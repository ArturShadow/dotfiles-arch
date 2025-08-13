package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/awesome/modules/?.lua"
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Enable hotkeys help widget for VIM and other apps
require("awful.hotkeys_popup.keys")
require("modules.menu")
require("modules.keybindings")

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, errors during startup!", text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err) })
        in_error = false
    end)
end

-- Themes
beautiful.init("/home/kurobon/.config/awesome/default/theme.lua")

-- Layouts
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw
}

-- Widgets
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock("%A %d %B %Y")

-- Battery widget con acpi
local battery_text = wibox.widget.textbox()
awful.widget.watch("acpi -b", 30,
    function(widget, stdout)
        local perc = tonumber(stdout:match("(%d?%d?%d)%%"))
        local status = stdout:match("(%a+),") or ""
        local icon = "🔋"
        if perc then
            if perc < 20 then icon = ""
            elseif perc < 40 then icon = ""
            elseif perc < 60 then icon = ""
            elseif perc < 80 then icon = ""
            else icon = ""
            end
            widget:set_text(string.format(" %s %d%% %s ", icon, perc, status))
        else
            widget:set_text(" 🔌 N/A ")
        end
    end,
battery_text)

-- Wibar
awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Promptbox
    s.mypromptbox = awful.widget.prompt()
    -- Taglist
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
    }
    -- Tasklist
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
    }

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end)
    ))

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left
        layout = wibox.layout.fixed.horizontal,
        mylauncher,
        wibox.container.margin(s.mytaglist, 6, 6, 0, 0),
        s.mypromptbox,
    },
     wibox.widget.textbox(), -- Middle (espacio vacío)
    { -- Right
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(mykeyboardlayout, 8, 8, 0, 0),
        wibox.container.margin(wibox.widget.systray(), 8, 8, 0, 0),
        wibox.container.margin(battery_text, 8, 8, 0, 0),
        wibox.container.margin(mytextclock, 8, 8, 0, 0),
        wibox.container.margin(s.mylayoutbox, 8, 8, 0, 0),
    },
}

end)
-- Autorun para lanzar programas al iniciar AwesomeWM
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

