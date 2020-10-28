/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

private interface GameView : GLib.Object {

    internal enum ReplaceStyle {
        REFRESH, // crossfade
        SLIDE_FORWARD, // slide out-in
        SLIDE_BACKWARD, // slide in-out
        SLIDE_NEXT // slide over
    }

    internal abstract void replace_board (BoardView board_biew, BoardView new_board_view, ReplaceStyle style, bool fast = true);

    internal abstract bool hide_cursor ();
    internal abstract bool activate_cursor ();
    internal abstract bool move_cursor (int x, int y);
    internal abstract void reset_game ();
    internal abstract BoardView get_board_view ();
    internal abstract bool is_transitioning ();
    internal abstract int next_level (int direction);
    internal abstract BoardView create_board_view (int level);

    // The player asked to swap to a different level without completing
    // the one in progress; this can occur either by clicking an arrow
    // or by requesting a new game from the menu. Animate the new board
    // in, depthwise, in the direction indicated by 'context'.
    internal void swap_board (int direction)
    {
        if (is_transitioning ())
            return;

        replace_board (get_board_view (), create_board_view (next_level (direction)),
                       direction == 1 ? GameView.ReplaceStyle.SLIDE_FORWARD
                                      : GameView.ReplaceStyle.SLIDE_BACKWARD);
    }

    // The player won the game; create a new board, update the level count,
    // and transition between the two boards in a random direction.
    internal void game_won_cb ()
    {
        if (is_transitioning ())
            return;

        replace_board (get_board_view (), create_board_view (next_level (1)), GameView.ReplaceStyle.SLIDE_NEXT);
    }

    internal void light_toggled_cb ()
    {
        moves_changed (get_board_view ().get_moves ());
    }

    internal signal void level_changed (int level);
    internal signal void moves_changed (int moves);
}
