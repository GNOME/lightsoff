/*
 * Copyright (C) 2010-2013 Robert Ancell
 * Copyright (C) 2014 Michael Catanzaro
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class LightsOff : Gtk.Application
{
    private Settings settings;
    private Gtk.ApplicationWindow window;
    private Gtk.HeaderBar headerbar;
    private GameView game_view;

    private const GLib.ActionEntry[] action_entries =
    {
        { "quit",          quit_cb     },
        { "help",          help_cb     },
        { "about",         about_cb    }
    };

    private const ActionEntry[] window_actions =
    {
        { "new-game",       new_game_cb },
        { "previous-level", previous_level_cb },
        { "next-level",     next_level_cb }
    };
    
    private LightsOff ()
    {
        Object (application_id: "org.gnome.lightsoff", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void startup ()
    {
        base.startup ();

        Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);

        add_action_entries (action_entries, this);
        add_accelerator ("<Primary>n", "win.new-game", null);
        add_accelerator ("F1", "app.help", null);
        add_accelerator ("<Primary>q", "app.quit", null);

        var menu = new Menu ();
        var section = new Menu ();
        menu.append_section (null, section);
        section.append (_("_New Game"), "win.new-game");
        section = new Menu ();
        menu.append_section (null, section);
        section.append (_("_Help"), "app.help");
        section.append (_("_About"), "app.about");
        section.append (_("_Quit"), "app.quit");
        set_app_menu (menu);

        settings = new Settings ("org.gnome.lightsoff");

        window = new Gtk.ApplicationWindow (this);
        window.add_action_entries (window_actions, this);
        window.icon_name = "lightsoff";
        window.resizable = false;

        var left_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON);
        left_button.valign = Gtk.Align.CENTER;
        left_button.action_name = "win.previous-level";
        left_button.set_tooltip_text (_("Return to the previous level"));
        left_button.show ();

        var right_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON);
        right_button.valign = Gtk.Align.CENTER;
        right_button.action_name = "win.next-level";
        right_button.set_tooltip_text (_("Proceed to the next level"));
        right_button.show ();

        headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.pack_start (left_button);
        headerbar.pack_end (right_button);
        headerbar.show ();
        level_changed_cb (settings.get_int ("level"));
        window.set_titlebar (headerbar);

        var clutter_embed = new GtkClutter.Embed ();
        clutter_embed.show ();
        window.add (clutter_embed);

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
        ((SimpleAction) (window.lookup_action ("previous-level"))).set_enabled (level > 1);
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

    public override void activate ()
    {
        window.present ();
    }

    private void new_game_cb ()
    {
        game_view.reset_game ();
    }

    private void quit_cb ()
    {
        window.destroy ();
    }

    private void help_cb ()
    {
        try
        {
            Gtk.show_uri (window.get_screen (), "help:lightsoff", Gtk.get_current_event_time ());
        }
        catch (Error e)
        {
            warning ("Failed to show help: %s", e.message);
        }
    }

    private void about_cb ()
    {
        string[] authors =
        {
            "Tim Horton",
            "Robert Ancell",
            null
        };

        string[] artists =
        {
            "Tim Horton",
            "Ulisse Perusin",
            null
        };

        string[] documenters =
        {
            "Eric Baudais",
            null
        };

        Gtk.show_about_dialog (window,
                               "program-name", _("Lights Off"),
                               "version", VERSION,
                               "comments",
                               _("Turn off all the lights\n\nLights Off is a part of GNOME Games."),
                               "copyright", "Copyright © 2009 Tim Horton",
                               "license-type", Gtk.License.GPL_2_0,
                               "authors", authors,
                               "artists", artists,
                               "documenters", documenters,
                               "translator-credits", _("translator-credits"),
                               "logo-icon-name", "lightsoff",
                               "website", "https://wiki.gnome.org/Apps/Lightsoff",
                               null);
    }

    public static int main (string[] args)
    {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        Environment.set_application_name (_("Lights Off"));

        if (GtkClutter.init (ref args) != Clutter.InitError.SUCCESS)
        {
            warning ("Failed to initialise Clutter");
            return Posix.EXIT_FAILURE;
        }

        var app = new LightsOff ();
        return app.run ();
    }
}
