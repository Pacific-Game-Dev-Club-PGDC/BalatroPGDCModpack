--- STEAMODDED HEADER
--- MOD_NAME: PGDCModPack
--- MOD_ID: PGDCModpack
--- MOD_AUTHOR: [Pacific Game Dev Club]
--- MOD_DESCRIPTION: Club collaboration of unique Balatro Cards.

----------------------------------------------
-- Sprite sheet
----------------------------------------------
-- MyJokers.png lives in assets/1x/ and is a single 71x95 frame.
-- Add more frames to the sheet (side by side) and increment pos.x
-- (0-indexed) if you add more jokers later.
SMODS.Atlas {
    key = "MyJokers",
    path = "MyJokers.png",
    px = 71,
    py = 95
}

----------------------------------------------
-- Enable the post_trigger context
----------------------------------------------
-- This lets our joker react right after an adjacent joker's
-- own calculate() has run, so we can see and modify its output.
SMODS.current_mod.optional_features = function()
    return { post_trigger = true }
end

----------------------------------------------
-- Amplifier
----------------------------------------------
-- Doubles the chips, mult, and xmult given by the jokers
-- immediately to its left and right.
SMODS.Joker {
    key = "amplifier",
    atlas = "MyJokers",
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_txt = {
        name = "Amplifier",
        text = {
            "Adjacent Jokers' scoring",
            "{C:mult}Chips{}, {C:mult}Mult{}, and {C:mult}Xmult{}",
            "are {C:red}doubled{}"
        }
    },

    config = {},

    calculate = function(self, card, context)
        -- Only react right after ANOTHER joker's main scoring trigger
        if context.post_trigger and context.other_context and context.other_context.joker_main then

            -- Find this card's position and the triggering card's position
            -- within the joker area, so we can check adjacency.
            local my_index, other_index
            for i, c in ipairs(G.jokers.cards) do
                if c == card then my_index = i end
                if c == context.other_card then other_index = i end
            end

            -- Only affect the immediate left/right neighbor
            if my_index and other_index and math.abs(my_index - other_index) == 1 then
                local ret = {}
                local vals = context.other_ret.jokers or {}

                -- Additive stats: repeating the same amount doubles it.
                -- Vanilla's return table uses chip_mod / mult_mod / Xmult_mod
                -- (capital X), not chips / mult / xmult.
                if vals.chip_mod then
                    ret.chip_mod = vals.chip_mod
                end
                if vals.mult_mod then
                    ret.mult_mod = vals.mult_mod
                end

                -- Multiplicative stat: an extra x2 doubles its effect
                -- (reapplying the same Xmult_mod would square it instead)
                if vals.Xmult_mod then
                    ret.Xmult_mod = 2
                end

                if next(ret) then
                    ret.message = "Amplified!"
                    ret.colour = G.C.RED
                    return ret
                end
            end
        end
    end
}

----------------------------------------------
-- TEMPORARY TESTING CODE
----------------------------------------------
-- Auto-spawns Amplifier at the start of every run so you don't have
-- to wait for it to show up naturally in shops while you're testing.
-- DELETE this whole block once you're done testing — you don't want
-- this forcing itself into normal runs (yours or anyone else's).
local start_run_ref = Game.start_run
function Game:start_run(...)
    start_run_ref(self, ...)
    SMODS.add_card{ key = "j_myjm_amplifier" }
end
