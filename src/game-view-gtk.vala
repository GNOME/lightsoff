public class GtkGameView : Gtk.Grid, GameView {

    private Gtk.ToggleButton[,] lights;
    private new const int SIZE = 5;
    private PuzzleGenerator puzzle_generator;
    private int current_level;
    private int moves;

    public void swap_board (int direction)
    {
        current_level += direction;
        load_level (current_level);
    }
    public void hide_cursor ()
    {
    }
    public void activate_cursor ()
    {
    }
    public void move_cursor (int x, int y)
    {
    }
    public void reset_game ()
    {


    }

    public GtkGameView (int level)
    {
        puzzle_generator = new PuzzleGenerator (SIZE);
                /* Clear level */
        current_level = level;
        lights = new Gtk.ToggleButton [SIZE, SIZE];
        for (var x = 0; x < SIZE; x++)
            for (var y = 0; y < SIZE; y++)
            {
                lights[x, y] = new Gtk.ToggleButton ();
                lights[x, y].show ();
                lights[x, y].toggled.connect (light_toggled_cb);
                attach (lights[x, y], x, y, 1, 1);
            }

        set_size_request (SIZE * 64, SIZE * 64);
        row_homogeneous = true;
        column_homogeneous = true;
        load_level (current_level);
    }

    private void find_light (Gtk.ToggleButton light, out int x, out int y)
    {
        x = y = 0;
        for (x = 0; x < SIZE; x++)
            for (y = 0; y < SIZE; y++)
                if (lights[x, y] == light)
                    return;
    }

    private bool is_completed ()
    {
        var cleared = true;
        for (var x = 0; x < SIZE; x++)
            for (var y = 0; y < SIZE; y++)
                if (lights[x, y].active)
                    cleared = false;

        return cleared;
    }

    public void light_toggled_cb (Gtk.ToggleButton source)
    {
        int xl, yl;
        find_light (source, out xl, out yl);

        toggle_light (xl, yl, true);
        moves_changed (++moves);
        if (is_completed ()) {
            load_level (++current_level);
        }
    }
    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.

     // Toggle a light and those in each cardinal direction around it.
    private void toggle_light (int x, int y, bool clicked = false)
    {
        for (var xi = 0; xi < SIZE; xi++)
            for (var yi = 0; yi < SIZE; yi++)
                lights[xi, yi].toggled.disconnect (light_toggled_cb);

        if (x>= SIZE || y >= SIZE || x < 0 || y < 0 )
            return;
        if ((int) x + 1 < SIZE)
            lights[(int) x + 1, (int) y].set_active (!lights[(int) x + 1, (int) y].get_active ());
        if ((int) x - 1 >= 0)
            lights[(int) x - 1, (int) y].set_active (!lights[(int) x - 1, (int) y].get_active ());
        if ((int) y + 1 < SIZE)
            lights[(int) x, (int) y + 1].set_active (!lights[(int) x, (int) y + 1].get_active ());
        if ((int) y - 1 >= 0)
            lights[(int) x, (int) y - 1].set_active (!lights[(int) x, (int) y - 1].get_active ());

        if (!clicked)
            lights[(int) x, (int) y].set_active (!lights[(int) x, (int) y ].get_active ());

        for (var xi = 0; xi < SIZE; xi++)
            for (var yi = 0; yi < SIZE; yi++)
                lights[xi, yi].toggled.connect (light_toggled_cb);
    }

    public void load_level (int level)
    {
        moves = 0;
        moves_changed (moves);
        level_changed (level);
        /* We *must* not have level < 1, as the following assumes a nonzero, nonnegative number */
        if (level < 1)
            level = 1;

        for (var xi = 0; xi < SIZE; xi++)
            for (var yi = 0; yi < SIZE; yi++)
                lights[xi, yi].toggled.disconnect (light_toggled_cb);

        /* Clear level */
        for (var x = 0; x < SIZE; x++)
            for (var y = 0; y < SIZE; y++)
                lights[x, y].active = false;

        /* Use the same pseudo-random levels */
        Random.set_seed (level);

        /* Levels require more and more clicks to make */
        var solution_length = (int) Math.floor (2 * Math.log (level) + 1);

        /* Do the moves the player needs to */
        var sol = puzzle_generator.minimal_solution (solution_length);
        for (var x = 0; x < SIZE; x++)
            for (var y = 0; y < SIZE; y++)
                if (sol[x, y])
                    toggle_light (x, y);
    }
}
