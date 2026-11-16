-- The WHIP layer, client side (server.lua decides it). Says in F8 what the server decided and what whip_core's page
-- was last told, once the player is in; and if the server holds the layer but this page never got it (a broadcast
-- missed while loading), hands whip_core its own applyTheme event again, locally.

local SELF = GetCurrentResourceName()
local pageTheme = nil   -- the last theme whip_core's page was told to load (its applyTheme event), if any

RegisterNetEvent('whip_core:client:applyTheme')
AddEventHandler('whip_core:client:applyTheme', function(resource) pageTheme = resource or false end)

local function check()
    local layer = GlobalState.d11_hud_layer
    if type(layer) ~= 'table' then
        print('^3[d11_hud] WHIP layer: no word from d11_hud\'s server side (is server.lua running? check the server console)^0')
        return
    end
    print(('%s[d11_hud] %s^0'):format(layer.on and '^2' or '^3', tostring(layer.text)))
    if layer.on and pageTheme ~= SELF then
        print('^3[d11_hud] whip_core\'s page had not been sent the layer: sending it again^0')
        TriggerEvent('whip_core:client:applyTheme', SELF)
    end
end

AddEventHandler('whip_core:player:loaded', function() SetTimeout(5000, check) end)
-- d11_hud (re)started with the player already in
CreateThread(function()
    Wait(5000)
    if Hud.core('IsPlayerLoaded') == true then check() end
end)
