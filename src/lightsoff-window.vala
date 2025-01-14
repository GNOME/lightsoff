/*
 * Copyright (C) 2025 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Adw, Gtk;

[GtkTemplate (ui = "/org/gnome/LightsOff/lightsoff.ui")]
private class LightsoffWindow : ManagedWindow
{
    [GtkChild]
    private unowned MenuButton               menu_button;
    [GtkChild]
    private unowned AspectFrame              aspect_frame;
    [GtkChild]
    private unowned ToastOverlay             toast_overlay;
    [GtkChild]
    private unowned WindowTitle              title_widget;

    private Toast toast;
    private GLib.Settings settings;
    private GameView game_view;
    private SimpleAction previous_level;
    private SimpleAction restart_action;
    private EventControllerKey key_controller;

    private const GLib.ActionEntry[] window_actions =
    {
        // "Change Puzzle" menu
        { "new-game",       new_game_cb         },
        { "previous-level", previous_level_cb   },
        { "next-level",     next_level_cb       },

        // game menu
        { "restart",        restart_cb          },
    };

    private inline void init_keyboard ()
    {
        key_controller = new EventControllerKey ();
        key_controller.key_pressed.connect (on_key_pressed);
        ((Widget) this).add_controller (key_controller);
    }

    private inline void populate_game_container (int level)
    {
        GtkGameView gtk_game_view = new GtkGameView (level);
        gtk_game_view.hexpand = true;
        gtk_game_view.vexpand = true;

        aspect_frame.set_child (gtk_game_view);
        game_view = gtk_game_view;

    }

    internal LightsoffWindow ()
    {
        Object (schema_path: "/org/gnome/LightsOff/");

        settings = new GLib.Settings ("org.gnome.LightsOff");

        var menu_builder = new Gtk.Builder.from_resource ("/org/gnome/LightsOff/menus.ui");
        menu_button.set_menu_model ((GLib.Menu) menu_builder.get_object ("primary-menu"));

        add_action_entries (window_actions, this);
        previous_level = (SimpleAction) this.lookup_action ("previous-level");
        restart_action = (SimpleAction) this.lookup_action ("restart");
        enable_restart_action (false);

        init_keyboard ();
        int level = settings.get_int ("level");
        level_changed_cb (level);

        populate_game_container (level);

        game_view.level_changed.connect (level_changed_cb);
        game_view.moves_changed.connect (moves_changed_cb);
    }

    private void moves_changed_cb (int moves)
    {
        enable_restart_action (moves > 0);
        title_widget.set_subtitle (ngettext("%d move", "%d moves", moves).printf(moves));
    }

    private void update_title (string custom_title)
    {
        title_widget.set_title (custom_title);
        moves_changed_cb (0);
        if (toast != null)
            toast.dismiss ();
    }

    private void enable_restart_action (bool new_state)
    {
        restart_action.set_enabled (new_state);
    }

    private void previous_level_cb ()
    {
        game_view.swap_board (-1);
    }

    private void next_level_cb ()
    {
        game_view.swap_board (1);
    }

    private void restart_cb ()
    {
        game_view.swap_board (0);
        enable_restart_action (false);
    }

    private void level_changed_cb (int level)
    {
        previous_level.set_enabled (level > 1);
        enable_restart_action (false);
        /* Translators: the title of the window, %d is the level number */
        update_title (_("Puzzle %d").printf (level));
        // set_focus_visible (false);
        if (level != settings.get_int ("level"))
            settings.set_int ("level", level);
        set_focus (game_view as Gtk.Widget);
        if (level == 1)
        {
            /* Translators: short game explanation, displayed as an in-app notification when game is launched on level 1 */
            toast = new Toast (_("Turn off all the lights!"));

            toast_overlay.add_toast (toast);
        }
    }

    private inline bool on_key_pressed (EventControllerKey _key_controller, uint keyval, uint keycode, Gdk.ModifierType state)
    {
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
        enable_restart_action (false);
    }

}
