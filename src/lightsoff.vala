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

private class LightsOff : Gtk.Application
{
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

        Environment.set_application_name (_("Lights Off"));
        Gtk.Window.set_default_icon_name ("org.gnome.LightsOff");

        var app = new LightsOff ();
        return app.run (args);
    }

    private LightsOff ()
    {
        Object (application_id: "org.gnome.LightsOff", flags: ApplicationFlags.FLAGS_NONE);

        add_main_option_entries (option_entries);
    }

    protected override int handle_local_options (GLib.VariantDict options)
    {
        if (options.contains ("version")
         || remaining [0] != null && (!) remaining [0] == "version")
        {
            /* Translators: name of the program, as displayed in the output of the command-line 'lightsoff --version' */
            print ("%s %s\n", _("Lights Off"), Config.VERSION);    // TODO is usually not translated, for parsing... would be better?
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

        Gtk.Settings? gtk_settings = Gtk.Settings.get_default ();
        if (gtk_settings != null) // else..?
            ((!) gtk_settings).set ("gtk-application-prefer-dark-theme", true);

        add_action_entries (action_entries, this);

        set_accels_for_action ("app.quit", {"<control>Q"});
        set_accels_for_action ("app.help", {"F1"});

        set_accels_for_action ("win.new-game", {"<control>N"});
        set_accels_for_action ("win.previous-level", {"<control>Page_Up"});
        set_accels_for_action ("win.next-level", {"<control>Page_Down"});

        window = new LightsoffWindow ();
        add_window (window);
    }

    protected override void activate ()
    {
        window.present ();
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

        Gtk.show_about_dialog (window,
                               "program-name", _("Lights Off"),
                               "version", Config.VERSION,
                               "comments",
                               _("Turn off all the lights"),
                               "copyright", "Copyright © 2009 Tim Horton",
                               "license-type", Gtk.License.GPL_2_0,
                               "authors", authors,
                               "artists", artists,
                               "documenters", documenters,
                               "translator-credits", _("translator-credits"),
                               "logo-icon-name", "org.gnome.LightsOff",
                               "website", "https://wiki.gnome.org/Apps/Lightsoff");
    }
}
