/*
 * Copyright (C) 2010-2013 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Config;

public void setup_animation (Clutter.Actor actor, Clutter.AnimationMode mode, uint duration) {
    actor.set_easing_duration (duration);
    actor.set_easing_mode (mode);
}

public class ClutterGameView : Clutter.Group, GameView
{
    private Clutter.Actor off_texture;
    private Clutter.Actor on_texture;

    private int current_level;

    private List<Clutter.Actor> actor_remove_queue = null;

    private Clutter.Actor board_group;
    private BoardViewClutter board_view;
    private Clutter.Actor key_cursor_view;

    private Clutter.Timeline timeline;
    private int key_cursor_x = 0;
    private int key_cursor_y = 0;
    private bool key_cursor_ready = false;

    private int last_direction = 0;

    private int last_sign = 0;

    private Clutter.Actor build_from_file ( string filename ) throws GLib.Error
    {
        var filepath = Path.build_filename (Config.DATADIR, filename);
        var handle = new Rsvg.Handle.from_file (filepath);
        Gdk.Pixbuf pixbuf = handle.get_pixbuf ();
        Clutter.Image image = new Clutter.Image ();
        image.set_data (pixbuf.get_pixels (),
                         pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                         pixbuf.width,
                         pixbuf.height,
                         pixbuf.rowstride);
        Clutter.Actor result = new Clutter.Actor ();
        result.set_content (image);
        float width, height;
        image.get_preferred_size (out width, out height);
        result.set_pivot_point (0.5f, 0.5f);
        result.set_size (width, height);
        return result;
    }

    public ClutterGameView (int level)
    {
        try
        {
            key_cursor_view = build_from_file ("highlight.svg");
            on_texture = build_from_file ( "on.svg");
            off_texture = build_from_file ( "off.svg");
        }
        catch (GLib.Error e)
        {
            warning ("Failed to load images: %s", e.message);
        }

        /* Add textures onto the scene so they can be cloned */
        off_texture.hide ();
        add_child (off_texture);
        on_texture.hide ();
        add_child (on_texture);

        board_group = new Clutter.Actor ();
        add_child (board_group);

        current_level = level;
        board_view = create_board_view (current_level) as BoardViewClutter;
        board_view.playable = true;
        board_group.add_child (board_view);

        var real_board_width = 5 * off_texture.width + 4;
        var real_board_height = 5 * off_texture.height + 4;
        set_size (real_board_width, real_board_height);

        key_cursor_view.set_pivot_point (0.5f, 0.5f);
        key_cursor_view.set_position (-100, -100);
        key_cursor_view.set_size (off_texture.width, off_texture.height);
        add_child (key_cursor_view);
    }

    public BoardView create_board_view (int level)
    {
        var view = new BoardViewClutter (off_texture, on_texture);
        view.load_level (level);
        view.game_won.connect (() => game_won_cb());
        view.light_toggled.connect (light_toggled_cb);
        view.playable = false;
        return view;
    }

    // The boards have finished transitioning; delete the old one!
    private void board_replaced (BoardViewClutter old_view, BoardViewClutter new_view)
    {
        old_view.destroy ();
        // Remove all of the queued-for-removal actors
        foreach (var actor in actor_remove_queue)
            actor.destroy ();
        actor_remove_queue = null;

        new_view.playable = true;
        timeline = null;
        board_view = new_view;
    }

    public void replace_board (BoardView old_board, BoardView new_board, GameView.ReplaceStyle style, bool fast = true)
    {
        timeline = new Clutter.Timeline (fast ? 500 : 1500);
        board_group.add_child (new_board as Clutter.Group);
        int direction = 1;
        BoardViewClutter new_board_view = new_board as BoardViewClutter;
        BoardViewClutter old_board_view = old_board as BoardViewClutter;
        switch (style)
        {
            case REFRESH: 
                new_board_view.z_position = 250;
                new_board_view.opacity = 0;
                /* Fade into background or drop down */
                old_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                                       "z_position", 250.0 * -1,
                                       "opacity", 0);
                        /* Bring into foreground and make visible */
                new_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                               "opacity", 255,
                               "z_position", 0.0);
                break;
            case SLIDE_NEXT:
                // Make sure the board transition is different than the previous.
                direction = 0;
                var sign = 0;
                do
                {
                    direction = Random.int_range (0, 2); // x or y
                    sign = Random.boolean () ? 1 : -1; // left/right up/down
                }
                while (last_direction == direction && last_sign == sign);
                last_direction = direction;
                last_sign = sign;

                timeline = new Clutter.Timeline (1500);
                new_board_view.slide_in (direction, sign, timeline);
                old_board_view.slide_out (direction, sign, timeline);
                break;
            case SLIDE_FORWARD: 
                new_board_view.z_position = -250 * direction;
                new_board_view.opacity = 0;
                /* Fade into background or drop down */
                old_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                                       "z_position", 250.0 * direction,
                                       "opacity", 0);
                        /* Bring into foreground and make visible */
                new_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                               "opacity", 255,
                               "z_position", 0.0);
                break;
            case SLIDE_BACKWARD: 
                direction = -1;
                new_board_view.z_position = -250 * direction;
                new_board_view.opacity = 0;
                /* Fade into background or drop down */
                old_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                                       "z_position", 250.0 * direction,
                                       "opacity", 0);
                        /* Bring into foreground and make visible */
                new_board_view.animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                               "opacity", 255,
                               "z_position", 0.0);
                break;

            default: break;
        } 
        timeline.completed.connect (() => board_replaced (old_board_view, new_board_view));
        level_changed (current_level);
    }

    public bool hide_cursor ()
    {
        setup_animation (key_cursor_view, Clutter.AnimationMode.EASE_OUT_SINE, 250);
        key_cursor_view.set_opacity (0);
        key_cursor_ready = false;
        return true;
    }

    public bool move_cursor (int x_step, int y_step)
    {
        if (key_cursor_ready)
        {
            key_cursor_x += x_step;
            key_cursor_y += y_step;
            key_cursor_x = int.max (key_cursor_x, 0);
            key_cursor_x = int.min (key_cursor_x, 4); // FIXME: Get the size from the model
            key_cursor_y = int.max (key_cursor_y, 0);
            key_cursor_y = int.min (key_cursor_y, 4);
        }

        float x, y;
        board_view.get_light_position (key_cursor_x, key_cursor_y, out x, out y);

        if (key_cursor_ready)
        {
            setup_animation (key_cursor_view, Clutter.AnimationMode.EASE_OUT_SINE, 250);
            key_cursor_view.set_position (x + 2, y + 2);
        }
        else
        {
            key_cursor_view.opacity = 0;
            key_cursor_view.set_position (x + 2, y + 2);
            setup_animation (key_cursor_view, Clutter.AnimationMode.EASE_OUT_SINE, 250);
            key_cursor_view.set_opacity (255);
        }

        key_cursor_ready = true;
        return true;
    }

    public bool activate_cursor ()
    {
        if (key_cursor_ready)
            board_view.move_to (key_cursor_x, key_cursor_y);
        return true;
    }

    public void reset_game ()
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level = 1;

        replace_board (board_view, create_board_view (current_level), GameView.ReplaceStyle.REFRESH);
    }

    public BoardView get_board_view ()
    {
        return board_view;
    }

    public int next_level (int direction)
    {
        current_level += direction;
        return current_level;
    }

    public bool is_transitioning ()
    {
        return timeline != null && timeline.is_playing ();
    }
}
