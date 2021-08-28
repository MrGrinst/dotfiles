local hotkey = require "hs.hotkey"
local keycodes = require "hs.keycodes"
local alert = require "hs.alert"

function reloadConfig(files)
    hs.reload()
end

function init()
    -- If we hook up a keyboard, rebind.
    keycodes.inputSourceChanged(rebindHotkeys)
    -- Automatically reload config when it changes.
    hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/init.lua", reloadConfig):start()

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
    hs.hotkey.bind({"cmd", "shift"}, "n", hs.spotify.next)

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

    hs.hotkey.bind({"cmd"}, "g", function()
        hs.application.frontmostApplication():hide()
    end)

    focusChromeAddressBar = hs.hotkey.new({"cmd", "shift"}, "l", function()
        app = hs.application.find("Google Chrome")
        app:selectMenuItem("Open Location...")
    end)

    focusFirefoxAddressBar = hs.hotkey.bind({"cmd", "shift"}, "l", keyPress("F6"))

    moveTabLeftFirefox = hs.hotkey.new({"alt"}, "i", function()
        hs.eventtap.keyStroke({"ctrl", "shift"}, "PageUp", delay)
    end)

    moveTabRightFirefox = hs.hotkey.new({"alt"}, "o", function()
        hs.eventtap.keyStroke({"ctrl", "shift"}, "PageDown", delay)
    end)

    hs.window.filter.new("Google Chrome")
    :subscribe(hs.window.filter.windowFocused,function() focusChromeAddressBar:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() focusChromeAddressBar:disable() end)

    hs.window.filter.new("Firefox")
    :subscribe(hs.window.filter.windowFocused,function() moveTabLeftFirefox:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() moveTabLeftFirefox:disable() end)
    :subscribe(hs.window.filter.windowFocused,function() moveTabRightFirefox:enable() end)
    :subscribe(hs.window.filter.windowUnfocused,function() moveTabRightFirefox:disable() end)
end

init()
