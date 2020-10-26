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
    [GtkChild] private unowned HeaderBar                headerbar;
    [GtkChild] private unowned MenuButton               menu_button;
    [GtkChild] private unowned Label                    level_label;
    [GtkChild] private unowned GameButton               game_button_1;
    [GtkChild] private unowned GameButton               game_button_2;
    [GtkChild] private unowned AspectFrame              aspect_frame;
    [GtkChild] private unowned Revealer                 revealer;
    [GtkChild] private unowned NotificationsRevealer    notifications_revealer;

    private GLib.Settings settings;
    private GameView game_view;
    private SimpleAction previous_level;
    private SimpleAction restart_action;
    private EventControllerKey key_controller;

    private string custom_title = "";

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
        key_controller = new EventControllerKey (this);
        key_controller.key_pressed.connect (on_key_pressed);
    }

    private inline void populate_game_container (int level)
    {
        GtkGameView gtk_game_view = new GtkGameView (level);
        gtk_game_view.hexpand = true;
        gtk_game_view.vexpand = true;

        aspect_frame.add (gtk_game_view);
        game_view = gtk_game_view;

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/org/gnome/LightsOff/ui/lightsoff.css");
        Gdk.Display? gdk_display = Gdk.Display.get_default ();
        if (gdk_display != null) // else..?
            StyleContext.add_provider_for_display ((!) gdk_display, provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    internal LightsoffWindow ()
    {
        Object (schema_path: "/org/gnome/LightsOff/");

        settings = new GLib.Settings ("org.gnome.LightsOff");

        var menu_builder = new Gtk.Builder.from_resource ("/org/gnome/LightsOff/ui/menus.ui");
        menu_button.set_menu_model ((GLib.Menu) menu_builder.get_object ("primary-menu"));

        add_action_entries (window_actions, this);
        previous_level = (SimpleAction) this.lookup_action ("previous-level");
        restart_action = (SimpleAction) this.lookup_action ("restart");
        enable_restart_action (false);

        init_keyboard ();
        int level = settings.get_int ("level");
        level_changed_cb (level);
        if (level == 1)
            /* Translators: short game explanation, displayed as an in-app notification when game is launched on level 1 */
            notifications_revealer.show_notification (_("Turn off all the lights!"));

        populate_game_container (level);

        game_view.level_changed.connect (level_changed_cb);
        game_view.moves_changed.connect (update_subtitle);
    }

    private void update_subtitle (int moves)
    {
        string moves_string = moves.to_string ();
        game_button_1.set_label (moves_string);
        game_button_2.set_label (moves_string);
        enable_restart_action (moves > 0);
    }

    private void update_title ()
    {
        if (large_window_size)
            headerbar.set_title (custom_title);
        level_label.set_label (custom_title);
        update_subtitle (0);
        notifications_revealer.hide_notification ();
    }

    private void enable_restart_action (bool new_state)
    {
        restart_action.set_enabled (new_state);
        game_button_1.set_sensitive (new_state);
        game_button_2.set_sensitive (new_state);
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
        custom_title = _("Puzzle %d").printf (level);
        update_title ();
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
        enable_restart_action (false);
    }

    bool large_window_size = true;
    protected override void change_window_size (bool large)
    {
        large_window_size = large;
        if (large)
        {
            game_button_1.show ();
            headerbar.set_title (custom_title);
            revealer.set_reveal_child (false);
            notifications_revealer.set_window_size (/* thin */ false);
        }
        else
        {
            game_button_1.hide ();
            headerbar.set_title (null);
            revealer.set_reveal_child (true);
            notifications_revealer.set_window_size (/* thin */ true);
        }
    }
}

[GtkTemplate (ui = "/org/gnome/LightsOff/ui/game-button.ui")]
private class GameButton : MenuButton
{
}
