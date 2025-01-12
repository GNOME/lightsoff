/*
 * Copyright (C) 2020 Arnaud Bonatti
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Adw;

private class ManagedWindow : ApplicationWindow
{
    private int window_width = 0;
    private int window_height = 0;
    private bool window_is_maximized = false;
    private bool window_is_fullscreen = false;
    private bool window_is_tiled = false;

    construct
    {
        connect_callbacks ();
        load_window_state ();
    }

    /*\
    * * callbacks
    \*/

    private inline void connect_callbacks ()
    {
        map.connect (init_state_watcher);
        unmap.connect (on_unmap);
    }

    private inline void init_state_watcher ()
    {
        Gdk.Surface? nullable_surface = get_surface ();     // TODO report bug, get_surface() returns a nullable Surface
        if (nullable_surface == null || !((!) nullable_surface is Gdk.Toplevel))
            assert_not_reached ();
        surface = (Gdk.Toplevel) (!) nullable_surface;
        surface.notify ["state"].connect (on_window_state_event);
    }

    private Gdk.Toplevel surface;
    private const Gdk.ToplevelState tiled_state = Gdk.ToplevelState.TILED
                                                | Gdk.ToplevelState.TOP_TILED
                                                | Gdk.ToplevelState.BOTTOM_TILED
                                                | Gdk.ToplevelState.LEFT_TILED
                                                | Gdk.ToplevelState.RIGHT_TILED;
    private inline void on_window_state_event ()
    {
        Gdk.ToplevelState state = surface.get_state ();

        window_is_maximized  = (state & Gdk.ToplevelState.MAXIMIZED)  != 0;

        /* fullscreen: saved as maximized */
        window_is_fullscreen = (state & Gdk.ToplevelState.FULLSCREEN) != 0;

        /* tiled: not saved, but should not change saved window size */
        window_is_tiled      = (state & tiled_state)                  != 0;
    }

    private inline void on_unmap ()
    {
        save_window_state ();
        application.quit ();
    }

    /*\
    * * manage window state
    \*/

    [CCode (notify = false)] public string schema_path
    {
        protected construct
        {
            string? _value = value;
            if (_value == null)
                assert_not_reached ();

            settings = new GLib.Settings.with_path ("org.gnome.LightsOff.Lib", value);
            settings.delay ();
        }
    }
    private GLib.Settings settings;

    private inline void load_window_state ()   // called on construct
    {
        if (settings.get_boolean ("window-is-maximized"))
            maximize ();
        set_default_size (settings.get_int ("window-width"), settings.get_int ("window-height"));
    }

    private inline void save_window_state ()   // called on unmap
    {
        settings.delay ();
        settings.set_int ("window-width", window_width);
        settings.set_int ("window-height", window_height);
        settings.set_boolean ("window-is-maximized", window_is_maximized || window_is_fullscreen);
        settings.apply ();
    }
}

