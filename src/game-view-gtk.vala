public class GtkGameView : Gtk.Stack, GameView {

    private BoardViewGtk board_view;
    private int current_level;
    private GLib.Queue<ulong> handlers = new GLib.Queue<ulong>();
    public void swap_board (int direction)
    {
        current_level += direction;
        replace_board (board_view, create_board_view (current_level),
                       direction == 1 ? GameView.ReplaceStyle.SLIDE_FORWARD 
                                      : GameView.ReplaceStyle.SLIDE_BACKWARD);
    }

    public void replace_board (BoardView old_board, BoardView new_board, GameView.ReplaceStyle style, bool fast = true)
    {
        stdout.printf ("Changing board %p with board %p\n", old_board, new_board);
        transition_duration = fast ? 500 : 1000;
        switch (style)
        {
            case REFRESH:
                transition_type = Gtk.StackTransitionType.SLIDE_DOWN;
                break;
            case SLIDE_NEXT:
            case SLIDE_FORWARD:
                transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
                break;
            case SLIDE_BACKWARD:
                transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                break;
        }

        var new_level = "level %d".printf(current_level);
        add_named (new_board as Gtk.Widget, new_level);
        set_visible_child (new_board as Gtk.Widget);
        handlers.push_tail(notify["transition-running"].connect(() => board_replaced (old_board as BoardViewGtk, new_board as BoardViewGtk)));
        level_changed (current_level);
    }

    public void board_replaced (BoardViewGtk old_board, BoardViewGtk new_board)
    {
        stdout.printf ("Cleaning board %p, replacing with  %p\n", old_board, new_board);
        @foreach((board) => { if (board != get_visible_child ()) remove(board);});
        board_view = new_board;
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
        current_level = 1;
        replace_board (board_view, create_board_view (current_level), GameView.ReplaceStyle.REFRESH);
    }

    public GtkGameView (int level)
    {
                /* Clear level */
        current_level = level;

        board_view = create_board_view (current_level);
        board_view.playable = true;
        add (board_view);
    }

    private BoardViewGtk create_board_view (int level)
    {
        var view = new BoardViewGtk ();
        view.load_level (level);
        view.game_won.connect (() => GLib.Timeout.add (300, game_won_cb));
        view.light_toggled.connect (light_toggled_cb);
        view.playable = false;
        view.show_all ();
        return view;
    }

    private void light_toggled_cb ()
    {
        moves_changed (board_view.moves);
    }

// The player won the game; create a new board, update the level count,
    // and transition between the two boards in a random direction.
    private bool game_won_cb ()
    {
        replace_board (board_view, create_board_view (++current_level), GameView.ReplaceStyle.SLIDE_NEXT, false);
        return false;
    }

}