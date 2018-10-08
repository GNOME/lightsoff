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

using Config;

public class LightsOff : Gtk.Application
{
    private LightsoffWindow window;

    private static bool version = false;
    private static bool gtk = false;

    private const GLib.OptionEntry[] options = {
        // --version
        { "version", 0, 0, OptionArg.NONE, ref version, "Display version number", null },

        // --gtk-mode
        { "gtk-mode", 0, 0, OptionArg.NONE, ref gtk, "Use native graphics", null },

        // list terminator
        { null }
    };

    private const GLib.ActionEntry[] action_entries =
    {
        { "help",          help_cb     },
        { "about",         about_cb    }
    };

    private LightsOff ()
    {
        Object (application_id: "org.gnome.lightsoff", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void startup ()
    {
        base.startup ();

        Gtk.Window.set_default_icon_name ("lightsoff");
        Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);

        add_action_entries (action_entries, this);

        window = new LightsoffWindow (gtk);
        add_window (window);
    }

    public override void activate ()
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

    private void about_cb ()
    {
        string[] authors =
        {
            "Tim Horton",
            "Robert Ancell",
            "Robert Roth",
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
                               _("Turn off all the lights"),
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
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        Environment.set_application_name (_("Lights Off"));

        try {
            var opt_context = new OptionContext ("");
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, Config.GETTEXT_PACKAGE);
            opt_context.parse (ref args);
        } catch (OptionError e) {
            print (_("Run `%s --help` to see a full list of available command line options.\n"), args[0]);
            return 0;
        }

        if (version) {
            print ("%s %s\n", _("Lights Off"), VERSION);
            return 0;
        }
        if (!gtk && GtkClutter.init (ref args) != Clutter.InitError.SUCCESS)
        {
            warning ("Failed to initialise Clutter");
            return Posix.EXIT_FAILURE;
        }

        var app = new LightsOff ();
        return app.run ();
    }
}
