file_prefix = '/usr/local' + "/share/gnome-games/lightsoff/";

Clutter = imports.gi.Clutter;

var name = "tango";

var light = [ load_svg("off.svg"), load_svg("on.svg") ];
var arrow = load_svg("arrow.svg");
var backing = load_svg("backing.svg");
var led_back = load_svg("led-back.svg");
var led_front = load_svg("led-front.svg");

// helper functions should be put somewhere global

function load_svg(file)
{
	// TODO: either imports should set the cwd (and this can go away),
	// or we need some quick way to compose paths. Really, we need that anyway.
	
	var tx = new Clutter.Texture({filename: file_prefix + "themes/" + name + "/" + file});
	tx.filter_quality = Clutter.TextureQuality.HIGH;
	return tx;
}
