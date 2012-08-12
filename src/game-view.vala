public class GameView : Clutter.Group
{
    private Clutter.Texture backing_texture;
    private Clutter.Texture highlight_texture;
    private Clutter.Texture off_texture;
    private Clutter.Texture on_texture;
    private Clutter.Texture led_back_texture;
    private Clutter.Texture arrow_texture;

    private int current_level;

    private List<Clutter.Actor> actor_remove_queue = null;

    private LEDArray score_view;
    private Clutter.Group board_group;
    private BoardView board_view;
    private BoardView? new_board_view = null;
    private Clutter.Actor backing_view;
    private Clutter.Actor left_arrow;
    private Clutter.Actor right_arrow;
    private Clutter.Actor key_cursor_view;

    private Clutter.Timeline timeline;
    private int key_cursor_x = 0;
    private int key_cursor_y = 0;
    private bool key_cursor_ready = false;

    private int last_direction = 0;

    private int last_sign = 0;

    public signal void level_changed (int level);

    public GameView (int level)
    {
        try
        {
            backing_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "backing.svg"));
            highlight_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "highlight.svg"));
            off_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "off.svg"));
            on_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "on.svg"));
            led_back_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "led-back.svg"));
            arrow_texture = new Clutter.Texture.from_file (Path.build_filename (Config.DATADIR, "arrow.svg"));
        }
        catch (Clutter.TextureError e)
        {
            warning ("Failed to load textures: %s", e.message);
        }

        /* Add textures onto the scene so they can be cloned */
        backing_texture.hide ();
        add_actor (backing_texture);
        highlight_texture.hide ();
        add_actor (highlight_texture);
        off_texture.hide ();
        add_actor (off_texture);
        on_texture.hide ();
        add_actor (on_texture);
        led_back_texture.hide ();
        add_actor (led_back_texture);
        arrow_texture.hide ();
        add_actor (arrow_texture);

        var real_board_width = 5 * off_texture.width + 4;
        var real_board_height = 5 * off_texture.height + 4;

        board_group = new Clutter.Group ();
        add_actor (board_group);

        current_level = level;
        board_view = create_board_view (current_level);
        board_view.playable = true;
        board_group.add_actor (board_view);

        backing_view = new Clutter.Clone (backing_texture);
        backing_view.set_position (0, real_board_height);
        add_actor (backing_view);

        score_view = new LEDArray (5, led_back_texture);
        score_view.value = current_level;
        score_view.set_anchor_point (score_view.width / 2, 0);
        score_view.set_position (real_board_width / 2, real_board_height + 18);
        add_actor (score_view);

        set_size (real_board_width, score_view.y + score_view.height);

        left_arrow = new Clutter.Clone (arrow_texture);
        left_arrow.anchor_gravity = Clutter.Gravity.CENTER;
        left_arrow.reactive = true;
        left_arrow.button_release_event.connect (left_arrow_button_release_cb);
        left_arrow.set_position ((score_view.x - score_view.anchor_x) / 2, score_view.y + (score_view.height / 2) - 10);
        add_actor (left_arrow);

        right_arrow = new Clutter.Clone (arrow_texture);
        right_arrow.anchor_gravity = Clutter.Gravity.CENTER;
        right_arrow.reactive = true;
        right_arrow.button_release_event.connect (right_arrow_button_release_cb);
        right_arrow.rotation_angle_y = 180;
        right_arrow.set_position (real_board_width - left_arrow.x, score_view.y + (score_view.height / 2) - 10);
        add_actor (right_arrow);

        key_cursor_view = new Clutter.Clone (highlight_texture);
        key_cursor_view.set_position (-100, -100);
        key_cursor_view.anchor_gravity = Clutter.Gravity.CENTER;
        add_actor (key_cursor_view);
    }

    private BoardView create_board_view (int level)
    {
        var view = new BoardView (off_texture, on_texture);
        view.load_level (level);
        view.game_won.connect (game_won_cb);
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

    // The player won the game; create a new board, update the level count,
    // and transition between the two boards in a random direction.
    private void game_won_cb ()
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level++;
        score_view.value = current_level;

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
        board_group.add_actor (new_board_view);

        timeline = new Clutter.Timeline (1500);
        new_board_view.slide_in (direction, sign, timeline);
        board_view.slide_out (direction, sign, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }

    private bool left_arrow_button_release_cb (Clutter.Actor actor, Clutter.ButtonEvent event)
    {
        swap_board (-1);
        return false;
    }

    private bool right_arrow_button_release_cb (Clutter.Actor actor, Clutter.ButtonEvent event)
    {
        swap_board (1);
        return false;
    }

    // The player asked to swap to a different level without completing
    // the one in progress; this can occur either by clicking an arrow
    // or by requesting a new game from the menu. Animate the new board
    // in, depthwise, in the direction indicated by 'context'.
    private void swap_board (int direction)
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level += direction;
        if (current_level <= 0)
        {
            current_level = 1;
            return;
        }

        score_view.value = current_level;

        timeline = new Clutter.Timeline (500);

        new_board_view = create_board_view (current_level);
        board_group.add_actor (new_board_view);
        new_board_view.depth = -250 * direction;
        new_board_view.opacity = 0;

        new_board_view.swap_in (direction, timeline);
        board_view.swap_out (direction, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }

    public void hide_cursor ()
    {
        key_cursor_view.animate (Clutter.AnimationMode.EASE_OUT_SINE, 250, "opacity", 0);
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
            key_cursor_view.animate (Clutter.AnimationMode.EASE_OUT_SINE, 250, "x", x, "y", y);
        else
        {
            key_cursor_view.opacity = 0;
            key_cursor_view.set_position (x, y);
            key_cursor_view.animate (Clutter.AnimationMode.EASE_OUT_SINE, 250, "opacity", 255);
        }

        key_cursor_ready = true;
    }
    
    public void activate_cursor ()
    {
        if (key_cursor_ready)
            board_view.toggle_light (key_cursor_x, key_cursor_y);
    }

    public void reset_game ()
    {
        if (timeline != null && timeline.is_playing ())
            return;

        current_level = 1;
        score_view.value = current_level;

        timeline = new Clutter.Timeline (500);

        new_board_view = create_board_view (current_level);
        board_group.add_actor (new_board_view);
        new_board_view.depth = 250;
        new_board_view.opacity = 0;

        new_board_view.swap_in (-1, timeline);
        board_view.swap_out (-1, timeline);
        timeline.completed.connect (transition_complete_cb);

        level_changed (current_level);
    }
}
