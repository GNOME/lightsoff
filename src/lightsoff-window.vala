/*
 * Copyright (C) 2010-2013 Robert Ancell
 * Copyright (C) 2014 Michael Catanzaro
 * Copyright (C) 2016 Arnaud Bonatti
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Gtk;

[GtkTemplate (ui = "/org/gnome/LightsOff/ui/lightsoff.ui")]
private class LightsoffWindow : ManagedWindow
{
    [GtkChild] private HeaderBar headerbar;
    [GtkChild] private MenuButton menu_button;

    private GLib.Settings settings;
    private GameView game_view;
    private SimpleAction previous_level;
    private EventControllerKey key_controller;

    private const GLib.ActionEntry[] window_actions =
    {
        { "new-game",       new_game_cb },
        { "previous-level", previous_level_cb },
        { "next-level",     next_level_cb }
    };

    private inline void init_keyboard ()
    {
        key_controller = new EventControllerKey (this);
        key_controller.key_pressed.connect (on_key_pressed);
    }

    private Gtk.Widget build_game_container (int level, out GameView out_game_view)
    {
        var aspect_frame = new Gtk.AspectFrame (null, 0.5f, 0.5f, 1.0f, false);
        aspect_frame.set_shadow_type (ShadowType.NONE);
        aspect_frame.get_style_context ().add_class ("aspect");
        aspect_frame.show ();

        GtkGameView gtk_game_view = new GtkGameView (level);
        gtk_game_view.show ();

        aspect_frame.add (gtk_game_view);
        out_game_view = gtk_game_view;

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/org/gnome/LightsOff/ui/lightsoff.css");
        Gdk.Screen? gdk_screen = Gdk.Screen.get_default ();
        if (gdk_screen != null) // else..?
            StyleContext.add_provider_for_screen ((!) gdk_screen, provider, STYLE_PROVIDER_PRIORITY_APPLICATION);

        return aspect_frame;
    }

    internal LightsoffWindow ()
    {
        Object (schema_path: "/org/gnome/LightsOff/");

        settings = new GLib.Settings ("org.gnome.LightsOff");

        var menu_builder = new Gtk.Builder.from_resource ("/org/gnome/LightsOff/gtk/menus.ui");
        menu_button.set_menu_model ((GLib.Menu) menu_builder.get_object ("primary-menu"));

        add_action_entries (window_actions, this);
        previous_level = (SimpleAction) this.lookup_action ("previous-level");

        init_keyboard ();
        int level = settings.get_int ("level");
        level_changed_cb (level);

        this.add (build_game_container (level, out game_view));

        this.set_resizable (true);
        game_view.level_changed.connect (level_changed_cb);
        game_view.moves_changed.connect (update_subtitle);

    }

    private void update_subtitle (int moves)
    {
        headerbar.subtitle = ngettext ("%d move", "%d moves", moves).printf (moves);
    }

    private void update_title (int level)
    {
        /* Translators: the title of the window, %d is the level number */
        headerbar.title = _("Puzzle %d").printf (level);

        if (level == 1)
            /* Translators: default subtitle, only displayed when playing level one; used as a game hint */
            headerbar.subtitle = _("Turn off all the lights!");
        else
            /* else show number of moves */
            update_subtitle (0);
    }

    private void previous_level_cb ()
    {
        game_view.swap_board (-1);
    }

    private void next_level_cb ()
    {
        game_view.swap_board (1);
    }

    private void level_changed_cb (int level)
    {
        previous_level.set_enabled (level > 1);
        update_title (level);
        set_focus_visible (false);
        if (level != settings.get_int ("level"))
            settings.set_int ("level", level);
    }

    private inline bool on_key_pressed (EventControllerKey _key_controller, uint keyval, uint keycode, Gdk.ModifierType state)
    {
        if (menu_button.get_active())
            return false;
        switch (keyval)
        {
        case Gdk.Key.Escape:
            set_focus_visible (false);
            return game_view.hide_cursor ();
        case Gdk.Key.Down:
            return game_view.move_cursor (0, 1);
        case Gdk.Key.Up:
            return game_view.move_cursor (0, -1);
        case Gdk.Key.Left:
            return game_view.move_cursor (-1, 0);
        case Gdk.Key.Right:
            return game_view.move_cursor (1, 0);
        case Gdk.Key.Return:
            return game_view.activate_cursor ();
        default:
            return false;
        }
    }

    private void new_game_cb ()
    {
        game_view.reset_game ();
    }
}
