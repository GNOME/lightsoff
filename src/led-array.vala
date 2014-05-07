/*
 * Copyright (C) 2010-2013 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public class LEDDigit : Clutter.CairoTexture
{
    private const int scale = 23;

    private int _value = 0;
    public int value
    {
        get { return _value; }
        set { _value = value; invalidate (); }
    }

    private const bool segment_states[] =
    {
         true,  true,  true,  true,  true, false,  true,
        false, false, false, false,  true, false,  true,
         true, false,  true,  true, false,  true,  true,
         true, false, false,  true,  true,  true,  true,
        false,  true, false, false,  true,  true,  true,
         true,  true, false,  true,  true,  true, false,
         true,  true,  true,  true,  true,  true, false,
         true, false, false, false,  true, false,  true,
         true,  true,  true,  true,  true,  true,  true,
         true,  true, false,  true,  true,  true,  true
    };

    public LEDDigit ()
    {
        set_surface_size (37, 65);
        invalidate ();
    }

    public override bool draw (Cairo.Context cr)
    {
        cr.set_operator (Cairo.Operator.CLEAR);
        cr.paint ();
        cr.set_operator (Cairo.Operator.OVER);

        var thickness = scale / 3;
        var pointy = thickness / 2;
        var margin = Math.floor (Math.log (scale));
        var side = pointy + margin;

        var offset = value * 7;
        draw_segment (cr, side,               0,                         false, segment_states[offset]);
        draw_segment (cr, 0,                  side,                      true,  segment_states[offset + 1]);
        draw_segment (cr, 0,                  side + scale + margin * 2, true,  segment_states[offset + 2]);
        draw_segment (cr, side,               2 * scale + 4 * margin,    false, segment_states[offset + 3]);
        draw_segment (cr, scale + 2 * margin, side + scale + margin * 2, true,  segment_states[offset + 4]);
        draw_segment (cr, side,               scale + 2 * margin,        false, segment_states[offset + 5]);
        draw_segment (cr, scale + 2 * margin, side,                      true,  segment_states[offset + 6]);

        return false;
    }

    private void draw_segment (Cairo.Context cr, double x, double y, bool is_vertical, bool is_lit)
    {
        if (is_lit)
            cr.set_source_rgba (0.145, 0.541, 1, 1);
        else
            cr.set_source_rgba (0.2, 0.2, 0.2, 1);

        cr.new_path ();

        var thickness = scale / 3;
        var pointy = thickness / 2;

        if (is_vertical)
        {
            cr.move_to (x + thickness / 2, y + 0);
            cr.line_to (x + 0, y + pointy);
            cr.line_to (x + 0, y + scale - pointy);
            cr.line_to (x + thickness / 2, y + scale);
            cr.line_to (x + thickness, y + scale - pointy);
            cr.line_to (x + thickness, y + pointy);
        }
        else
        {
            cr.move_to (x + 0, y + thickness / 2);
            cr.line_to (x + pointy, y + 0);
            cr.line_to (x + scale - pointy, y + 0);
            cr.line_to (x + scale, y + thickness / 2);
            cr.line_to (x + scale - pointy, y + thickness);
            cr.line_to (x + pointy, y + thickness);
        }

        cr.close_path ();
        cr.fill ();
    }
}

public class LEDArray : Clutter.Group
{
    private List<LEDDigit> digits = null;
    private Clutter.Actor back;

    private int _value = 0;
    public int value
    {
        get { return _value; }
        set
        {
            _value = value;
            var d_val = value;
            foreach (var d in digits)
            {
                d.value = (int) Math.floor (d_val % 10);
                d_val /= 10;
            }
        }
    }

    public LEDArray (int n_digits, Clutter.Actor back_texture)
    {
        var margin = 4;
        var inner_x_margin = 10;
        var inner_y_margin = -1;

        back = new Clutter.Clone (back_texture);
        add_child (back);

        for (var i = 0; i < n_digits; i++)
        {
            var d = new LEDDigit ();
            d.set_anchor_point (0, d.height / 2);
            d.x = i * (d.width + margin) + inner_x_margin;
            d.y = back.height / 2 + inner_y_margin;
            add_child (d);
            digits.prepend (d);
        }
    }
}
