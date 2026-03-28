# Librariesforward
import os
import subprocess

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal


@hook.subscribe.startup_complete
def run_every_startup():
    home = os.path.expanduser(
        "~/.config/qtile/autostart.sh"
    )  # path to my script, under my user directory
    subprocess.call([home])


def move_to_next_screen(qtile):
    if qtile.current_screen.index in [0, 1]:
        other = 1 - qtile.current_screen.index
        qtile.current_window.toscreen(other)
        qtile.to_screen(other)


# Mod button
mod = "mod4"

# Terminal
terminal = "alacritty"


keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key(
        [mod, "shift"],
        "n",
        lazy.function(move_to_next_screen),
        desc="Move window to next screen",
    ),
    # Grow windows
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    # Switch focus
    #   Key([mod], "n", lazy.next_screen(), desc="Focus to next screen"),
    Key(
        [mod],
        "n",
        lazy.function(
            lambda qtile: (
                qtile.cmd_to_screen(1 - qtile.current_screen.index)
                if qtile.current_screen.index in [0, 1]
                else None
            )
        ),
        desc="Focus between screen 1 and 2",
    ),
    # Layouts splitting\unsplitting
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between layouts
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    # Window Kill, fullscreen,
    Key([mod, "shift"], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    # Qtile shutdown and config reload
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift", "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Sound
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ),
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ),
    # Others
    Key(
        [mod],
        "r",
        lazy.spawn("/usr/bin/dmenu_run"),
        desc="Spawn a command using a prompt widget",
    ),
    Key([mod], "b", lazy.spawn("firefox"), desc="Spawn a firefox"),
    Key([mod], "v", lazy.spawn("copyq menu"), desc="Spawn copyq"),
    Key([mod], "d", lazy.spawn("thunar"), desc="Spawn the Files"),
    Key(["control", "shift"], "l", lazy.spawn("betterlockscreen -l")),
    Key(
        [],
        "Print",
        lazy.spawn("flameshot gui"),
        desc="Spawn Flameshot",
    ),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # mod1 + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


### Functions ###
# Volume_click
def open_pavucontrol():
    qtile.cmd_spawn("pavucontrol")


screens = [
    Screen(
        wallpaper="~/.config/qtile/dark_forest.jpg",
        wallpaper_mode="stretch",
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                #                widget.Chord(
                #                   chords_colors={
                #                      "launch": ("#ff0000", "#ffffff"),
                #                 },
                #                name_transform=lambda name: name.upper(),
                #           ),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),
                widget.Systray(),
                widget.Volume(
                    fmt="Vol: {}", mouse_callbacks={"Button1": open_pavucontrol}
                ),
                widget.GenPollText(
                    func=lambda: subprocess.check_output(
                        ["xkblayout-state", "print", "%s"]
                    )
                    .decode()
                    .strip(),
                    update_interval=0.2,
                ),
                widget.Clock(format="%d-%m %a  %I:%M %p"),
                widget.QuickExit(),
            ],
            24,
            background="#003635",  # Set the background color
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
    Screen(
        wallpaper="~/.config/qtile/dark_forest.jpg",
        wallpaper_mode="stretch",
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                #                widget.Chord(
                #                   chords_colors={
                #                      "launch": ("#ff0000", "#ffffff"),
                #                 },
                #                name_transform=lambda name: name.upper(),
                #           ),
                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),
                widget.Volume(
                    fmt="Vol: {}", mouse_callbacks={"Button1": open_pavucontrol}
                ),
                widget.GenPollText(
                    func=lambda: subprocess.check_output(
                        ["xkblayout-state", "print", "%s"]
                    )
                    .decode()
                    .strip(),
                    update_interval=0.2,
                ),
                widget.Clock(format="%d-%m %a  %I:%M %p"),
                widget.QuickExit(),
            ],
            24,
            background="#003635",  # Set the background color
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="Pavucontrol"),
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
