/*
 * Copyright (C) 2010-2013 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

// Puzzle generation logic:
// We want to measure a puzzle's difficulty by the number of button presses
// needed to solve it, and have that increase in a controlled manner.
//
// Lights Off can be seen as a linear algebra problem over the field GF(2).
// (See e.g. the first page of "Turning Lights Out with Linear Algebra".)
// The linear map from button-press strategies to light configurations
// will in general have a nullspace (of dimension n).
// Thus, any solvable puzzle has 2^n solutions, given by a fixed solution
// plus an element of the nullspace.
// A solution is thus optimal if it presses at most half the buttons
// which make up any element of the nullspace.
//
// A basis for the nullspace splits the board into (up to) 2^n regions,
// defined by which basic nullspace elements include a given button.
// (This determines which nullspace elements include the same button.)
// Thus, a solution is optimal if it includes at most half the buttons in any
// region (except the region lying outside all null-sets).
// The converse is not true, but (at least if the regions are even-sized)
// does hold for a large number of puzzles up to the highest difficulty level.
// (Certainly, on average, at most half the lights which belong to at least
// one null set may be used.)

private class PuzzleGenerator : Object
{
    private int size;
    private int max_solution_length;
    private int[] region_of;
    private int[] region_size;

    internal PuzzleGenerator (int size)
    {
        this.size = size;
        var adj_matrix = new int[size * size, size * size];
        for (var x0 = 0; x0 < size; x0++)
        {
            for (var y0 = 0; y0 < size; y0++)
            {
                for (var x1 = 0; x1 < size; x1++)
                {
                    for (var y1 = 0; y1 < size; y1++)
                    {
                        var dx = x0 - x1;
                        var dy = y0 - y1;
                        adj_matrix[x0 * size + y0, x1 * size + y1] = dx*dx + dy*dy <= 1 ? 1 : 0;
                    }
                }
            }
        }

        // Row-reduction over field with two elements
        List<int> non_pivot_cols = new List<int> ();
        var ipiv = 0;
        for (var jpiv = 0; jpiv < size * size; jpiv++)
        {
            var is_pivot_col = false;
            for (var i = ipiv; i < size * size; i++)
            {
                if (adj_matrix[i, jpiv] != 0)
                {
                    /* Swap rows */
                    if (i != ipiv)
                    {
                        for (var z = 0; z < size * size; z++)
                        {
                            var t = adj_matrix[i, z];
                            adj_matrix[i, z] = adj_matrix[ipiv, z];
                            adj_matrix[ipiv, z] = t;
                        }
                    }

                    for (var j = ipiv+1; j < size * size; j++)
                    {
                        if (adj_matrix[j, jpiv] != 0)
                        {
                            for (var k = 0; k < size * size; k++)
                                adj_matrix[j, k] ^= adj_matrix[ipiv, k];
                        }
                    }
                    is_pivot_col = true;
                    ipiv++;
                    break;
                }
            }

            if (!is_pivot_col)
                non_pivot_cols.append (jpiv);
        }

        // Use back-substitution to solve Adj*x = 0, once with each
        // free variable set to 1 (and the others to 0).
        var basis_for_ns = new int[non_pivot_cols.length (), size * size];
        var n = 0;
        foreach (var col in non_pivot_cols)
        {
            for (var j = 0; j < size * size; j++)
                basis_for_ns[n, j] = 0;
            basis_for_ns[n, col] = 1;

            for (var i = size * size - 1; i >= 0; i--)
            {
                var jpiv = 0;
                for (; jpiv < size * size; jpiv++)
                    if (adj_matrix[i, jpiv] != 0)
                        break;
                if (jpiv == size * size)
                    continue;
                for (var j = jpiv + 1; j < size * size; j++)
                    basis_for_ns[n, jpiv] ^= adj_matrix[i, j] * basis_for_ns[n, j];
            }

            n++;
        }

        // A button's region # is a binary # with 1's in a place corresponding
        // to any null-vector which contains it.
        region_size = new int [1 << non_pivot_cols.length ()];
        for (var j = 0; j < region_size.length; j++)
            region_size[j] = 0;
        region_of = new int[size * size];
        for (var i = 0; i < size * size; i++)
        {
            region_of[i] = 0;
            for (var j = 0; j < non_pivot_cols.length (); j++)
            {
                if (basis_for_ns[j, i] != 0)
                    region_of[i] += 1 << j;
            }
            region_size[region_of[i]]++;
        }

        max_solution_length = region_size[0];
        for (var j = 1; j < region_size.length; j++)
            max_solution_length += (int) Math.floor (region_size[j] / 2);
    }

    internal bool[,] minimal_solution (int solution_length)
    {
        var sol = new bool[size, size];
        for (var x = 0; x < size; x++)
            for (var y = 0; y < size; y++)
                sol[x, y] = false;

        var presses_in_region = new int[region_size.length];
        for (var i = 0; i < region_size.length; i++)
            presses_in_region[i] = 0;

        /* Note this should be Random.int_range (0, 3) but it is like this to match the old behaviour */
        var sym = (int) Math.floor (3 * Random.next_double ());

        var presses_left = int.min (solution_length, max_solution_length);
        while (presses_left > 0)
        {
            int x[2], y[2];

            // Pick a spot (x[0], y[0]), a corner if one is needed
            /* Note this should be Random.int_range (0, size) but it is like this to match the old behaviour */
            x[0] = (int) Math.round ((size - 1) * Random.next_double ());
            y[0] = (int) Math.round ((size - 1) * Random.next_double ());

            // Also pick a symmetric spot, to take if possible
            if (sym == 0)
            {
                x[1] = size - 1 - x[0];
                y[1] = y[0];
            }
            else if (sym == 1)
            {
                x[1] = size - 1 - x[0];
                y[1] = size - 1 - y[0];
            }
            else
            {
                x[1] = x[0];
                y[1] = size - 1 - y[0];
            }

            // Make each move if it doesn't fill a region more than halfway.
            for (var k = 0; k < 2; k++)
            {
                var r = region_of[x[k] * size + y[k]];
                if (r == 0 || 2 * (presses_in_region[r] + 1) <= region_size[r])
                {
                    if (sol[x[k], y[k]])
                        continue;
                    sol[x[k], y[k]] = true;
                    presses_in_region[r]++;
                    presses_left--;
                }
                if (presses_left == 0)
                    break;
            }
        }

        return sol;
    }
}
