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

    public Gtk.Widget build_game_container (int level, out GameView out_game_view)
    {
        var clutter_embed = new GtkClutter.Embed ();
        clutter_embed.show ();
        var stage = (Clutter.Stage) clutter_embed.get_stage ();
        stage.key_release_event.connect (key_release_event_cb);
        stage.background_color = Clutter.Color.from_string ("#000000");

        ClutterGameView clutter_game_view = new ClutterGameView (level);
        clutter_game_view.show ();

        stage.add_child (clutter_game_view);

        out_game_view = clutter_game_view;
        stage.set_size (clutter_game_view.width, clutter_game_view.height);
        clutter_embed.set_size_request ((int) stage.width, (int) stage.height);
        return clutter_embed;
    }

    public LightsoffWindow ()
    {
        settings = new GLib.Settings ("org.gnome.lightsoff");

        add_action_entries (window_actions, this);
        previous_level = (SimpleAction) this.lookup_action ("previous-level");

        int level = settings.get_int ("level");
        level_changed_cb (level);

        this.add (build_game_container (level, out game_view));

        game_view.level_changed.connect (level_changed_cb);
        game_view.moves_changed.connect (update_subtitle);

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
