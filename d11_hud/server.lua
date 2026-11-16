-- The WHIP layer (whip/hud.css: WHIP's gauges and rev dial hidden, voice as a circle, round minimap) goes into
-- whip_core's page as a WHIP theme, but only when no other theme is active. With your own theme, @import the file
-- from it (README) and set D11Hud.WhipLayer = false. Stopping d11_hud puts WHIP's look back.
if D11Hud.WhipLayer == false then return end

local SELF = GetCurrentResourceName()

local function ours()
    local theme = exports.whip_core:GetActiveTheme()
    return theme == SELF
end

-- Inside Whip.register so it is set again after a whip_core restart.
Whip.register(function()
    local theme = exports.whip_core:GetActiveTheme()
    if theme ~= nil and theme ~= '' and theme ~= SELF then
        print(('^3[d11_hud] the WHIP theme "%s" is active, so d11_hud does not set its own. Add @import url(\'https://cfx-nui-%s/whip/hud.css\'); to that theme, or WHIP\'s gauges stay on screen next to d11_hud.^0')
            :format(theme, SELF))
        return
    end
    local ok, err = exports.whip_core:SetActiveTheme(SELF)
    if not ok then print(('^1[d11_hud] WHIP layer not applied: %s^0'):format(tostring(err))) end
end)

-- Sent again after login: whip_core sends the theme at login, but FiveM's NUI can serve the theme.css cached from the
-- last session; sending it again swaps the <link> and the page fetches it anew.
AddEventHandler('whip_core:player:loaded', function(data)
    local src = type(data) == 'table' and tonumber(data.source)
    if not src then return end
    SetTimeout(2000, function()
        if GetPlayerName(src) and ours() then TriggerClientEvent('whip_core:client:applyTheme', src, SELF) end
    end)
end)
