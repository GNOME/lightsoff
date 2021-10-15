/*
  This file is part of LightsOff

  LightsOff is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  LightsOff is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with LightsOff.  If not, see <https://www.gnu.org/licenses/>.
*/

using Gtk;

[GtkTemplate (ui = "/org/gnome/LightsOff/ui/notifications-revealer.ui")]
private class NotificationsRevealer : Widget
{
    [GtkChild]
    private unowned Revealer revealer;

    [GtkChild]
    private unowned Label notification_label;

    construct
    {
        BinLayout layout = new BinLayout ();
        set_layout_manager (layout);

        install_action_entries ();
    }

    /*\
    * * internal calls
    \*/

    internal void show_notification (string notification)
    {
        notification_label.set_text (notification);
        revealer.set_reveal_child (true);
    }

    private bool thin_window_size = false;
    internal void set_window_size (bool thin)
    {
        if (thin_window_size == thin)
            return;
        thin_window_size = thin;

        if (thin)
        {
            hexpand = true;
            halign = Align.FILL;
            get_style_context ().add_class ("thin-window");
        }
        else
        {
            hexpand = false;
            halign = Align.CENTER;
            get_style_context ().remove_class ("thin-window");
        }
    }

    /*\
    * * action entries
    \*/

    private void install_action_entries ()
    {
        SimpleActionGroup action_group = new SimpleActionGroup ();
        action_group.add_action_entries (action_entries, this);
        insert_action_group ("notification", action_group);
    }

    private const GLib.ActionEntry [] action_entries =
    {
        { "hide", hide_notification }
    };

    internal void hide_notification (/* SimpleAction action, Variant? variant */)
    {
        revealer.set_reveal_child (false);
    }
}
