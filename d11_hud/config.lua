-- d11_hud settings (client and server).
--
-- Language (every D11 resource): setr d11_locale en | pt-BR in server.cfg. Default: en.
local PT = GetConvar('d11_locale', 'en') == 'pt-BR'
local function L(en, pt) return PT and pt or en end

D11Hud = {
    Locale = PT and 'pt-BR' or 'en',
    L = L,

    SpeedUnit = 'mph',      -- 'mph' or 'kmh'
    Logo = false,           -- the D11 logo in the top-right corner (ui/logo.png: swap it for your own)

    -- WHIP's own HUD: d11_hud hides WHIP's status gauges and 3D rev dial (it draws its own), keeps WHIP's voice
    -- gauge as a small circle and clips WHIP's minimap round under the radar ring. That is CSS inside whip_core's
    -- page, so it goes in as a WHIP theme (whip/hud.css) when no other theme is active. Running your own theme?
    -- Add @import url('https://cfx-nui-d11_hud/whip/hud.css'); to it and set this to false.
    WhipLayer = true,

    Radar = true,           -- the ring over WHIP's minimap: compass, heading, area and street
    Route = true,           -- the GPS card next to the ring: next turn and distance (needs Radar)
    MapDefaults = true,     -- once per PC: minimap on foot too, and 25% less zoom in a vehicle (players can change it)

    Ammo = true,            -- rounds, spare magazines and the weapon's silhouette (whip_gunny; GTA's ammo without it)

    Turbo = true,           -- boost gauge for cars with a whip_autos turbo
    Nitro = true,           -- nitrous arc for cars with a whip_autos nitrous bottle

    Seatbelt = {
        Enabled = true,
        Key = 'B',              -- default key; players rebind it in Settings > Key Bindings > FiveM
        EjectKmh = 20,          -- through the windscreen above this speed without the belt...
        EjectBuckledKmh = 160,  -- ...and above this one with it
    },

    Hints = {
        Enabled = true,         -- action hints in the bottom-right corner; players toggle them with the command
        Command = L('hints', 'legendas'),
    },

    LowFuel = {
        Enabled = true,
        Threshold = 20,         -- % of the tank
        RepeatSeconds = 60,     -- warns again this often until refuelled
    },

    -- The energy orb reads GTA's sprint stamina. A movement resource that keeps its own stamina can feed it:
    -- { resource = 'my_movement', export = 'GetStamina' } (the export returns 0-100).
    Stamina = false,
}
