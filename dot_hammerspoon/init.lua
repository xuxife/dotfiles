-- Common Config --
hs.alert.show("Config loaded")
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
-- Common Config End --

-- Application Start --
local function activateOrHide(bundleID)
  return function()
    local app = hs.application.get(bundleID)
    if not app then -- app hasn't yet running
      return hs.application.open(bundleID)
    end
    -- if hs.window.focusedWindow():application():bundleID() == bundleID then
    if app:isFrontmost() then
      -- hs.alert.show("hide")
      app:hide()
    else
      -- hs.alert.show("activate")
      app:activate()
    end
  end
end

hs.hotkey.bind({"alt"}, "`", activateOrHide('com.apple.finder'))
hs.hotkey.bind({"alt"}, "A", activateOrHide('ru.keepcoder.Telegram'))
hs.hotkey.bind({"alt"}, "C", activateOrHide('com.apple.iCal'))
hs.hotkey.bind({"alt"}, "D", activateOrHide('com.google.Chrome'))
hs.hotkey.bind({"alt", "shift"}, "D", activateOrHide('com.apple.Dictionary'))
hs.hotkey.bind({"alt"}, "E", activateOrHide('com.microsoft.edgemac'))
hs.hotkey.bind({"alt"}, "F", activateOrHide('com.googlecode.iterm2'))
-- hs.hotkey.bind({"alt"}, "G", activateOrHide(''))
-- hs.hotkey.bind({"alt"}, "I", activateOrHide('com.colliderli.iina'))
-- hs.hotkey.bind({"alt"}, "M", activateOrHide('com.google.Chrome.app.cinhimbnkkaeohfgghhklpknlkffjgod')) -- 'com.tomito.tomito'))
hs.hotkey.bind({"alt"}, "M", activateOrHide('com.apple.MobileSMS'))
hs.hotkey.bind({"alt"}, "N", activateOrHide('com.apple.Notes'))
hs.hotkey.bind({"alt", "shift"}, "N", activateOrHide('com.microsoft.onenote.mac'))
hs.hotkey.bind({"alt"}, "O", activateOrHide('com.microsoft.Outlook'))
hs.hotkey.bind({"alt"}, "P", activateOrHide('com.apple.Preview'))
hs.hotkey.bind({"alt"}, "R", activateOrHide('com.apple.reminders'))
hs.hotkey.bind({"alt", "shift"}, "R", activateOrHide('com.microsoft.rdc.osx.beta'))
hs.hotkey.bind({"alt"}, "T", activateOrHide('com.microsoft.teams'))
hs.hotkey.bind({"alt"}, "Y", activateOrHide('abnerworks.Typora'))
hs.hotkey.bind({"alt"}, "V", activateOrHide('com.microsoft.VSCode'))
hs.hotkey.bind({"alt"}, "W", activateOrHide('com.tencent.xinWeChat'))
-- hs.hotkey.bind({"alt"}, "X", activateOrHide('com.apple.dt.Xcode'))
-- Application End --

-- Keystroke Start --
-- Keystroke End --

-- VimMode Start --
local VimMode = hs.loadSpoon('VimMode')
local vim = VimMode:new()

vim
  :bindHotKeys({ enter = {{'ctrl'}, ';'} })
  :shouldShowAlertInNormalMode(true)
  :shouldDimScreenInNormalMode(false)
-- VimMode End --
