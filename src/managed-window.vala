/*
 * Copyright (C) 2020 Arnaud Bonatti
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Gtk;

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
        window_state_event.connect (on_window_state_event);
        size_allocate.connect (on_size_allocate);
        destroy.connect (on_destroy);
    }

    private const Gdk.WindowState tiled_state = Gdk.WindowState.TILED
                                              | Gdk.WindowState.TOP_TILED
                                              | Gdk.WindowState.BOTTOM_TILED
                                              | Gdk.WindowState.LEFT_TILED
                                              | Gdk.WindowState.RIGHT_TILED;
    private inline bool on_window_state_event (Widget widget, Gdk.EventWindowState event)
    {
        if ((event.changed_mask & Gdk.WindowState.MAXIMIZED) != 0)
            window_is_maximized = (event.new_window_state & Gdk.WindowState.MAXIMIZED) != 0;

        /* fullscreen: saved as maximized */
        if ((event.changed_mask & Gdk.WindowState.FULLSCREEN) != 0)
            window_is_fullscreen = (event.new_window_state & Gdk.WindowState.FULLSCREEN) != 0;

        /* tiled: not saved, but should not change saved window size */
        if ((event.changed_mask & tiled_state) != 0)
            window_is_tiled = (event.new_window_state & tiled_state) != 0;

        return false;
    }

    private inline void on_size_allocate (Allocation allocation)
    {
        if (window_is_maximized || window_is_tiled || window_is_fullscreen)
            return;
        int? _window_width = null;
        int? _window_height = null;
        get_size (out _window_width, out _window_height);
        if (_window_width == null || _window_height == null)
            return;
        window_width = (!) _window_width;
        window_height = (!) _window_height;

        update_adaptative_children ();
    }

    private inline void on_destroy ()
    {
        save_window_state ();
        base.destroy ();
    }

    /*\
    * * adaptative stuff
    \*/

    private enum WindowSize
    {
        START,
        SMALL,
        LARGE
    }
    private WindowSize window_size = WindowSize.START;

    private void update_adaptative_children ()
    {
        if (window_width < 590)
            _change_window_size (WindowSize.SMALL);
        else
            _change_window_size (WindowSize.LARGE);
    }

    private void _change_window_size (WindowSize new_window_size)
    {
        if (window_size == new_window_size)
            return;
        window_size = new_window_size;
        change_window_size (window_size == WindowSize.LARGE);
    }

    protected virtual void change_window_size (bool large) {}

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
        }
    }
    private GLib.Settings settings;

    private inline void load_window_state ()   // called on construct
    {
        if (settings.get_boolean ("window-is-maximized"))
            maximize ();
        set_default_size (settings.get_int ("window-width"), settings.get_int ("window-height"));
    }

    private inline void save_window_state ()   // called on destroy
    {
        settings.delay ();
        settings.set_int ("window-width", window_width);
        settings.set_int ("window-height", window_height);
        settings.set_boolean ("window-is-maximized", window_is_maximized || window_is_fullscreen);
        settings.apply ();
    }
}
