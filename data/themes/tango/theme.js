file_prefix = imports.path.file_prefix;

Clutter = imports.gi.Clutter;

var name = "Tango";
var setup_done = false;
var light = [ load_svg("off.svg"), load_svg("on.svg") ];
var arrow = load_svg("arrow.svg");
var backing = load_svg("backing.svg");
var led_back = load_svg("led-back.svg");
var highlight = load_svg("highlight.svg");

function setup(a)
{
	if(setup_done)
		return;
	setup_done = true;

	a.add_actor(light[0]);
	a.add_actor(light[1]);
	a.add_actor(arrow);
	a.add_actor(backing);
	a.add_actor(led_back);
	a.add_actor(highlight);
}

// helper functions should be put somewhere global

function load_svg(file)
{
	// TODO: either imports should set the cwd (and this can go away),
	// or we need some quick way to compose paths. Really, we need that anyway.
	
	var tx = new Clutter.Texture({filename: file_prefix + "themes/tango/" + file});
	tx.filter_quality = Clutter.TextureQuality.HIGH;
	tx.hide();
	return tx;
}
