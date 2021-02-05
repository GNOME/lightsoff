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
    private int _moves = 0;
    internal int get_moves () { return _moves; }

    construct
    {
        get_style_context ().add_class ("grid");
        row_homogeneous = true;
        column_homogeneous = true;
        border_width = 2;
        row_spacing = 2;
        column_spacing = 2;

        set_size_request (size * MIN_TOGGLE_SIZE, size * MIN_TOGGLE_SIZE);

        puzzle_generator = new PuzzleGenerator (size);
        lights = new ToggleButton [size, size];
        List<Widget> focus_list = new List<Widget> ();
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
            {
                lights[x, y] = new ToggleButton ();
                lights[x, y].show ();
                lights[x, y].toggled.connect (handle_toggle);
                attach (lights[x, y], x, y, 1, 1);
                focus_list.append (lights[x, y]);
            }
        set_focus_chain (focus_list);
        _moves = 0;
        completed.connect (() => set_sensitive (false));
        show ();
    }

    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.

    // Toggle a light and those in each cardinal direction around it.
    internal void toggle_light (int x, int y, bool clicked = true)
    {
        @foreach((light) => ((ToggleButton)light).toggled.disconnect (handle_toggle));

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

        @foreach((light) => ((ToggleButton)light).toggled.connect (handle_toggle));
    }

    internal void clear_level ()
    {
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                lights[x, y].active = false;
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

    internal void increase_moves ()
    {
        _moves += 1;
    }
}
