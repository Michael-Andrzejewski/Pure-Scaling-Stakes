-- Pure Scaling Stakes -- by Soareverix
--
-- Fix: On the Continue screen, G.viewed_stake gets clamped to 1 before
-- the UI callback renders the stake name. We hook viewed_stake_option to
-- restore the correct stake from the save data when in Continue mode.
local ss_orig_viewed = G.UIDEF.viewed_stake_option
G.UIDEF.viewed_stake_option = function()
    if G.SETTINGS.current_setup == 'Continue' and G.SAVED_GAME and G.SAVED_GAME.GAME then
        local saved_stake = G.SAVED_GAME.GAME.stake
        if saved_stake and saved_stake > 0 and saved_stake <= #G.P_CENTER_POOLS.Stake then
            G.viewed_stake = saved_stake
        end
    end
    return ss_orig_viewed()
end

----------------------------------------------
-- Config: soft antes + per-stake toggles    --
----------------------------------------------

local ss_config_defaults = {
    soft_antes = 0,
    apply_to_white = false,
    apply_to_white_blue = false,
    apply_to_white_red = false,
    apply_to_white_black = false,
    apply_to_white_void = false,
    win_ante = 8,
}

local SS_WIN_ANTE_MIN = 2
local SS_WIN_ANTE_MAX = 39

local ss_mod_handle = SMODS.current_mod
if ss_mod_handle then
    ss_mod_handle.config = ss_mod_handle.config or {}
    for k, v in pairs(ss_config_defaults) do
        if ss_mod_handle.config[k] == nil then
            ss_mod_handle.config[k] = v
        end
    end
end

local function ss_cfg()
    return (ss_mod_handle and ss_mod_handle.config) or ss_config_defaults
end

local function ss_log(msg)
    local s = '[ScalingStakes] ' .. tostring(msg)
    if sendInfoMessage then
        pcall(sendInfoMessage, s, 'ScalingStakes')
    end
    print(s)
end

-- Apply soft-ante shift for a given stake config key, if enabled.
local function ss_apply_soft(cfg_key)
    local cfg = ss_cfg()
    local n = cfg.soft_antes or 0
    ss_log(string.format('ss_apply_soft: cfg_key=%s n=%s toggle=%s',
        tostring(cfg_key), tostring(n), tostring(cfg[cfg_key])))
    if n > 0 and cfg_key and cfg[cfg_key] and G.GAME and G.GAME.modifiers then
        G.GAME.modifiers.ss_soft_white_shift = n
        ss_log('  set ss_soft_white_shift = ' .. tostring(n))
    end
end

----------------------------------------------
-- Atlas definitions for chips and stickers --
----------------------------------------------

SMODS.Atlas({
    key = "ss_chips",
    path = "ss_chips.png",
    px = 29,
    py = 29,
    atlas_table = "ASSET_ATLAS",
})

SMODS.Atlas({
    key = "ss_stickers",
    path = "ss_stickers.png",
    px = 71,
    py = 57,
    atlas_table = "ASSET_ATLAS",
})

-----------------------
-- Stake definitions --
-----------------------

