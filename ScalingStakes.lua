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
