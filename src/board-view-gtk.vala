/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class BoardViewGtk : Gtk.Grid
{
    private new const int size = 5;
    private PuzzleGenerator puzzle_generator;
    private Gtk.ToggleButton[,] lights;

    public bool playable = true;

    private int _moves = 0;
    public int moves
    {
        get { return _moves;}
    }

    public signal void game_won ();
    public signal void light_toggled ();

    public BoardViewGtk ()
    {
        get_style_context ().add_class ("grid");
        row_homogeneous = true;
        column_homogeneous = true;
        border_width = 4;
        row_spacing = 2;
        column_spacing = 2;

        set_size_request (size * 72, size * 72);

        puzzle_generator = new PuzzleGenerator (size);
        lights = new Gtk.ToggleButton [size, size];
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
            {
                lights[x, y] = new Gtk.ToggleButton ();
                lights[x, y].show ();
                lights[x, y].toggled.connect (light_toggled_cb);
                attach (lights[x, y], x, y, 1, 1);
            }

        _moves = 0;
    }

    public void slide_in (int direction, int sign, Clutter.Timeline timeline)
    {
    }

    public void slide_out (int direction, int sign, Clutter.Timeline timeline)
    {
    }

    public void swap_in (float direction, Clutter.Timeline timeline)
    {
    }

    public void swap_out (float direction, Clutter.Timeline timeline)
    {
    }

    private void find_light (Gtk.ToggleButton light, out int x, out int y)
    {
        x = y = 0;
        for (x = 0; x < size; x++)
            for (y = 0; y < size; y++)
                if (lights[x, y] == light)
                    return;
    }

    private bool is_completed ()
    {
        var cleared = true;
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (lights[x, y].active)
                    cleared = false;

        return cleared;
    }

    public void light_toggled_cb (Gtk.ToggleButton source)
    {
        int xl, yl;
        find_light (source, out xl, out yl);

        toggle_light (xl, yl, true);
        _moves += 1;
        light_toggled ();
        if (is_completed ()) {
            game_won ();
        }
    }
    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.

     // Toggle a light and those in each cardinal direction around it.
    private void toggle_light (int x, int y, bool clicked = false)
    {
        for (var xi = 0; xi < size; xi++)
            for (var yi = 0; yi < size; yi++)
                lights[xi, yi].toggled.disconnect (light_toggled_cb);

        if (x>= size || y >= size || x < 0 || y < 0 )
            return;
        if ((int) x + 1 < size)
            lights[(int) x + 1, (int) y].set_active (!lights[(int) x + 1, (int) y].get_active ());
        if ((int) x - 1 >= 0)
            lights[(int) x - 1, (int) y].set_active (!lights[(int) x - 1, (int) y].get_active ());
        if ((int) y + 1 < size)
            lights[(int) x, (int) y + 1].set_active (!lights[(int) x, (int) y + 1].get_active ());
        if ((int) y - 1 >= 0)
            lights[(int) x, (int) y - 1].set_active (!lights[(int) x, (int) y - 1].get_active ());

        if (!clicked)
            lights[(int) x, (int) y].set_active (!lights[(int) x, (int) y ].get_active ());

        for (var xi = 0; xi < size; xi++)
            for (var yi = 0; yi < size; yi++)
                lights[xi, yi].toggled.connect (light_toggled_cb);
    }

    public void load_level (int level)
    {
        _moves = 0;
        light_toggled ();
        /* We *must* not have level < 1, as the following assumes a nonzero, nonnegative number */
        if (level < 1)
            level = 1;

        for (var xi = 0; xi < size; xi++)
            for (var yi = 0; yi < size; yi++)
                lights[xi, yi].toggled.disconnect (light_toggled_cb);

        /* Clear level */
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                lights[x, y].active = false;

        /* Use the same pseudo-random levels */
        Random.set_seed (level);

        /* Levels require more and more clicks to make */
        var solution_length = (int) Math.floor (2 * Math.log (level) + 1);

        /* Do the moves the player needs to */
        var sol = puzzle_generator.minimal_solution (solution_length);
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                if (sol[x, y])
                    toggle_light (x, y);
    }
}
