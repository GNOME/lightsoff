/*
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Gtk;

public class GtkGameView : Stack, GameView {

    private BoardViewGtk board_view;
    private int current_level;
    private GLib.Queue<ulong> handlers = new GLib.Queue<ulong>();

    public void replace_board (BoardView old_board, BoardView new_board, GameView.ReplaceStyle style, bool fast = true)
    {
        transition_duration = fast ? 500 : 1000;
        switch (style)
        {
            case REFRESH:
                transition_type = StackTransitionType.SLIDE_DOWN;
                break;
            case SLIDE_NEXT:
            case SLIDE_FORWARD:
                transition_type = StackTransitionType.SLIDE_LEFT;
                break;
            case SLIDE_BACKWARD:
                transition_type = StackTransitionType.SLIDE_RIGHT;
                break;
        }

        var new_level = "level %d".printf(current_level);
        add_named ((Widget)new_board, new_level);
        set_visible_child ((Widget)new_board);
        ((BoardViewGtk)old_board).playable = false;
        if (Gtk.Settings.get_for_screen (((Widget)new_board).get_screen ()).gtk_enable_animations)
            handlers.push_tail(notify["transition-running"].connect(() => board_replaced ((BoardViewGtk)old_board, (BoardViewGtk)new_board)));
        else
            board_replaced ((BoardViewGtk)old_board, (BoardViewGtk)new_board);
        level_changed (current_level);
    }

    public void board_replaced (BoardViewGtk old_board, BoardViewGtk new_board)
    {
        @foreach((board) => { if (board != get_visible_child ()) remove(board);});
        new_board.playable = true;
        board_view = new_board;
        if (!handlers.is_empty ())
            disconnect(handlers.pop_head());
    }

    public bool hide_cursor ()
    {
        queue_draw ();
        return false;
    }
    public bool activate_cursor ()
    {
        return false;
    }
    public bool move_cursor (int x, int y)
    {
        return false;
    }

    public void reset_game ()
    {
        if (is_transitioning())
            return;

        replace_board (get_board_view (), create_board_view (1), GameView.ReplaceStyle.REFRESH);
    }

    public GtkGameView (int level)
    {
        board_view = (BoardViewGtk)create_board_view (level);
        board_view.playable = true;
        add (board_view);
    }

    public BoardView create_board_view (int level)
    {
        current_level = level;

        var view = new BoardViewGtk ();
        view.load_level (level);
        view.game_won.connect (() => game_won_cb());
        view.light_toggled.connect (light_toggled_cb);
        view.playable = false;
        return (BoardView)view;
    }

   public BoardView get_board_view ()
    {
        return (BoardView)board_view;
    }

    public int next_level (int direction) {
        current_level += direction;
        return current_level;
    }

    public bool is_transitioning ()
    {
        return transition_running;
    }

}
