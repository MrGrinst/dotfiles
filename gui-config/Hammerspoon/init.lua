local hotkey = require "hs.hotkey"
local keycodes = require "hs.keycodes"
local alert = require "hs.alert"

function reloadConfig(files)
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            return
        end
    end
end

function init()
    -- If we hook up a keyboard, rebind.
    keycodes.inputSourceChanged(rebindHotkeys)
    -- Automatically reload config when it changes.
    hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

    alert.show("Reloaded.", 1)

    delay = hs.eventtap.keyRepeatDelay()
    keyPress = function(direction)
        return function()
            hs.eventtap.keyStroke({}, direction, delay)
        end
    end
    hs.hotkey.bind({"cmd"}, "j", keyPress("down"), nil, keyPress("down"))
    hs.hotkey.bind({"cmd"}, "h", keyPress("left"), nil, keyPress("left"))
    hs.hotkey.bind({"cmd"}, "k", keyPress("up"), nil, keyPress("up"))
    hs.hotkey.bind({"cmd"}, "l", keyPress("right"), nil, keyPress("right"))

    hs.hotkey.bind({"cmd"}, "i", function()
        hs.eventtap.keyStroke({"cmd", "alt"}, "left", delay)
    end, nil, function()
        hs.eventtap.keyStroke({"cmd", "alt"}, "left", delay)
    end)
    hs.hotkey.bind({"cmd"}, "o", function()
        hs.eventtap.keyStroke({"cmd", "alt"}, "right", delay)
    end, nil, function()
        hs.eventtap.keyStroke({"cmd", "alt"}, "right", delay)
    end)

    hs.hotkey.bind({"alt"}, "h", function()
        hs.eventtap.keyStroke({"alt"}, "left", delay)
    end, nil, function()
        hs.eventtap.keyStroke({"alt"}, "left", delay)
    end)
    hs.hotkey.bind({"alt"}, "l", function()
        hs.eventtap.keyStroke({"alt"}, "right", delay)
    end, nil, function()
        hs.eventtap.keyStroke({"alt"}, "right", delay)
    end)

    focusChromeAddressBar = hs.hotkey.new({"cmd", "shift"}, "l", function()
        app = hs.application.find("Google Chrome")
        app:selectMenuItem("Open Location...")
    end)

    hs.window.filter.new("Google Chrome")
    :subscribe(hs.window.filter.windowFocused,function() focusChromeAddressBar:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() focusChromeAddressBar:disable() end)

    hs.hotkey.bind({"cmd"}, "g", function()
        hs.application.frontmostApplication():hide()
    end)
end

init()
