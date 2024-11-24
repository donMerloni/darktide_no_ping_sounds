local mod = get_mod("NoTaggingSound")
local dmf = get_mod("DMF")
-- mod.is_hooked = false

-- dmf:echo("hello %s", "echo")
-- dmf:info("hello %s", "info")
-- dmf:warning("hello %s", "warning")
-- dmf:error("hello %s", "error")
-- dmf:debug("hello %s", "debug")
-- print(string.format("hello %s", "console"))

local _last_unit = nil

local function _local_player()
    local player = Managers.player:local_player(1)
    return player and player.player_unit
end

local function _check_unit_within_view(unit)
    local player = _local_player()
    local first_person_system = ScriptUnit.has_extension(player, "first_person_system")
    if not first_person_system then return false end

    --local pos = POSITION_LOOKUP[unit] --Unit.world_position(unit, 1)
    local pos = Unit.world_position(unit, 1)

    dmf:echo(pos)
    -- dmf:dump_to_file(pos, "TARGET_POS", 5)
    
    local R = first_person_system:is_within_default_view(pos)

    if not R then
        dmf:echo("NOT IN VIEW")
    end
    --wwise/events/ui/play_smart_tag_location_threat_enter_others

    return R
end

function mod:on_setting_changed()
end

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
    
    if mod:get("ping_mute_all") then
        print(event_name)
        -- dmf:echo("tag_instance=%d event_name=%s display_name=%s", tag_instance._expire_time, event_name, tag_instance:display_name())
        
        -- OVERRIDE DURATION
        -- local t = Managers.time:time("gameplay")
        -- local expire_time = t + 3
        -- tag_instance:set_expire_time(expire_time)

        target = tag_instance:target_unit()
        _last_unit = target

        --dmf:dump_to_file(ScriptUnit.extensions(tag_instance:tagger_unit()), "tag_instance__tagger_extensions", 5)
        --dmf:dump_to_file(ScriptUnit.extensions(tag_instance:target_unit()), "tag_instance__target_extensions", 5)
        --dmf:dump_to_file(tag_instance, "tag_instance", 5)
        --dmf:dump_to_file(tag_instance:target_location(), "tag_instance__target_location", 5)
        
        if not mod:get("ping_unmute_all_behind") or _check_unit_within_view(target) then
            return -- mute sound
        end 
    end

    return func(self, tag_instance, event_name)
end)

-- mod:hook_require("scripts/ui/hud/elements/smart_tagging/hud_element_smart_tagging", function(instance)
--     -- if mod.is_hooked then return end
--     -- mod.is_hooked = true
--     print("Hooking stuff")

--     mod:hook(instance, "_play_tag_sound", function(func, self, tag_instance, event_name)
--         if mod:get("mute_pings") then
--             return -- nuke all ping sounds
--         end
--         return func(self, tag_instance, event_name)
--     end)
-- end)

-- quick and dirty keybinds without using NoTaggingSound_data.lua
mod:hook_safe(CLASS.InputManager, "update", function(self, dt, t)
    if Keyboard.pressed(Keyboard.button_index("f2")) then
        dmf:echo("Pressed F2")

        if _last_unit then
            _check_unit_within_view(_last_unit)
        end
    end
end)
