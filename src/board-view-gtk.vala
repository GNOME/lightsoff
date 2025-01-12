/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Gtk;

private class BoardViewGtk : Grid, BoardView
{
    private PuzzleGenerator puzzle_generator;
    private ToggleButton[,] lights;

    private const int MIN_TOGGLE_SIZE = 48;

    construct
    {
        add_css_class ("grid");
        row_homogeneous = true;
        column_homogeneous = true;
        margin_start = 2;
        margin_end = 2;
        margin_top = 2;
        margin_bottom = 2;
        row_spacing = 2;
        column_spacing = 2;

        set_size_request (size * MIN_TOGGLE_SIZE, size * MIN_TOGGLE_SIZE);

        puzzle_generator = new PuzzleGenerator (size);
        lights = new ToggleButton [size, size];
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
            {
                lights[x, y] = new ToggleButton ();
                lights[x, y].toggled.connect (handle_toggle);
                attach (lights[x, y], x, y, 1, 1);
            }
        completed.connect (() => set_sensitive (false));
    }

    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.

    internal void set_light (ToggleButton toggle, bool val)
    {
        toggle.toggled.disconnect (handle_toggle);
        toggle.set_active (val);
        toggle.toggled.connect (handle_toggle);
    }

    internal void invert_light (int x, int y)
    {
        var toggle = lights [x, y];
        var active = toggle.get_active ();
        set_light (toggle, !active);
    }

    // Toggle a light and those in each cardinal direction around it.
    internal void toggle_light (int x, int y, bool clicked = true)
    {
        if (x>= size || y >= size || x < 0 || y < 0 )
            return;
        if ((int) x + 1 < size)
            invert_light (x + 1, y);
        if ((int) x - 1 >= 0)
            invert_light (x - 1, y);
        if ((int) y + 1 < size)
            invert_light (x, y + 1);
        if ((int) y - 1 >= 0)
            invert_light (x, y - 1);

        if (!clicked)
            invert_light (x, y);
    }

    internal void clear_level ()
    {
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
            {
                set_light (lights[x, y], false);
            }
    }

    internal PuzzleGenerator get_puzzle_generator ()
    {
        return puzzle_generator;
    }

    internal bool is_light_active (int x, int y)
    {
        return lights[x, y].active;
    }

    internal GLib.Object get_light_at (int x, int y)
    {
        return lights[x, y];
    }

}
