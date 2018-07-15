/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class BoardViewGtk : Gtk.Grid, BoardView
{
    private PuzzleGenerator puzzle_generator;
    private Gtk.ToggleButton[,] lights;

    public bool playable = true;

    private int _moves = 0;
    public int moves
    {
        get { return _moves;}
    }

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
        List<Gtk.Widget> focus_list = new List<Gtk.Widget> ();
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
            {
                lights[x, y] = new Gtk.ToggleButton ();
                lights[x, y].show ();
                lights[x, y].toggled.connect (light_toggled_cb);
                attach (lights[x, y], x, y, 1, 1);
                focus_list.append (lights[x, y]);
            }
        set_focus_chain (focus_list);
        _moves = 0;
    }

    public void light_toggled_cb (Gtk.ToggleButton source)
    {
        int xl, yl;
        find_light (source, out xl, out yl);
        move_to (xl, yl);
    }
    // Pseudorandomly generates and sets the state of each light based on
    // a level number; hopefully this is stable between machines, but that
    // depends on GLib's PRNG stability. Also, provides some semblance of
    // symmetry for some levels.

     // Toggle a light and those in each cardinal direction around it.
    private void toggle_light (int x, int y, bool clicked = true)
    {
        @foreach((light) => (light as Gtk.ToggleButton).toggled.disconnect (light_toggled_cb));

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

        @foreach((light) => (light as Gtk.ToggleButton).toggled.connect (light_toggled_cb));
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

        @foreach((light) => (light as Gtk.ToggleButton).toggled.disconnect (light_toggled_cb));

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
                    toggle_light (x, y, false);
    }

    private void find_light (GLib.Object light, out int x, out int y)
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

    public void move_to (int x, int y)
    {
        toggle_light (x, y);
        _moves += 1;
        light_toggled ();
        if (is_completed ()) {
            game_won ();
        }
    }

}
