public class LightsOff
{
    private Settings settings;
    private Gtk.Builder ui;
    private Gtk.Window window;
    private GameView game_view;
    
    private LightsOff () throws Error
    {
        settings = new Settings ("org.gnome.lightsoff");

        ui = new Gtk.Builder();
        ui.add_from_file ("data/lightsoff.ui");
        ui.connect_signals (this);

        window = (Gtk.Window) ui.get_object ("game_window");
        window.hide.connect (Gtk.main_quit);

        var box = (Gtk.Box) ui.get_object ("game_vbox");

        var clutter_embed = new GtkClutter.Embed ();
        clutter_embed.show ();
        box.pack_start (clutter_embed, true, true);

        var stage = (Clutter.Stage) clutter_embed.get_stage ();
        stage.key_release_event.connect (key_release_event_cb);
        stage.color = Clutter.Color.from_string ("#000000");
        stage.use_fog = false;

        game_view = new GameView (settings.get_int ("level"));
        game_view.level_changed.connect (level_changed_cb);
        game_view.show ();
        stage.add_actor (game_view);

        stage.set_size (game_view.width, game_view.height);
        clutter_embed.set_size_request ((int) stage.width, (int) stage.height);        
    }
    
    private void level_changed_cb (int level)
    {
        settings.set_int ("level", level);
    }

    private bool key_release_event_cb (Clutter.Actor actor, Clutter.KeyEvent event)
    {
        switch (event.keyval)
        {
        case Clutter.KEY_Escape:
            game_view.hide_cursor ();
            return true;
        case Clutter.KEY_Down:
            game_view.move_cursor (0, 1);
            return true;
        case Clutter.KEY_Up:
            game_view.move_cursor (0, -1);
            return true;
        case Clutter.KEY_Left:
            game_view.move_cursor (-1, 0);
            return true;
        case Clutter.KEY_Right:
            game_view.move_cursor (1, 0);
            return true;
        case Clutter.KEY_Return:
            game_view.activate_cursor ();
            return true;
        default:
            return false;
        }
    }

    public void show ()
    {
        window.show ();
    }

    [CCode (cname = "G_MODULE_EXPORT new_game_cb", instance_pos = -1)]
    public void new_game_cb (Gtk.Widget widget)
    {
        game_view.reset_game();
    }

    [CCode (cname = "G_MODULE_EXPORT quit_cb", instance_pos = -1)]
    public void quit_cb (Gtk.Widget widget)
    {
        Gtk.main_quit ();
    }

    [CCode (cname = "G_MODULE_EXPORT help_cb", instance_pos = -1)]
    public void help_cb (Gtk.Widget widget)
    {
        GnomeGamesSupport.help_display (window, "lightsoff", null);
    }

    [CCode (cname = "G_MODULE_EXPORT about_cb", instance_pos = -1)]
    public void about_cb (Gtk.Widget widget)
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
                               "copyright", "Copyright \xa9 2009 Tim Horton",
                               "license", GnomeGamesSupport.get_license (_("Lights Off")),
                               "wrap-license", true,
                               "authors", authors,
                               "artists", artists,
                               "documenters", documenters,
                               "translator-credits", _("translator-credits"),
                               "logo-icon-name", "gnome-lightsoff",
                               "website", "http://www.gnome.org/projects/gnome-games",
                               "website-label", _("GNOME Games web site"),
                               null);
    }

    public static int main (string[] args)
    {
        Environment.set_prgname ("lightsoff");

        if (GtkClutter.init (ref args) != Clutter.InitError.SUCCESS)
        {
            warning ("Failed to initialise Clutter");
            return Posix.EXIT_FAILURE;
        }

        GnomeGamesSupport.runtime_init ("lightsoff");
        GnomeGamesSupport.stock_init ();

        LightsOff app;
        try
        {
            app = new LightsOff ();
            app.show ();
        }
        catch (Error e)
        {
            warning ("Failed to create application: %s", e.message);
            return Posix.EXIT_FAILURE;
        }

        Gtk.main ();

        GnomeGamesSupport.runtime_shutdown();

        return Posix.EXIT_SUCCESS;
    }
}
