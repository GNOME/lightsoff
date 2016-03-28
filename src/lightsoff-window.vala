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

[GtkTemplate (ui = "/org/gnome/lightsoff/ui/lightsoff.ui")]
public class LightsoffWindow : ApplicationWindow
{
    [GtkChild] private HeaderBar headerbar;

    private GLib.Settings settings;
    private GameView game_view;
    private SimpleAction previous_level;

    private const GLib.ActionEntry[] window_actions =
    {
        { "new-game",       new_game_cb },
        { "previous-level", previous_level_cb },
        { "next-level",     next_level_cb }
    };

    public LightsoffWindow ()
    {
        settings = new GLib.Settings ("org.gnome.lightsoff");

        add_action_entries (window_actions, this);
        previous_level = (SimpleAction) this.lookup_action ("previous-level");

        level_changed_cb (settings.get_int ("level"));

        var clutter_embed = new GtkClutter.Embed ();
        clutter_embed.show ();
        this.add (clutter_embed);

        var stage = (Clutter.Stage) clutter_embed.get_stage ();
        stage.key_release_event.connect (key_release_event_cb);
        stage.background_color = Clutter.Color.from_string ("#000000");

        game_view = new GameView (settings.get_int ("level"));
        game_view.level_changed.connect (level_changed_cb);
        game_view.moves_changed.connect (update_subtitle);
        game_view.show ();
        stage.add_child (game_view);

        stage.set_size (game_view.width, game_view.height);
        clutter_embed.set_size_request ((int) stage.width, (int) stage.height);
    }

    private void update_subtitle (int moves)
    {
        headerbar.subtitle = ngettext ("%d move", "%d moves", moves).printf (moves);
    }

    private void update_title (int level)
    {
        /* The title of the window, %d is the level number */
        headerbar.title = _("Level %d").printf (level);

        /* Subtitle is a game hint when playing level one, the number of moves otherwise */
        if (level == 1)
            headerbar.subtitle = _("Turn off all the lights!");
        else
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
        if (level != settings.get_int ("level"))
            settings.set_int ("level", level);
    }

    private bool key_release_event_cb (Clutter.Actor actor, Clutter.KeyEvent event)
    {
        switch (event.keyval)
        {
        case Clutter.Key.Escape:
            game_view.hide_cursor ();
            return true;
        case Clutter.Key.Down:
            game_view.move_cursor (0, 1);
            return true;
        case Clutter.Key.Up:
            game_view.move_cursor (0, -1);
            return true;
        case Clutter.Key.Left:
            game_view.move_cursor (-1, 0);
            return true;
        case Clutter.Key.Right:
            game_view.move_cursor (1, 0);
            return true;
        case Clutter.Key.Return:
            game_view.activate_cursor ();
            return true;
        default:
            return false;
        }
    }

    private void new_game_cb ()
    {
        game_view.reset_game ();
    }
 }
