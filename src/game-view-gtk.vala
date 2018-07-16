public class GtkGameView : Gtk.Stack, GameView {

    private BoardViewGtk board_view;
    private int current_level;
    private GLib.Queue<ulong> handlers = new GLib.Queue<ulong>();

    public void replace_board (BoardView old_board, BoardView new_board, GameView.ReplaceStyle style, bool fast = true)
    {
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

        board_view = create_board_view (current_level) as BoardViewGtk;
        board_view.playable = true;
        add (board_view);
    }

    public BoardView create_board_view (int level)
    {
        var view = new BoardViewGtk ();
        view.load_level (level);
        view.game_won.connect (() => GLib.Timeout.add (300, game_won_cb));
        view.light_toggled.connect (light_toggled_cb);
        view.playable = false;
        view.show_all ();
        return view;
    }

    public BoardView get_board_view ()
    {
        return board_view;
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