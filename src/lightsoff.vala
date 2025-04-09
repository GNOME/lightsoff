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

using Adw;

private class LightsOff : Adw.Application
{
    /* Translators: name of the program, as seen in the headerbar, in GNOME Shell, or in the about dialog */
    private const string PROGRAM_NAME = _("Lights Off");

    private LightsoffWindow window;

    private static string? [] remaining = new string? [1];
    private const OptionEntry [] option_entries =
    {
        /* Translators: command-line option description, see 'lightsoff --help' */
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, null,                       N_("Display version number"),   null }, // is usually "Print release version and exit"

        { OPTION_REMAINING, 0, OptionFlags.NONE, OptionArg.STRING_ARRAY, ref remaining, "args", null },
        {}
    };

    private const GLib.ActionEntry[] action_entries =
    {
        { "help",          help_cb     },
        { "quit",          quit_cb     },
        { "about",         about_cb    }
    };

    private static int main (string[] args)
    {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        Environment.set_application_name (PROGRAM_NAME);

        var app = new LightsOff ();
        return app.run (args);
    }

    private LightsOff ()
    {
        Object (application_id: "org.gnome.LightsOff", flags: ApplicationFlags.DEFAULT_FLAGS);

        add_main_option_entries (option_entries);
    }

    protected override int handle_local_options (GLib.VariantDict options)
    {
        if (options.contains ("version")
         || remaining [0] != null && (!) remaining [0] == "version")
        {
            print ("%s %s\n", PROGRAM_NAME, Config.VERSION);   // TODO is usually not translated, for parsing... would be better?
            return Posix.EXIT_SUCCESS;
        }

        if (remaining [0] != null)
        {
            /* Translators: command-line error message, displayed for an invalid CLI command; see 'lightsoff unparsed' */
            stderr.printf (_("Failed to parse command-line arguments.") + "\n");
            return Posix.EXIT_FAILURE;
        }

        /* Activate */
        return -1;
    }

    protected override void startup ()
    {
        base.startup ();

        add_action_entries (action_entries, this);

        // generic
        set_accels_for_action ("app.quit",              { "<Primary>q"          });
        set_accels_for_action ("app.help",              {          "F1"         });

        // "Change Puzzle" menu
        set_accels_for_action ("win.new-game",          { "<Primary>n"          });
        set_accels_for_action ("win.previous-level",    { "<Primary>Page_Up"    });
        set_accels_for_action ("win.next-level",        { "<Primary>Page_Down"  });

        // game menu
        set_accels_for_action ("win.restart",           { "<Primary>r"          });
    }

    protected override void activate ()
    {
        if (window == null)
        {
            window = new LightsoffWindow ();
            add_window (window);
        }

        window.present ();
    }

    private inline void help_cb ()
    {
        Gtk.show_uri (window, "help:lightsoff", Gdk.CURRENT_TIME);
    }

    private void quit_cb ()
    {
        window.destroy ();
    }

    private void about_cb ()
    {
        string[] authors =
        {
            "Tim Horton",
            "Robert Ancell",
            "Robert Roth"
        };

        string[] artists =
        {
            "Tim Horton",
            "Ulisse Perusin"
        };

        string[] documenters =
        {
            "Eric Baudais"
        };

        /* Translators: short description of the application, seen in the About dialog */
        string comments = _("Turn off all the lights");

        show_about_dialog (window,
                           "application-name",      PROGRAM_NAME,
                           "version",               Config.VERSION,
                           "developer_name",        _("The GNOME Project"),
                           "comments",              comments,
                           "copyright",             "Copyright © 2009 Tim Horton",  // TODO _("Copyright \xc2\xa9 %u-%u – Arnaud Bonatti").printf (20xx, 20xx)
                           "license-type",          Gtk.License.GPL_2_0,
                           "developers",            authors,
                           "artists",               artists,
                           "documenters",           documenters,
        /* Translators: about dialog text; this string should be replaced by a text crediting yourselves and your translation team, or should be left empty. Do not translate literally! */
                           "translator-credits",    _("translator-credits"),
                           "application-icon",      "org.gnome.LightsOff",
                           "website",               "https://wiki.gnome.org/Apps/Lightsoff");
    }
}
