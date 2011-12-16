private class Light : Clutter.Group
{
    private Clutter.Actor off;
    private Clutter.Actor on;

    private bool _is_lit;
    public bool is_lit
    {
        get { return _is_lit; }
        set
        {
            value = value != false;
            if (value != _is_lit)
                toggle ();
        }
    }

    public Light (Clutter.Actor off_actor, Clutter.Actor on_actor)
    {
        set_scale (0.9, 0.9);

        off = new Clutter.Clone (off_actor);
        off.anchor_gravity = Clutter.Gravity.CENTER;
        add_actor (off);

        on = new Clutter.Clone (on_actor);
        on.anchor_gravity = Clutter.Gravity.CENTER;
        on.opacity = 0;
        add_actor (on);

        // Add a 2 px margin around the tile image, center tiles within it.
        width += 4;
        height += 4;
        off.set_position (width / 2, height / 2);
        on.set_position (width / 2, height / 2);
    }

    public void toggle (Clutter.Timeline? timeline = null)
    {
        _is_lit = !_is_lit;

        if (timeline != null)
        {
            // Animate the opacity of the 'off' tile to match the state.
            off.animate_with_timeline (Clutter.AnimationMode.EASE_OUT_SINE, timeline, "opacity", is_lit ? 0 : 255);
            on.animate_with_timeline (Clutter.AnimationMode.EASE_OUT_SINE, timeline, "opacity", is_lit ? 255 : 0);

            // Animate the tile to be smaller when in the 'off' state.
            animate_with_timeline (Clutter.AnimationMode.EASE_OUT_SINE, timeline,
                                   "scale-x", is_lit ? 1.0 : 0.9,
                                   "scale-y", is_lit ? 1.0 : 0.9);
        }
        else
        {
            off.opacity = is_lit ? 0 : 255;
            on.opacity = is_lit ? 255 : 0;
            scale_x = is_lit ? 1 : 0.9;
            scale_y = is_lit ? 1 : 0.9;
        }
    }
}

public class BoardView : Clutter.Group
{
    private const int size = 5;
    private PuzzleGenerator puzzle_generator;
    private Clutter.Texture off_texture;
    private Clutter.Texture on_texture;
    private Light[,] lights;

    public bool playable = true;
    
    public signal void game_won ();
    
    public BoardView (Clutter.Texture off_texture, Clutter.Texture on_texture)
    {
        this.off_texture = off_texture;
        this.on_texture = on_texture;
        puzzle_generator = new PuzzleGenerator (size);
        lights = new Light [size, size];
        for (var x = 0; x < size; x++)
        {
            for (var y = 0; y < size; y++)
            {
                var l = new Light (off_texture, on_texture);

                l.reactive = true;
                l.button_press_event.connect (light_button_press_cb);

                float xx, yy;
                get_light_position (x, y, out xx, out yy);
                l.anchor_gravity = Clutter.Gravity.CENTER;
                l.set_position (xx, yy);

                lights[x, y] = l;
                add_actor (l);
            }
        }
    }

    public void get_light_position (int x, int y, out float xx, out float yy)
    {
        // All lights need to be shifted down and right by half a light,
        // as lights have center gravity.
        xx = (x + 0.5f) * off_texture.width + 2;
        yy = (y + 0.5f) * off_texture.height + 2;
    }
    
    public void fade_in (Clutter.Timeline timeline)
    {
        animate_with_timeline (Clutter.AnimationMode.EASE_OUT_SINE, timeline, "opactity", 0);
    }

    public void fade_out (Clutter.Timeline timeline)
    {
        animate_with_timeline (Clutter.AnimationMode.EASE_OUT_SINE, timeline, "opactity", 255);
    }
   
    public void slide_in (int direction, int sign, Clutter.Timeline timeline)
    {
        /* Place offscreen */
        x = -sign * direction * width;
        y = -sign * (1 - direction) * height;

        /* Slide onscreen */
        animate_with_timeline (Clutter.AnimationMode.EASE_OUT_BOUNCE, timeline, "x", 0.0, "y", 0.0);
    }

    public void slide_out (int direction, int sign, Clutter.Timeline timeline)
    {
        /* Slide offscreen */
        animate_with_timeline (Clutter.AnimationMode.EASE_OUT_BOUNCE, timeline,
                               "x", sign * direction * width,
                               "y", sign * (1 - direction) * height);
    }
   
    public void swap_in (float direction, Clutter.Timeline timeline)
    {
        /* Bring into foreground and make visible */
        animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                               "opacity", 255,
                               "depth", 0.0);
    }

    public void swap_out (float direction, Clutter.Timeline timeline)
    {
        /* Fade into background or drop down */
        animate_with_timeline (Clutter.AnimationMode.EASE_IN_SINE, timeline,
                               "depth", 250.0 * direction,
                               "opacity", 0);
    }

    private void find_light (Light light, out int x, out int y)
    {
        x = y = 0;
        for (x = 0; x < size; x++) 
            for (y = 0; y < size; y++)
                if (lights[x, y] == light)
                    return;
    }

    private bool light_button_press_cb (Clutter.Actor actor, Clutter.ButtonEvent event)
    {
        int x, y;
        find_light ((Light) actor, out x, out y);
        toggle_light (x, y);
        return false;
    }

    // Toggle a light and those in each cardinal direction around it.
    public void toggle_light (int x, int y, bool animate = true)
    {
        if (!playable)
            return;
            
        Clutter.Timeline? timeline = null;
        if (animate)
        {
            timeline = new Clutter.Timeline (300);
            timeline.completed.connect (toggle_completed_cb);
        }

        if ((int) x + 1 < size)
            lights[(int) x + 1, (int) y].toggle (timeline);
        if ((int) x - 1 >= 0)
            lights[(int) x - 1, (int) y].toggle (timeline);
        if ((int) y + 1 < size)
            lights[(int) x, (int) y + 1].toggle (timeline);
        if ((int) y - 1 >= 0)
            lights[(int) x, (int) y - 1].toggle (timeline);

        lights[(int) x, (int) y].toggle (timeline);

        if (animate)
            timeline.start ();
    }

    private void toggle_completed_cb ()
    {
        var cleared = true;
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (lights[x, y].is_lit)
                    cleared = false;

        if (cleared)
            game_won ();
    }
        
    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of 
    // symmetry for some levels.
    public void load_level (int level)
    {
        /* We *must* not have level < 1, as the following assumes a nonzero, nonnegative number */
        if (level < 1)
            level = 1;

        /* Clear level */
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                lights[x, y].is_lit = false;

        /* Use the same pseudo-random levels */
        Random.set_seed (level);

        /* Levels require more and more clicks to make */
        var solution_length = (int) Math.floor (2 * Math.log (level) + 1);

        /* Do the moves the player needs to */
        var sol = puzzle_generator.minimal_solution (solution_length);
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (sol[x, y])
                    toggle_light (x, y, false);
    }
}
