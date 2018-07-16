/*
 * Copyright (C) 2018 Robert Roth
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */
public interface GameView : GLib.Object {

    public enum ReplaceStyle {
        REFRESH, // crossfade
        SLIDE_FORWARD, // slide out-in
        SLIDE_BACKWARD, // slide in-out
        SLIDE_NEXT // slide over
    }

    public abstract void swap_board (int direction);

    public abstract BoardView replace_board (BoardView board_biew, BoardView new_board_view, ReplaceStyle style, bool fast = true);

    public abstract bool hide_cursor ();
    public abstract bool activate_cursor ();
    public abstract bool move_cursor (int x, int y);
    public abstract void reset_game ();

    public signal void level_changed (int level);
    public signal void moves_changed (int moves);

}
