#!/usr/bin/env seed

file_prefix = imports.path.file_prefix;

GtkClutter = imports.gi.GtkClutter;
Clutter = imports.gi.Clutter;
Gtk = imports.gi.Gtk;
GtkBuilder = imports.gtkbuilder;
GnomeGamesSupport = imports.gi.GnomeGamesSupport;
_ = imports.gettext.gettext;

Gtk.init(Seed.argv);
GtkClutter.init(Seed.argv);
GnomeGamesSupport.runtime_init("lightsoff");
GnomeGamesSupport.stock_init();

Game = imports.Game;
Settings = imports.Settings;
About = imports.About;
themes = imports.ThemeLoader;

handlers = {
	show_settings: function(selector, ud)
	{
		Settings.show_settings();
	},
	show_about: function(selector, ud)
	{
		About.show_about_dialog();
	},
	show_help: function(selector, ud)
	{
		GnomeGamesSupport.help_display(window, _("lightsoff"), null);
	},
	reset_score: function(selector, ud)
	{
		game.reset_game();
	},
	quit: function(selector, ud)
	{
		Gtk.main_quit();
	}
};

b = new Gtk.Builder();
b.add_from_file(file_prefix + "/lightsoff.ui");
b.connect_signals(handlers);

var window = b.get_object("game_window");
var clutter_embed = new GtkClutter.Embed();
window.signal.hide.connect(Gtk.main_quit);
b.get_object("game_vbox").pack_start(clutter_embed, true, true);

var stage = clutter_embed.get_stage();
stage.color = {alpha:255};
stage.set_use_fog(false);

// TODO: determine size of window before we show it
// NOTE: show the window before the stage, and the stage before any children
window.show_all();
stage.show_all();

themes.load_theme(stage, Settings.theme);

var game = new Game.GameView();
stage.add_actor(game);
stage.set_size(game.width, game.height);
clutter_embed.set_size_request(stage.width, stage.height);

stage.signal.key_release_event.connect(game.update_keyboard_selection);

Gtk.main();
