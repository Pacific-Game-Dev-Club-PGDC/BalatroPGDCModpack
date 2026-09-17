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
-- CARD EFFECT TEMPLATES
----------------------------------------------
--[[
WHEN does calculate() fire? (context flags to check)
-------------------------------------------------------------------------------
  context.joker_main            -- true during the main joker-scoring
                                    stage, after all cards are scored.
                                    Most "if you played X" jokers hook here.

  context.using_consumeable     -- true the instant a Tarot/Planet/Spectral
                                    is used. Unrelated to scoring entirely.

  context.consumeable            -- the actual consumable card being used
                                    (only valid inside using_consumeable).

  context.poker_hands['Flush']  -- array of cards forming that hand THIS
                                    play; empty (not nil) if not played.
                                    Use next(...) to check non-empty.

  context.post_trigger          -- fires right after ANOTHER card/joker's
                                    own calculate() has run. Requires:
                                      SMODS.current_mod.optional_features
                                        = function() return {post_trigger=true} end

  context.other_context          -- the context the OTHER card triggered
                                    under (e.g. check .joker_main on it).

  context.other_card              -- the card that just triggered.

  context.other_ret                -- return table from that trigger.
                                    CONFIRMED BY TESTING: the actual values
                                    are nested under context.other_ret.jokers,
                                    NOT at the top level. Always guard:
                                      local vals = context.other_ret.jokers or {}

WHAT to put in the table you return (effects applied)
-------------------------------------------------------------------------------
  chip_mod   = 10   -- adds Chips (additive)
  mult_mod   = 10   -- adds Mult (additive)
  Xmult_mod  = 2    -- MULTIPLIES current Mult (multiplicative — note
                        capital X). To "double" an xmult you see from
                        another joker, return Xmult_mod = 2 fresh,
                        don't repeat their value (that would square it).

  dollars    = 3    -- adds money, unrelated to scoring
  message    = "+10 Mult"   -- cosmetic popup text
  colour     = G.C.MULT     -- popup color (G.C.MULT/G.C.CHIPS/G.C.MONEY/G.C.RED)

IDENTIFYING cards/jokers
-------------------------------------------------------------------------------
  card.config.center.key      -- internal id, e.g. "j_myjm_amplifier"
                                  (SMODS.Joker keys get auto-prefixed with
                                  your mod's json "prefix"; ConsumableType/
                                  Rarity keys do NOT, so keep those unique
                                  yourself)

  card.config.center.rarity   -- 1=Common, 2=Uncommon, 3=Rare, 4=Legendary
                                  (or a custom SMODS.Rarity key string)

  card.ability.set            -- 'Joker' / 'Planet' / 'Tarot' / 'Spectral'
                                  / a custom SMODS.ConsumableType key

-- PERSISTENT per-card storage (e.g. Fortune-Teller-style counters)
  config = { extra = { mult = 0 } }   -- seeds card.ability.extra.mult = 0
                                        on creation; read/write it any time
                                        from within calculate via
                                        card.ability.extra.mult

SPRITES
-------------------------------------------------------------------------------
  SMODS.Atlas{ key=, path=, px=, py= }  -- ONE call, registers ONE image
                                          file sliced into a px-by-py grid.
                                          To add more sprites: widen/heighten
                                          the PNG (more tiles), don't add a
                                          second Atlas entry.

  pos = { x = 0, y = 0 }                -- which tile a joker uses, 0-indexed,
                                          left-to-right/top-to-bottom.

  disable_mipmap = true                 -- add to Atlas{} if you see color
                                          bleeding between tiles at small
                                          render sizes.
]]

----------------------------------------------
-- PLACE MODDED CARDS HERE!! 
----------------------------------------------
-- Copy this template to help create the base of a new modded card.
--[[
SMODS.Joker {
    key = "Enter card's key.",
    atlas = "MyJokers",
    pos = { x = 0, y = 0 },    -- Position is based on position in MyJokers.pgn file.
    rarity = 1,
    cost = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    loc_txt = {
        name = "Give card a name...",
        text = {
            "(Write description for card...)",
            "Use commas to create multiple lines",
            "of text on the card."
        }
    },

    config = {},

    calculate = function(self, card, context)
        -- Enter card effects here...
    end
]]

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