-- White-Blue Stake: Scaling level 2 (same as Red Stake's scaling, but no debuffs)
SMODS.Stake({
    name = "White-Blue Stake",
    key = "white_blue",
    atlas = "ss_chips",
    pos = { x = 0, y = 0 },
    sticker_atlas = "ss_stickers",
    sticker_pos = { x = 0, y = 0 },
    applied_stakes = {},
    colour = HEX("5588CC"),
    above_stake = "white",
    unlocked = true,
    modifiers = function()
        G.GAME.modifiers.scaling = 2
        ss_apply_soft('apply_to_white_blue')
    end,
})

-- White-Red Stake: Scaling level 3 (same as Green Stake's scaling, but no debuffs)
SMODS.Stake({
    name = "White-Red Stake",
    key = "white_red",
    atlas = "ss_chips",
    pos = { x = 1, y = 0 },
    sticker_atlas = "ss_stickers",
    sticker_pos = { x = 1, y = 0 },
    applied_stakes = {},
    colour = HEX("CC5544"),
    above_stake = "scalingstakes_white_blue",
    unlocked = true,
    modifiers = function()
        G.GAME.modifiers.scaling = 3
        ss_apply_soft('apply_to_white_red')
    end,
})

-- White-Black Stake: Scaling level 4 (same as Cryptid Pink Stake's scaling, but no debuffs)
SMODS.Stake({
    name = "White-Black Stake",
    key = "white_black",
    atlas = "ss_chips",
    pos = { x = 2, y = 0 },
    sticker_atlas = "ss_stickers",
    sticker_pos = { x = 2, y = 0 },
    applied_stakes = {},
    colour = HEX("3A3A3E"),
    above_stake = "scalingstakes_white_red",
    unlocked = true,
    modifiers = function()
        G.GAME.modifiers.scaling = 4
        ss_apply_soft('apply_to_white_black')
    end,
})

-- White-Void Stake: Scaling level 5 (same as Cryptid Verdant Stake's scaling, but no debuffs)
SMODS.Stake({
    name = "White-Void Stake",
    key = "white_void",
    atlas = "ss_chips",
    pos = { x = 3, y = 0 },
    sticker_atlas = "ss_stickers",
    sticker_pos = { x = 3, y = 0 },
    applied_stakes = {},
    colour = HEX("7733BB"),
    above_stake = "scalingstakes_white_black",
    unlocked = true,
    modifiers = function()
        G.GAME.modifiers.scaling = 5
        ss_apply_soft('apply_to_white_void')
    end,
})

----------------------------------------------
-- Soft-ante shift wiring                    --
----------------------------------------------

-- Hook the vanilla White stake's modifiers function so it can also opt
-- into soft antes. We install this lazily once the stake pool exists.
local ss_white_hooked = false
local function ss_install_white_hook()
    if ss_white_hooked then return true end
    if not (G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake) then return false end
    for _, s in ipairs(G.P_CENTER_POOLS.Stake) do
        if s.key == 'white' then
            local orig = s.modifiers
            s.modifiers = function()
                if orig then orig() end
                ss_apply_soft('apply_to_white')
            end
            ss_white_hooked = true
            ss_log('vanilla white stake modifiers hook installed')
            return true
        end
    end
    return false
end

-- Try at load time (might be too early), and also via a Game:start_run
-- pre-hook that installs the patch before stake modifiers run.
ss_install_white_hook()

local ss_orig_start_run = Game.start_run
function Game:start_run(args)
    ss_install_white_hook()
    -- Log stake info before vanilla runs.
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake then
        ss_log('start_run: stake_index_arg=' .. tostring(args and args.stake))
    end
    local res = ss_orig_start_run(self, args)
    -- Apply configured win ante (default 8). Clamped to [min, max].
    if G.GAME then
        local cfg2 = ss_cfg()
        local wa = math.floor(tonumber(cfg2.win_ante) or 8)
        if wa < SS_WIN_ANTE_MIN then wa = SS_WIN_ANTE_MIN end
        if wa > SS_WIN_ANTE_MAX then wa = SS_WIN_ANTE_MAX end
        G.GAME.win_ante = wa
        ss_log('start_run: G.GAME.win_ante = ' .. tostring(wa))
    end
    -- Log final state after stake modifiers fired.
    if G.GAME and G.GAME.modifiers then
        ss_log(string.format('start_run done: stake=%s scaling=%s shift=%s',
            tostring(G.GAME.stake),
            tostring(G.GAME.modifiers.scaling),
            tostring(G.GAME.modifiers.ss_soft_white_shift)))
        local center = G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[G.GAME.stake]
        if center then
            ss_log('start_run done: stake center.key=' .. tostring(center.key))
        end
    end
    return res
end

-- Hook get_blind_amount so the soft-ante shift takes effect.
-- Antes 1..(shift+1) all return ante 1's chip value; higher antes use ante N-shift.
local ss_orig_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
    local shift = G.GAME and G.GAME.modifiers and G.GAME.modifiers.ss_soft_white_shift
    if shift and shift > 0 then
        if ante < 1 then return 100 end
        local effective = ante - shift
        if effective < 1 then effective = 1 end
        local out = ss_orig_get_blind_amount(effective)
        ss_log(string.format('get_blind_amount(%s) shift=%s -> effective=%s -> %s',
            tostring(ante), tostring(shift), tostring(effective), tostring(out)))
        return out
    end
    return ss_orig_get_blind_amount(ante)
end

----------------------------------------------
-- Mods menu config tab                      --
----------------------------------------------

if SMODS.current_mod then
    local ss_mod = SMODS.current_mod
    ss_mod.config_tab = function()
        local cfg = ss_mod.config or ss_config_defaults
        local soft_options = { 0, 1, 2, 3, 4, 5 }

        local function row(node)
            return { n = G.UIT.R, config = { align = 'cm', padding = 0.04 }, nodes = { node } }
        end

        return {
            n = G.UIT.ROOT,
            config = { align = 'cm', padding = 0.05, colour = G.C.CLEAR },
            nodes = {
                row({ n = G.UIT.T, config = {
                    text = 'Extra soft antes (use Ante 1 chips for this many extra antes after Ante 1):',
                    scale = 0.38,
                    colour = G.C.UI.TEXT_LIGHT,
                } }),
                row(create_option_cycle({
                    label = 'Soft antes',
                    scale = 0.8,
                    w = 4,
                    options = soft_options,
                    opt_callback = 'ss_soft_antes_callback',
                    current_option = (cfg.soft_antes or 0) + 1,
                })),
                row({ n = G.UIT.T, config = {
                    text = 'Apply soft antes to:',
                    scale = 0.42,
                    colour = G.C.UI.TEXT_LIGHT,
                } }),
                row(create_toggle({ label = 'White Stake (vanilla)', ref_table = cfg, ref_value = 'apply_to_white' })),
                row(create_toggle({ label = 'White-Blue Stake', ref_table = cfg, ref_value = 'apply_to_white_blue' })),
                row(create_toggle({ label = 'White-Red Stake', ref_table = cfg, ref_value = 'apply_to_white_red' })),
                row(create_toggle({ label = 'White-Black Stake', ref_table = cfg, ref_value = 'apply_to_white_black' })),
                row(create_toggle({ label = 'White-Void Stake', ref_table = cfg, ref_value = 'apply_to_white_void' })),
                row({ n = G.UIT.T, config = {
                    text = 'Win ante (default 8, applies to all runs):',
                    scale = 0.42,
                    colour = G.C.UI.TEXT_LIGHT,
                } }),
                row(create_slider({
                    label = 'Win Ante',
                    ref_table = cfg,
                    ref_value = 'win_ante',
                    min = SS_WIN_ANTE_MIN,
                    max = SS_WIN_ANTE_MAX,
                    w = 4,
                    h = 0.4,
                    text_scale = 0.4,
                    decimal_places = 0,
                })),
            },
        }
    end
end

local ss_mod_ref = SMODS.current_mod
G.FUNCS.ss_soft_antes_callback = function(args)
    if not args or args.to_val == nil then return end
    if ss_mod_ref and ss_mod_ref.config then
        ss_mod_ref.config.soft_antes = tonumber(args.to_val) or 0
        ss_log('soft_antes set to ' .. tostring(ss_mod_ref.config.soft_antes))
    end
end

-- Dump full config when the tab opens, so we can verify persisted values.
if ss_mod_handle and ss_mod_handle.config_tab then
    local orig_tab = ss_mod_handle.config_tab
    ss_mod_handle.config_tab = function(...)
        local c = ss_mod_handle.config or {}
        ss_log(string.format('config_tab open: soft_antes=%s white=%s wb=%s wr=%s wblk=%s wv=%s',
            tostring(c.soft_antes),
            tostring(c.apply_to_white),
            tostring(c.apply_to_white_blue),
            tostring(c.apply_to_white_red),
            tostring(c.apply_to_white_black),
            tostring(c.apply_to_white_void)))
        return orig_tab(...)
    end
end
