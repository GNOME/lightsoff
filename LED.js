Settings = imports.Settings;
cairo = imports.cairo;
Clutter = imports.gi.Clutter;

const HORIZONTAL = 0;
const VERTICAL = 1;

LEDDigit = new GType({
	parent: Clutter.Group.type,
	name: "LEDDigit",
	init: function()
	{
		// Private
		
		var a, b, c, d, e, f, g;
		var scale = 23;
		var thickness = scale / 3;
		var pointy = thickness / 2;
		var margin = Math.floor(Math.log(scale));
		var segments = [];
		var s;
		
		// The state of each segment for each representable digit.
		var segment_states = { 0: [ 1, 1, 1, 1, 1, 0, 1],
		                       1: [ 0, 0, 0, 0, 1, 0, 1],
		                       2: [ 1, 0, 1, 1, 0, 1, 1],
		                       3: [ 1, 0, 0, 1, 1, 1, 1],
		                       4: [ 0, 1, 0, 0, 1, 1, 1],
		                       5: [ 1, 1, 0, 1, 1, 1, 0],
		                       6: [ 1, 1, 1, 1, 1, 1, 0],
		                       7: [ 1, 0, 0, 0, 1, 0, 1],
		                       8: [ 1, 1, 1, 1, 1, 1, 1],
		                       9: [ 1, 1, 0, 1, 1, 1, 1]};
		var segment_directions = { 0: HORIZONTAL,
		                           1: VERTICAL,
		                           2: VERTICAL,
		                           3: HORIZONTAL,
		                           4: VERTICAL,
		                           5: HORIZONTAL,
		                           6: VERTICAL };
		
		// Draw a single section, in either direction, at the given position
		var create_segment = function(num, x, y, alpha)
		{
			var texture = segments[num];
					
			var context = texture.create();
			var cr = new cairo.Context.steal(context);
			
			cr.set_source_rgba(1, 1, 1, 0);
			cr.paint();

			if(alpha)
				cr.set_source_rgba(0.145, 0.541, 1, 1);
			else
				cr.set_source_rgba(0.2, 0.2, 0.2, 1);
			
			cr.new_path();
			
			if(segment_directions[num] == VERTICAL)
			{
				cr.move_to(thickness / 2, 0);
				cr.line_to(0, pointy);
				cr.line_to(0, scale - pointy);
				cr.line_to(thickness / 2, scale);
				cr.line_to(thickness, scale - pointy);
				cr.line_to(thickness, pointy);
			}
			else if(segment_directions[num] == HORIZONTAL)
			{
				cr.move_to(0, thickness / 2);
				cr.line_to(pointy, 0);
				cr.line_to(scale - pointy, 0);
				cr.line_to(scale, thickness / 2);
				cr.line_to(scale - pointy, thickness);
				cr.line_to(pointy, thickness);
			}
			
			cr.close_path();
			cr.fill();
			cr.destroy();

			texture.set_position(x, y);

			return texture;
		}
		
		// Creates and arranges segments of the LEDDigit, lit based on the
		// represented digit.
		var draw_leds = function(group)
		{
			var side = pointy + margin;
			
			for(var i = 0; i < 7; i++)
			{
				segments[i] = new Clutter.CairoTexture();
				
				if(segment_directions[i] == VERTICAL)
					segments[i].set_surface_size(thickness, scale);
				else if(segment_directions[i] == HORIZONTAL)
					segments[i].set_surface_size(scale, thickness);
				
				group.add_actor(segments[i]);
			}
			
			create_segment(0, side, 0, s[0]);
			create_segment(1, 0, side, s[1]);
			create_segment(2, 0, side + scale + (margin*2), s[2]);
			create_segment(3, side, (2*scale) + (4*margin), s[3]);
			create_segment(4, scale + (2*margin),
			                   side + scale + (margin*2), s[4]);
			create_segment(5, side, scale + (2*margin), s[5]);
			create_segment(6, scale + (2*margin), side, s[6]);
		}
		
		// Public
		
		this.set_value = function(val)
		{
			s = segment_states[val];
			draw_leds(this);
		}
		
		// Implementation
		
		this.set_value(0);
	}
});

LEDView = new GType({
	parent: Clutter.Group.type,
	name: "LEDView",
	init: function()
	{
		// Private
		
		var value = 0;
		var width = 0;
		var margin = 5;
		var digits = [];
		var back, front;
		var inner_x_margin = 10;
		var inner_y_margin = -2;
		
		back = new Clutter.Clone({source: Settings.theme.led_back});
		//front = new Clutter.Clone({source: Settings.theme.led_front});
		
		// Public
		
		// Creates, arranges, and shows LEDDigits to fill the given width.
		this.set_width = function(wid)
		{
			width = wid;
			
			this.remove_all();
			digits = [];
			
			this.add_actor(back);
			//this.add_actor(front);
			
			for(var i = 0; i < width; i++)
			{
				digits[i] = new LEDDigit();
				digits[i].set_anchor_point(0, digits[i].height / 2);
				digits[i].x = (i * (digits[i].width + margin)) + inner_x_margin;
				digits[i].y = (back.height / 2) + inner_y_margin;
				this.add_actor(digits[i]);
			}
			
			back.lower_bottom();
			//this.raise_child(front, null);
		}
		
		// Set the value represented by the LEDView, and update its
		// child LEDDigits. Currently ignores digits past the width of the view.
		this.set_value = function(val)
		{
			var d_val = value = val;
			
			for(var i = width - 1; i >= 0; i--)
			{
				digits[i].set_value(Math.floor(d_val % 10));
				d_val /= 10;
			}
			
			// TODO: this is a /really/ bad place to do this...
			try
			{
				Settings.gconf_client.set_int("/apps/lightsoff/score", value);
			}
			catch(e)
			{
				Seed.print("Couldn't save score to GConf.");
			}
		}
		
		this.get_value = function()
		{
			return value;
		}
		
		// Implementation
		
		this.add_actor(back);
		//this.add_actor(front);
	}
});

