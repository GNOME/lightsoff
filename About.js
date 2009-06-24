Gtk = imports.gi.Gtk;
GnomeGamesSupport = imports.gi.GnomeGamesSupport;

main = imports.main;

// How do we do translation from Seed?

function show_about_dialog()
{
	var about_dialog = new Gtk.AboutDialog();
	about_dialog.program_name = "Lights Off";
	about_dialog.version = "1.0";
	about_dialog.comments = "Turn off all the lights\n\nLights Off is a part of GNOME Games.";
	about_dialog.copyright = "Copyright \xa9 2009 Tim Horton";
	about_dialog.license = GnomeGamesSupport.get_license("Gnometris"); // FIXME
	about_dialog.wrap_license = true;
	about_dialog.logo_icon_name = "gnome-lightsoff";
	about_dialog.website = "http://www.gnome.org/projects/gnome-games/";
	about_dialog.website_label = "GNOME Games web site"; // this doesn't work for anyone

	about_dialog.set_authors(["Tim Horton"]);

	// TODO: some form of wrapper so we can use gtk_show_about_dialog instead
	// of faking all of its window-management-related stuff

	about_dialog.set_transient_for(main.window);
	about_dialog.run();
	
	about_dialog.hide();
}
