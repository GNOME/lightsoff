Clutter = imports.gi.Clutter;
ThemeLoader = imports.ThemeLoader;

var name = "Tango";

var light = [ ThemeLoader.load_svg("tango", "off.svg"),
              ThemeLoader.load_svg("tango", "on.svg") ];
var arrow = ThemeLoader.load_svg("tango", "arrow.svg");
var backing = ThemeLoader.load_svg("tango", "backing.svg");
var led_back = ThemeLoader.load_svg("tango", "led-back.svg");
var highlight = ThemeLoader.load_svg("tango", "highlight.svg");

var loaded = false;
var textures = [light[0], light[1], arrow, backing, led_back, highlight];

