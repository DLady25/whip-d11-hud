-- The WHIP layer (whip/hud.css: rev dial hidden, round minimap; whip/status.css: WHIP's gauges hidden, voice as a
-- circle) goes into whip_core's page as a WHIP theme, but only when no other theme is active. With your own theme,
-- @import the files from it (README) and set D11Hud.WhipLayer = false. Stopping d11_hud puts WHIP's look back.
--
-- What happened is always said: one line in this console, and the same line in each player's F8 (client/layer.lua
-- reads GlobalState.d11_hud_layer), since that is where people look first.

local SELF = GetCurrentResourceName()
local IMPORT = ("@import url('https://cfx-nui-%s/whip/hud.css'); @import url('https://cfx-nui-%s/whip/status.css');")
    :format(SELF, SELF)

local function report(on, text)
    -- every public whip_core (1.0.0 on) draws its minimap in its own page (#minimap3d), which whip/hud.css rounds
    text = ('%s (whip_core %s)'):format(text, GetResourceMetadata('whip_core', 'version', 0) or '?')
    GlobalState.d11_hud_layer = { on = on, text = text, resource = SELF }
    print(('%s[d11_hud] %s^0'):format(on and '^2' or '^3', text))
end

if D11Hud.WhipLayer == false then
    report(false, ('WHIP layer off: WhipLayer = false in config.lua. Your WHIP theme must carry %s'):format(IMPORT))
    return
end

-- Inside Whip.register so it is set again after a whip_core restart.
Whip.register(function()
    local theme, owner = exports.whip_core:GetActiveTheme()
    if theme == SELF then
        report(true, 'WHIP layer on: d11_hud is already WHIP\'s active theme.')
        return
    end
    if theme == 'd11_theme' then
        report(true, 'WHIP layer on: through d11_theme, which imports whip/hud.css and whip/status.css.')
        return
    end
    if theme == 'whip_theme_d12' then
        report(false, ('WHIP layer: "whip_theme_d12" is the active WHIP theme; the copy in the old D11 Starter Kit does not round the minimap. Replace it with d11_theme (github.com/DLady25/whip-d11-theme), which carries the layer, or add %s to its theme.css right after its own @import lines.')
            :format(IMPORT))
        return
    end
    if theme ~= nil and theme ~= '' and theme ~= false then
        report(false, ('WHIP layer off: the WHIP theme "%s" is active (%s), so d11_hud cannot load its own. Add %s to that theme\'s theme.css, or WHIP\'s gauges and square minimap stay on screen.')
            :format(tostring(theme), owner and ('set by ' .. tostring(owner)) or 'Config.Theme', IMPORT))
        return
    end
    local ok, err = exports.whip_core:SetActiveTheme(SELF)
    if not ok then
        report(false, ('WHIP layer off: whip_core refused it (%s).'):format(tostring(err)))
        return
    end
    report(true, 'WHIP layer on: d11_hud set itself as WHIP\'s active theme (whip/hud.css, whip/status.css).')
end)

-- Sent again after login: whip_core sends the theme at login, but FiveM's NUI can serve the theme.css cached from the
-- last session; sending it again swaps the <link> and the page fetches it anew.
AddEventHandler('whip_core:player:loaded', function(data)
    local src = type(data) == 'table' and tonumber(data.source)
    if not src then return end
    SetTimeout(2000, function()
        if GetPlayerName(src) and exports.whip_core:GetActiveTheme() == SELF then
            TriggerClientEvent('whip_core:client:applyTheme', src, SELF)
        end
    end)
end)
