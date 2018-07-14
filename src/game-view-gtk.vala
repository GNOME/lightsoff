public class GtkGameView : Gtk.Frame, GameView {

    private BoardViewGtk board_view;
    private BoardViewGtk? new_board_view = null;
    private int current_level;

    public void swap_board (int direction)
    {
        current_level += direction;
        new_board_view = create_board_view (current_level);
        replace_board (board_view, new_board_view);
        board_view = new_board_view;
        level_changed (current_level);
    }

    public void replace_board (BoardView old_board, BoardView new_board)
    {
        remove (old_board as Gtk.Widget);
        add (new_board as Gtk.Widget);
    }

    public void hide_cursor ()
    {
    }
    public void activate_cursor ()
    {
    }
    public void move_cursor (int x, int y)
    {
    }
    public void reset_game ()
    {
        current_level = 1;
        new_board_view = create_board_view (current_level);
        replace_board (board_view, new_board_view);
        board_view = new_board_view;
        level_changed (current_level);
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
        view.game_won.connect (game_won_cb);
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
    private void game_won_cb ()
    {
        current_level++;

        new_board_view = create_board_view (current_level);
        replace_board (board_view, new_board_view);
        board_view = new_board_view;
        level_changed (current_level);
    }

}
