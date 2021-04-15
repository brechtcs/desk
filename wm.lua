local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"
local naughty = require "naughty"

-- Handle errors
if awesome.startup_errors then
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    }
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify {
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        }
        in_error = false
    end)
end

-- Initialize theme
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Create global variables 
modkey = "Mod4"

-- Set available layouts
awful.layout.layouts = {
    awful.layout.suit.max.fullscreen
}

-- Load wallpaper
screen.connect_signal("request::wallpaper", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

-- Create screen tag table
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1" }, s, awful.layout.layouts[1])
end)

-- Handle focus after closing window
client.connect_signal("unmanage", function() 
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c == nil then return end
    awful.client.focus.byidx(0, c)
end)

-- Check internet connection
local ok = os.execute('curl --silent http://example.com &> /dev/null')
local preset = ok and "low" or "critical"
local notify_net = naughty.notify {
    title = 'Checking internet...';
    text = ok and 'Connection established' or 'No connection established';
    preset = naughty.config.presets[preset];
}

gears.timer {
    timeout = ok and 1.5 or 15;
    callback = function() if notify_net then notify_net.die() end end;
    autostart = true;
    single_shot = true;
}

-- Periodically check battery level
local function readcapacity ()
    local battery = io.open('/sys/class/power_supply/BAT0/capacity')
    local capacity = battery:read('*line')
    battery:close()
    return capacity
end

local function readstatus ()
    local battery = io.open('/sys/class/power_supply/BAT0/status')
    local status = battery:read('*line')
    battery:close()
    return status
end

local function showbattery (force)
    local notify_battery 
    local capacity = readcapacity()
    local status = readstatus()
    local low = tonumber(capacity) < 15
    local preset = low and "critical" or "normal"
    if status == "Discharging" then preset = "critical" end

    if low or force == true then
        notify_battery = naughty.notify {
            preset = naughty.config.presets[preset];
            title = 'Battery ' .. status:lower();
            text = capacity .. '% remaining ';
        }

        gears.timer {
            timeout = 7;
            autostart = true;
            single_shot = true;
            callback = function()
                if notify_battery then notify_battery.die() end
            end
        }
    end
end

gears.timer {
    timeout = 60;
    callback = showbattery;
    autostart = true;
    single_shot = false;
    call_now = true;
}

-- Setup global keybindings
root.keys(gears.table.join(
    awful.key({ modkey }, "r", awesome.restart),
    awful.key({ modkey }, "q", awesome.quit),
    awful.key({ modkey }, "Return", function() awful.spawn("terminator") end),
    awful.key({ modkey }, "BackSpace", function() client.focus:kill() end),
    awful.key({ modkey }, "Tab", function() awful.client.focus.byidx(1) end),
    awful.key({ modkey, 'Shift' }, "Tab", function() awful.client.focus.byidx(-1) end),
    awful.key({ modkey }, "b", function() showbattery(true) end),
    awful.key({ modkey }, "n", function()
        naughty.notify {
            preset = naughty.config.presets.normal;
            title = os.date('%X');
            text = os.date('%A, %B %d');
        }
    end)
))
