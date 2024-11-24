local mod = get_mod("NoTaggingSound")

local function _local_player()
    local player = Managers.player:local_player(1)
    return player and player.player_unit
end

local function _check_unit_within_view(unit)
    local player = _local_player()
    local first_person_system = ScriptUnit.has_extension(player, "first_person_system")
    if not first_person_system then return false end

    local pos = Unit.world_position(unit, 1)
    
    return first_person_system:is_within_default_view(pos)
end

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
    if mod:get("ping_mute_all") then
        target = tag_instance:target_unit()

        if not mod:get("ping_unmute_all_behind") or _check_unit_within_view(target) then
            return -- mute sound
        end 
    end

    return func(self, tag_instance, event_name)
end)
