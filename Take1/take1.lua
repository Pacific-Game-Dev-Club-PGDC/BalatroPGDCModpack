SMODS.current_mod.optional_features = { retrigger_joker = true }

-- LEFT ARM
SMODS.Atlas {
    key = 'larm',
    path = 'larm.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "larm",
    atlas = "larm",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 2,
    discovered = true,
    eternal_compat = false,
    config = { extra = { mult = 10 }, },
    loc_txt = {
        name = "Forbidden Left Arm",
        text = {
            "{C:red,s:1.1}+#1#{} Mult",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
    end
}

-- RIGHT ARM
SMODS.Atlas {
    key = 'rarm',
    path = 'rarm.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "rarm",
    atlas = "rarm",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 2,
    discovered = true,
    eternal_compat = false,
    config = { extra = { chips = 50 }, },
    loc_txt = {
        name = "Forbidden Right Arm",
        text = {
            "{C:blue,s:1.1}+#1#{} Chips",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end
}

-- LEFT LEG
SMODS.Atlas {
    key = 'lleg',
    path = 'lleg.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "lleg",
    atlas = "lleg",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    eternal_compat = false,
    config = { extra = { Xmult = 1.5 }, },
    loc_txt = {
        name = "Forbidden Left Leg",
        text = {
            "{X:mult,C:white}X1.5{} Mult",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { Xmult = card.ability.extra.Xmult }
        end
    end
}

-- RIGHT LEG
SMODS.Atlas {
    key = 'rleg',
    path = 'rleg.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "rleg",
    atlas = "rleg",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 5,
    discovered = true,
    eternal_compat = false,
    config = { extra = { x_chips = 1.5 }, },
    loc_txt = {
        name = "Forbidden Right Leg",
        text = {
            "{X:chips,C:white}X1.5{} Chips",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { x_chips = card.ability.extra.x_chips }
        end
    end
}

-- EXODIA HEAD
SMODS.Atlas {
    key = 'exodia',
    path = 'exodia.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'exodia',
    atlas = 'exodia',
    pos = { x = 0, y = 0 },
    rarity = 2,
    blueprint_compat = true,
    cost = 10,
    discovered = true,
    eternal_compat = false,
    config = { extra = { retriggers = 2 }, },
    loc_txt = {
        name = "Head of Exodia",
        text = {
            "Retriggers Joker to the {C:attention}right{} twice",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers } }
    end,
    calculate = function(self, card, context)
        -- Exodia completion
        if context.joker_main then
            local larm = find_joker("j_take1_larm")
            local rarm = find_joker("j_take1_rarm")
            local lleg = find_joker("j_take1_lleg")
            local rleg = find_joker("j_take1_rleg")


            if next(larm) and next(rarm) and next(lleg) and next(rleg) then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    blockable = false,
                    func = function()
                        card:remove()
                        larm[1]:remove()
                        rarm[1]:remove()
                        lleg[1]:remove()
                        rleg[1]:remove()
                        SMODS.add_card{ key = "j_take1_exodiafull" }
                        
                        return true
                    end
                }))
            end
        end

        -- Retrigger to the right
        local my_pos = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                my_pos = i
                break
            end
        end

        if context.retrigger_joker_check and not context.retrigger_joker then
            if my_pos and context.other_card == G.jokers.cards[my_pos + 1] then
                return {
                    message = "Again!",
                    repetitions = card.ability.extra.retriggers,
                    card = card,
                }
            end
        end
    end
}

-- EXODIA FULL (no atlas yet, just mechanical)
SMODS.Joker {
    key = "exodiafull",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 0, y = 1 },
    rarity = 4,
    blueprint_compat = true,
    cost = 20,
    discovered = true,
    eternal_compat = false,
    config = { extra = { x_chips = 1.5 }, },
    loc_txt = {
        name = "Exodia Unchained",
        text = {
            "{C:attention}Squares{} Chips and Mult",
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                echips = 2,
                emult = 2,
            }
        end
    end
}

local start_run_ref = Game.start_run
function Game:start_run(...)
    start_run_ref(self, ...)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        blockable = false,
        func = function()
            SMODS.add_card{ key = "j_take1_larm" }
            SMODS.add_card{ key = "j_take1_rarm" }
            SMODS.add_card{ key = "j_take1_lleg" }
            SMODS.add_card{ key = "j_take1_rleg" }
            SMODS.add_card{ key = "j_take1_exodia" }
            return true
        end
    }))
end
