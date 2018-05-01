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

public class GameView : Clutter.Group
{
    private Clutter.Texture highlight_texture;
    private Clutter.Texture off_texture;
    private Clutter.Texture on_texture;

    private int current_level;

    private List<Clutter.Actor> actor_remove_queue = null;

    private Clutter.Actor board_group;
    private BoardView board_view;
    private BoardView? new_board_view = null;
    private Clutter.Actor key_cursor_view;

    private Clutter.Timeline timeline;
    private int key_cursor_x = 0;
    private int key_cursor_y = 0;
    private bool key_cursor_ready = false;

    private int last_direction = 0;

    private int last_sign = 0;

    public signal void level_changed (int level);
    public signal void moves_changed (int moves);

    public GameView (int level)
    {
        try
        {
            highlight_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "highlight.svg"));
            off_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "off.svg"));
            on_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "on.svg"));
        }
        catch (Clutter.TextureError e)
        {
            warning ("Failed to load textures: %s", e.message);
        }

        /* Add textures onto the scene so they can be cloned */
        highlight_texture.hide ();
        add_child (highlight_texture);
        off_texture.hide ();
        add_child (off_texture);
        on_texture.hide ();
        add_child (on_texture);

        board_group = new Clutter.Actor ();
        add_child (board_group);

        current_level = level;
        board_view = create_board_view (current_level);
        board_view.playable = true;
        board_group.add_child (board_view);

        var real_board_width = 5 * off_texture.width + 4;
        var real_board_height = 5 * off_texture.height + 4;
        set_size (real_board_width, real_board_height);

        key_cursor_view = new Clutter.Clone (highlight_texture);
        key_cursor_view.set_position (-100, -100);
        key_cursor_view.anchor_gravity = Clutter.Gravity.CENTER;
        add_child (key_cursor_view);
    }

    private BoardView create_board_view (int level)
    {
        var view = new BoardView (off_texture, on_texture);
        view.load_level (level);
        view.game_won.connect (game_won_cb);
        view.light_toggled.connect (light_toggled_cb);
        view.playable = false;
        return view;
    }

    // The boards have finished transitioning; delete the old one!
    private void transition_complete_cb ()
    {
        board_view.destroy ();
        board_view = new_board_view;
        board_view.playable = true;
        new_board_view = null;
        timeline = null;

        // Remove all of the queued-for-removal actors
        foreach (var actor in actor_remove_queue)
            actor.destroy ();
        actor_remove_queue = null;
    }

    private void light_toggled_cb ()
    {
        moves_changed (board_view.moves);
    }

    // The player won the game; create a new board, update the level count,
    // and transition between the two boards in a random direction.
    private void game_won_cb ()
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level++;

        // Make sure the board transition is different than the previous.
        var direction = 0;
        var sign = 0;
        do
        {
            direction = Random.int_range (0, 2); // x or y
            sign = Random.boolean () ? 1 : -1; // left/right up/down
        }
        while (last_direction == direction && last_sign == sign);
        last_direction = direction;
        last_sign = sign;

        new_board_view = create_board_view (current_level);
        board_group.add_child (new_board_view);

        timeline = new Clutter.Timeline (1500);
        new_board_view.slide_in (direction, sign, timeline);
        board_view.slide_out (direction, sign, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }

    // The player asked to swap to a different level without completing
    // the one in progress; this can occur either by clicking an arrow
    // or by requesting a new game from the menu. Animate the new board
    // in, depthwise, in the direction indicated by 'context'.
    public void swap_board (int direction)
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level += direction;
        if (current_level <= 0)
        {
            current_level = 1;
            return;
        }

        timeline = new Clutter.Timeline (500);

        new_board_view = create_board_view (current_level);
        board_group.add_child (new_board_view);
        new_board_view.z_position = -250 * direction;
        new_board_view.opacity = 0;

        new_board_view.swap_in (direction, timeline);
        board_view.swap_out (direction, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }

    public void hide_cursor ()
    {
        setup_animation (key_cursor_view, Clutter.AnimationMode.EASE_OUT_SINE, 250);
        key_cursor_view.set_opacity (0);
        key_cursor_ready = false;
    }

    public void move_cursor (int x_step, int y_step)
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
            key_cursor_view.set_position (x, y);
        }
        else
        {
            key_cursor_view.opacity = 0;
            key_cursor_view.set_position (x, y);
            setup_animation (key_cursor_view, Clutter.AnimationMode.EASE_OUT_SINE, 250);
            key_cursor_view.set_opacity (255);
        }

        key_cursor_ready = true;
    }

    public void activate_cursor ()
    {
        if (key_cursor_ready)
            board_view.move_to (key_cursor_x, key_cursor_y);
    }

    public void reset_game ()
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level = 1;

        timeline = new Clutter.Timeline (500);

        new_board_view = create_board_view (current_level);
        board_group.add_child (new_board_view);
        new_board_view.z_position = 250;
        new_board_view.opacity = 0;

        new_board_view.swap_in (-1, timeline);
        board_view.swap_out (-1, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }
}
