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
    if not app:isFrontmost() then
      return app:activate()
    else
      return app:hide()
    end
  end
end

hs.hotkey.bind({"alt"}, "`", activateOrHide('com.apple.finder'))
hs.hotkey.bind({"alt"}, "D", activateOrHide('com.apple.Dictionary'))
hs.hotkey.bind({"alt"}, "E", activateOrHide('com.microsoft.edgemac'))
hs.hotkey.bind({"alt"}, "F", activateOrHide('com.googlecode.iterm2'))
hs.hotkey.bind({"alt"}, "G", activateOrHide('com.github.GitHubClient')) -- com.google.Chrome'))
-- hs.hotkey.bind({"alt"}, "M", activateOrHide('com.google.Chrome.app.kmhopmchchfpfdcdjodmpfaaphdclmlj'))
-- hs.hotkey.bind({"alt"}, "N", activateOrHide('com.microsoft.onenote.mac'))
hs.hotkey.bind({"alt"}, "O", activateOrHide('com.microsoft.edgemac.app.faolnafnngnfdaknnbpnkhgohbobgegn'))
hs.hotkey.bind({"alt"}, "P", activateOrHide('com.apple.Preview'))
hs.hotkey.bind({"alt"}, "R", activateOrHide('com.microsoft.rdc.osx.beta'))
hs.hotkey.bind({"alt"}, "T", activateOrHide('com.microsoft.teams'))
-- hs.hotkey.bind({"alt", "shift"}, "T", activateOrHide('ru.keepcoder.Telegram'))
-- hs.hotkey.bind({"alt"}, "Y", activateOrHide('abnerworks.Typora'))
hs.hotkey.bind({"alt"}, "V", activateOrHide('com.microsoft.VSCode'))
-- hs.hotkey.bind({"alt"}, "W", activateOrHide('com.tencent.xinWeChat'))
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

-- WinWin Start --
-- local winwin = hs.loadSpoon('WinWin')
-- hs.hotkey.bind({"alt", "ctrl"}, "left", function() winwin:moveAndResize('halfleft') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "right", function() winwin:moveAndResize('halfright') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "up", function() winwin:moveAndResize('halfup') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "down", function() winwin:moveAndResize('halfdown') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "U", function() winwin:moveAndResize('cornerNW') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "M", function() winwin:moveAndResize('cornerSW') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "I", function() winwin:moveAndResize('cornerNE') end)
-- hs.hotkey.bind({"alt", "ctrl"}, ",", function() winwin:moveAndResize('cornerSE') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "C", function() winwin:moveAndResize('center') end)
-- hs.hotkey.bind({"alt", "ctrl"}, "enter", function() winwin:moveAndResize('maximize') end)
-- WinWin End --
