-- The WHIP layer (whip/hud.css: rev dial hidden, round minimap; whip/status.css: WHIP's gauges hidden, voice as a
-- circle) goes into whip_core's page as a WHIP theme, but only when no other theme is active. With your own theme,
-- @import the files from it (README) and set D11Hud.WhipLayer = false. Stopping d11_hud puts WHIP's look back.
--
-- What happened is always said: one line in this console, and the same line in each player's F8 (client/layer.lua
-- reads GlobalState.d11_hud_layer), since that is where people look first.

local SELF = GetCurrentResourceName()
local IMPORT = ("@import url('https://cfx-nui-%s/whip/hud.css'); @import url('https://cfx-nui-%s/whip/status.css');")
    :format(SELF, SELF)

--- theme: the WHIP theme that carries the layer (d11_hud itself or d11_theme); the client hands whip_core's page that
--- one again if it missed it, never d11_hud over another theme.
local function report(on, text, theme)
    -- every public whip_core (1.0.0 on) draws its minimap in its own page (#minimap3d), which whip/hud.css rounds
    text = ('%s (whip_core %s)'):format(text, GetResourceMetadata('whip_core', 'version', 0) or '?')
    GlobalState.d11_hud_layer = { on = on, text = text, resource = SELF, theme = on and (theme or SELF) or nil }
    print(('%s[d11_hud] %s^0'):format(on and '^2' or '^3', text))
end

-- The layer itself: hud.css, and status.css unless D11Hud.Status = false (WHIP's own gauges stay then).
local function layerCss()
    local out = { "/* d11_hud's layer inside WHIP's page. Written by d11_hud when it starts, emptied when it stops: do not edit. */" }
    out[#out + 1] = LoadResourceFile(SELF, 'whip/hud.css') or ''
    if D11Hud.Status ~= false then out[#out + 1] = LoadResourceFile(SELF, 'whip/status.css') or '' end
    return table.concat(out, '\n')
end
exports('WhipLayerCss', layerCss)   -- d11_theme 1.1.0+ asks for it and keeps it in its own css/d11_hud.css

-- d11_hud as its own WHIP theme (theme.css): whip/status-layer.css follows D11Hud.Status, no line to delete.
SaveResourceFile(SELF, 'whip/status-layer.css', D11Hud.Status ~= false and (LoadResourceFile(SELF, 'whip/status.css') or '')
    or '/* D11Hud.Status = false: WHIP\'s own status gauges stay. */\n', -1)

-- d11_theme 1.1.0+ imports its own css/d11_hud.css, written from WhipLayerCss as it starts (FiveM hands players a
-- resource's files as they were when it started). When what it serves is not our layer (it started before us, or
-- Status changed), or when we stop, it is restarted so it writes the right one: nobody edits theme.css.
local THEME_RES, THEME_LAYER = 'd11_theme', 'css/d11_hud.css'
local function themeTakesLayer()
    return GetResourceState(THEME_RES) == 'started'
        and (LoadResourceFile(THEME_RES, 'theme.css') or ''):find(THEME_LAYER, 1, true) ~= nil
end
local function restartTheme(why)
    print(('^3[d11_hud] restarting d11_theme: %s^0'):format(why))
    StopResource(THEME_RES)
    StartResource(THEME_RES)
end

-- Stopping: the theme goes back to an empty layer, or WHIP's gauges would stay hidden with no HUD of ours.
AddEventHandler('onResourceStop', function(res)
    if res ~= SELF or not themeTakesLayer() then return end
    if (LoadResourceFile(THEME_RES, THEME_LAYER) or ''):find('#minimap3d', 1, true) then restartTheme('d11_hud stopped') end
end)

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
    if themeTakesLayer() then
        if (LoadResourceFile(THEME_RES, THEME_LAYER) or '') ~= layerCss() then
            restartTheme('it started before d11_hud (or Status changed), so it serves an old layer')
        end
        report(true, 'WHIP layer on: carried by d11_theme (its css/d11_hud.css).', THEME_RES)
        return
    end
    if theme == 'd11_theme' then
        -- d11_theme 1.0.x: the two @import lines ship commented out (a failed import drops the whole theme)
        local css = LoadResourceFile('d11_theme', 'theme.css') or ''
        if ("\n" .. css):find("\n@import url%('https://cfx%-nui%-" .. SELF .. "/whip/hud%.css") then
            report(true, 'WHIP layer on: through d11_theme, which imports whip/hud.css and whip/status.css.', 'd11_theme')
        else
            report(false, ('WHIP layer off: d11_theme 1.0.x is the active WHIP theme. Update it to 1.1.0 (github.com/DLady25/whip-d11-theme), which takes the layer by itself, or add %s to its theme.css.')
                :format(IMPORT))
        end
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
