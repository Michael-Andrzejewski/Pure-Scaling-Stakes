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
    end,
})

-- Soft-White Stake: White scaling, but antes 1-3 all use ante 1 chips,
-- then shifted by 2 (ante 4 = ante 2 chips, ante 5 = ante 3, etc.)
SMODS.Stake({
    name = "Soft-White Stake",
    key = "soft_white",
    atlas = "ss_chips",
    pos = { x = 4, y = 0 },
    sticker_atlas = "ss_stickers",
    sticker_pos = { x = 4, y = 0 },
    applied_stakes = {},
    colour = HEX("F5EFD0"),
    above_stake = "white",
    unlocked = true,
    modifiers = function()
        G.GAME.modifiers.scaling = 1
        G.GAME.modifiers.ss_soft_white_shift = 2
    end,
})

-- Hook get_blind_amount so the Soft-White ante shift takes effect.
-- Antes 1..(shift+1) all return ante 1's chip value; higher antes use ante N-shift.
local ss_orig_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
    local shift = G.GAME and G.GAME.modifiers and G.GAME.modifiers.ss_soft_white_shift
    if shift and shift > 0 then
        if ante < 1 then return 100 end
        local effective = ante - shift
        if effective < 1 then effective = 1 end
        return ss_orig_get_blind_amount(effective)
    end
    return ss_orig_get_blind_amount(ante)
end
