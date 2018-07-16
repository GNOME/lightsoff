/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */
public interface BoardView: GLib.Object {

    protected new const int size = 5;

    public abstract int get_moves ();
    public abstract PuzzleGenerator get_puzzle_generator ();
    public abstract void clear_level ();
    public abstract void toggle_light (int x, int y, bool user_initiated = true);
    public abstract void increase_moves ();
    public abstract bool is_light_active (int x, int y);

    public abstract GLib.Object get_light_at (int x, int y);

    public signal void game_won ();
    public signal void light_toggled ();

        // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.
    public void load_level (int level)
    {
        /* We *must* not have level < 1, as the following assumes a nonzero, nonnegative number */
        if (level < 1)
            level = 1;

        clear_level ();
        /* Use the same pseudo-random levels */
        Random.set_seed (level);

        /* Levels require more and more clicks to make */
        var solution_length = (int) Math.floor (2 * Math.log (level) + 1);

        /* Do the moves the player needs to */
        var sol = get_puzzle_generator ().minimal_solution (solution_length);
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (sol[x, y])
                    toggle_light (x, y, false);
    }

    public void handle_toggle (GLib.Object light)
    {
        int x, y;
        find_light (light, out x, out y);
        move_to (x, y);
    }

    public void find_light (GLib.Object light, out int x, out int y)
    {
        x = y = 0;
        for (x = 0; x < size; x++)
            for (y = 0; y < size; y++)
                if (get_light_at (x, y) == light)
                    return;
    }

    public void move_to (int x, int y)
    {
        toggle_light (x, y);
        increase_moves ();
        light_toggled ();
        if (is_completed ()) {
            game_won ();
        }
    }

    public bool is_completed ()
    {
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (is_light_active (x, y))
                    return false;

        return true;
    }
}
