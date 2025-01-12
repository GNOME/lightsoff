/*
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

using Gtk;

private class GtkGameView : Widget, GameView
{
    private Stack stack;
    private BoardViewGtk board_view;
    private int current_level;
    private GLib.Queue<ulong> handlers = new GLib.Queue<ulong>();
    private int _moves = 0;

    internal void replace_board (BoardView old_board, BoardView new_board, GameView.ReplaceStyle style, bool fast = true)
    {
        ((BoardViewGtk)old_board).sensitive = false;

        stack.transition_duration = fast ? 500 : 1000;
        switch (style)
        {
            case RESTART:
                stack.transition_type = StackTransitionType.SLIDE_DOWN;
                break;
            case REFRESH:
                stack.transition_type = StackTransitionType.CROSSFADE;
                break;
            case SLIDE_NEXT:
            case SLIDE_FORWARD:
                stack.transition_type = StackTransitionType.SLIDE_LEFT;
                break;
            case SLIDE_BACKWARD:
                stack.transition_type = StackTransitionType.SLIDE_RIGHT;
                break;
            default:
                assert_not_reached ();
        }

        stack.add_child ((Widget)new_board);
        stack.set_visible_child ((Widget)new_board);
        if (Gtk.Settings.get_for_display (((Widget)new_board).get_display ()).gtk_enable_animations)
            handlers.push_tail(notify["transition-running"].connect(() => board_replaced ((BoardViewGtk)old_board, (BoardViewGtk)new_board)));
        else
            board_replaced ((BoardViewGtk)old_board, (BoardViewGtk)new_board);
        level_changed (current_level);
    }

    internal void board_replaced (BoardViewGtk old_board, BoardViewGtk new_board)
    {
        stack.remove (old_board);
        new_board.sensitive = true;
        board_view = new_board;
        if (!handlers.is_empty ())
            disconnect (handlers.pop_head());
        moves_changed (0);
    }

    internal bool hide_cursor ()
    {
        queue_draw ();
        return false;
    }
    internal bool activate_cursor ()
    {
        return false;
    }
    internal bool move_cursor (int x, int y)
    {
        return false;
    }

    internal void reset_game ()
    {
        if (is_transitioning ())
            return;

        replace_board (get_board_view (), create_board_view (1), GameView.ReplaceStyle.RESTART);
    }

    construct
    {
        BinLayout layout = new BinLayout ();
        set_layout_manager (layout);

        stack = new Stack ();
        stack.insert_after (this, /* insert first */ null);
    }

    internal GtkGameView (int level)
    {
        board_view = (BoardViewGtk)create_board_view (level);
        board_view.sensitive = true;
        stack.add_child (board_view);
    }

    internal BoardView create_board_view (int level)
    {
        current_level = level;

        var view = new BoardViewGtk ();
        view.load_level (level);
        view.game_won.connect (game_won_cb);
        view.light_toggled.connect (light_toggled_cb);
        view.sensitive = true;
        _moves = 0;
        return (BoardView)view;
    }

    internal void light_toggled_cb ()
    {
        _moves += 1;
        moves_changed (_moves);
    }

    internal BoardView get_board_view ()
    {
        return (BoardView)board_view;
    }

    internal int next_level (int direction)
    {
        current_level += direction;
        return current_level;
    }

    internal bool is_transitioning ()
    {
        return stack.transition_running;
    }

}
