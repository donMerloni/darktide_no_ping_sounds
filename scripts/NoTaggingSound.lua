local mod = get_mod("NoTaggingSound")

local function local_player()
	local player = Managers.player:local_player(1)
	return player and player.player_unit
end

local function _check_pos_within_view(pos)
	local player = local_player()
	local first_person_system = ScriptUnit.has_extension(player, "first_person_system")
	if not first_person_system then
		return false
	end

	return first_person_system:is_within_default_view(pos)
end

local function _tag_unit_pos(tag_instance)
	local unit = tag_instance:target_unit()
	return unit, unit and Unit.world_position(unit, 1) or tag_instance:target_location()
end

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local unit, pos = _tag_unit_pos(tag_instance)

	if mod:get("ping_duration") then
		local secs = mod:get("ping_duration_seconds")
		local t = Managers.time:time("gameplay")
		local expire_time = t + secs
		tag_instance:set_expire_time(expire_time)
	end

	if unit then
		local is_item = unit and ScriptUnit.has_extension(unit, "interactee_system")
		if is_item and mod:get("ping_mute_items") then
			return -- mute items
		end

		if
			mod:get("ping_mute_enemies") and (not mod:get("ping_unmute_enemies_behind") or _check_pos_within_view(pos))
		then
			return -- mute enemies
		end
	else
		local marker_type = tag_instance:template().marker_type
		if marker_type == "location_ping" and mod:get("ping_mute_location_ping") then
			return
		end
		if marker_type == "location_attention" and mod:get("ping_mute_location_attention") then
			return
		end
		if marker_type == "location_threat" and mod:get("ping_mute_location_threat") then
			return
		end
	end

	return func(self, tag_instance, event_name)
end)
