Settings = imports.Settings;
GLib = imports.gi.GLib;
Clutter = imports.gi.Clutter;
Light = imports.Light;

var tiles = 5; // fix this

BoardView = new GType({
	parent: Clutter.Group.type,
	name: "BoardView",
	signals: [{name: "game_won"}],
	init: function(self)
	{
		// Private
		var self = this;
		var playable = true;
		var lights = [];
		var loading_level = false;
		
		// Create a two-dimensional array of 'tiles*tiles' lights,
		// connect to their clicked signals, and display them.
		var create_lights = function()
		{
			for(var x = 0; x < tiles; x++)
			{
				lights[x] = [];
				
				for(var y = 0; y < tiles; y++)
				{
					var l = new Light.LightView();
					var loc = self.position_for_light(x, y);
					l.set_position(loc.x, loc.y);
					l.signal.button_release_event.connect(light_clicked, {"x":x, "y":y});
					
					lights[x][y] = l;
					self.add_actor(l);
					
					GLib.main_context_iteration(null, false);
				}
			}
		}
		
		// Check if the game was won; if so, emit the game_won signal
		// in order to notify the Game controller.
		
		var check_won = function()
		{
			if(cleared())
				self.signal.game_won.emit();
		}
		
		// Callback for button_release_event from each light; user_data
		// is an object containing the coordinates of the clicked light.
		var light_clicked = function(light, event, coords)
		{
			self.light_toggle(coords.x, coords.y);
			
			return false;
		}
		
		// Returns whether or not the board is entirely 'off' (i.e. game is won)
		var cleared = function()
		{
			for(var x = 0; x < tiles; x++)
				for(var y = 0; y < tiles; y++)
					if(lights[x][y].get_state())
						return false;
			
			return true;
		}
		
		// Public
		
		// Toggle a light and those in each cardinal direction around it.
		this.light_toggle = function(x, y)
		{
			if(!playable)
				return;
			
			var timeline = null;
			
			if(!loading_level)
			{
				timeline = new Clutter.Timeline({duration: 300});
				timeline.signal.completed.connect(check_won);
			}
			
			if(x + 1 < tiles)
				lights[x + 1][y].toggle(timeline);
			if(x - 1 >= 0)
				lights[x - 1][y].toggle(timeline);
			if(y + 1 < tiles)
				lights[x][y + 1].toggle(timeline);
			if(y - 1 >= 0)
				lights[x][y - 1].toggle(timeline);

			lights[x][y].toggle(timeline);
			
			if(!loading_level)
				timeline.start();
		}
		
		this.position_for_light = function(x, y)
		{
			var p_l = {x: (x + 0.5) * Settings.theme.light[0].width,
			           y: (y + 0.5) * Settings.theme.light[0].height};
			
			return p_l;
		}
		
		// Pseudorandomly generates and sets the state of each light based on
		// a level number; hopefully this is stable between machines, but that
		// depends on GLib's PRNG stability. Also, provides some semblance of 
		// symmetry for some levels.
		this.load_level = function(level)
		{
			loading_level = true;
			
			for(var x = 0; x < tiles; x++)
				for(var y = 0; y < tiles; y++)
					lights[x][y].set_state(0, 0);
			
			GLib.random_set_seed(level);
			
			do
			{
				// log(level^2) gives a reasonable progression of difficulty
				var count = Math.floor(Math.log(level * level) + 1);
				var sym = Math.floor(3 * GLib.random_double());

				for (var q = 0; q < count; ++q)
				{
					i = Math.round((tiles - 1) * GLib.random_double());
					j = Math.round((tiles - 1) * GLib.random_double());
					
					self.light_toggle(i, j);
					
					// Ensure some level of "symmetry"
					var x_sym = Math.abs(i - (tiles - 1));
					var y_sym = Math.abs(j - (tiles - 1));
					
					if(sym == 0)
						self.light_toggle(x_sym, j);
					else if(sym == 1)
						self.light_toggle(x_sym, y_sym);
					else
						self.light_toggle(i, y_sym);
				}
			}
			while(cleared());
			
			loading_level = false;
		}
		
		this.set_playable = function(p)
		{
			playable = p;
		}
		
		this.fade_out = function(timeline)
		{
			self.animate_with_timeline(Clutter.AnimationMode.EASE_OUT_SINE, 
			                           timeline,
			{
				opacity: 0
			});
		}
		
		this.fade_in = function(timeline)
		{
			self.animate_with_timeline(Clutter.AnimationMode.EASE_OUT_SINE, 
			                           timeline,
			{
				opacity: 255
			});
		}
		
		this.animate_out = function(direction, sign, timeline)
		{
			self.animate_with_timeline(Clutter.AnimationMode.EASE_OUT_BOUNCE, 
			                           timeline,
			{
				x: sign * direction * self.width,
				y: sign * !direction * self.height
			});
		}
		
		this.animate_in = function(direction, sign, timeline)
		{
			self.x = (-sign) * direction * self.width;
			self.y = (-sign) * !direction * self.height;
			
			self.animate_with_timeline(Clutter.AnimationMode.EASE_OUT_BOUNCE, 
			                           timeline,
			{
				x: 0,
				y: 0
			});
		}
		
		this.swap_in = function(direction, timeline)
		{
			self.animate_with_timeline(Clutter.AnimationMode.EASE_IN_SINE, 
			                           timeline,
			{
				depth: 0,
				x: 0,
				y: 0,
				opacity: 255
			});
		}
		
		this.swap_out = function(direction, timeline)
		{
			self.animate_with_timeline(Clutter.AnimationMode.EASE_IN_SINE, 
			                           timeline,
			{
				depth: 250 * direction,
				x: 0,
				y: 0,
				opacity: 0
			});
		}
		
		// Implementation
		
		create_lights();
	}
});

