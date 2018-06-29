public interface GameView : GLib.Object {
    public abstract void swap_board (int direction);
    public abstract void hide_cursor ();
    public abstract void activate_cursor ();
    public abstract void move_cursor (int x, int y);
    public abstract void reset_game ();

    public signal void level_changed (int level);
    public signal void moves_changed (int moves);

}
