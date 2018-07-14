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
    public abstract void swap_board (int direction);

    public abstract void replace_board (BoardView board_biew, BoardView new_board_view);

    public abstract void hide_cursor ();
    public abstract void activate_cursor ();
    public abstract void move_cursor (int x, int y);
    public abstract void reset_game ();

    public signal void level_changed (int level);
    public signal void moves_changed (int moves);

}
