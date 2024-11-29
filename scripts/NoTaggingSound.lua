local mod = get_mod("NoTaggingSound")
local Data = mod:io_dofile("NoTaggingSound/scripts/NoTaggingSound_data")

local _player = nil
local _player_first_person_system = nil
local _settings = {}

local function _msg(fmt, ...)
	local s = string.format(fmt, ...)
	mod:echo(s)
	print(s)
end

local function _update_local_player(player, unit)
	player = Managers.player:local_player_safe(1)
	_player = player and player.player_unit
	_player_first_person_system = ScriptUnit.has_extension(_player, "first_person_system")
	_msg("PLAYER=%s FPS=%s", _player, _player_first_person_system)
end

-- mod:hook_safe("GameModeManager", "on_player_unit_spawn", function(self, player, player_unit, is_respawn)
-- 	_msg("Spawn %s", player:local_player_id())
-- 	_update_local_player(player, player_unit)
-- end)

-- Managers.event:register(mod, "player_unit_spawned", "on_player_unit_spawned")
-- function mod.on_player_unit_spawned(...)
-- 	print(...)
-- end
-- function mod.on_unload(...)
-- 	Managers.event:unregister(mod, "player_unit_spawned")
-- end

local function _update_settings(parent)
	for _, v in pairs(parent) do
		_settings[v.setting_id] = mod:get(v.setting_id)
		if v.sub_widgets then
			_update_settings(v.sub_widgets)
		end
	end
end

local function _check_visible(pos)
	_update_local_player()
	if not _player_first_person_system then
		mod:error("_player_first_person_system is nil")
		return false
	end

	return _player_first_person_system:is_within_default_view(pos)
end

_update_local_player()
_update_settings(Data.options.widgets)

function mod.on_setting_changed(setting_id)
	_settings[setting_id] = mod:get(setting_id)
end

local _groups = {
	enemy = function(tag)
		-- return _settings.ping_mute_enemies and (not _settings.ping_unmute_enemies_behind or _check_visible(pos))
		if _settings.ping_mute_enemies then
			if _settings.ping_unmute_enemies_behind then
				local pos = POSITION_LOOKUP[tag._target_unit]

				mod:echo(Vector3Box(pos))
				if _check_visible(pos) then
					_msg("enemy VISIBLE")
					return true
				else
					_msg("enemy NOT visible")
					return false
				end
			end

			return true
		end

		return false
	end,
	object = function(tag)
		return _settings.ping_mute_items
	end,
	location_ping = function(tag)
		return _settings.ping_mute_location_ping
	end,
	location_attention = function(tag)
		return _settings.ping_mute_location_attention
	end,
	location_threat = function(tag)
		return _settings.ping_mute_location_threat
	end,
}

local function _smart_tag(template_name, tagger_unit, target_unit, target_location)
	local smart_tag_extension = Managers.state.extension:system("smart_tag_system")
	if target_unit then
		smart_tag_extension:set_contextual_unit_tag(tagger_unit, target_unit)
	else
		smart_tag_extension:set_tag(template_name, tagger_unit, nil, target_location)
	end
end
local _last_tag = nil

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local group = tag_instance._template.group

	_last_tag = {
		template = tag_instance._template,
		tagger = tag_instance._tagger_unit,
		unit = tag_instance._target_unit,
		pos = tag_instance._target_location or Vector3Box(POSITION_LOOKUP[tag_instance._target_unit]),
	}

	if _settings.ping_duration then
		local t = Managers.time:time("gameplay")
		tag_instance._expire_time = t + _settings.ping_duration_seconds
	end

	if _groups[group](tag_instance) then
		return -- mute
	end

	return func(self, tag_instance, event_name)
end)

mod:hook_safe("InputManager", "update", function(self, dt, t)
	if Keyboard.pressed(Keyboard.button_index("t")) then
		if _last_tag and (not _last_tag.unit or HEALTH_ALIVE[_last_tag.unit]) then
			_smart_tag(
				_last_tag.template.name,
				_last_tag.tagger,
				_last_tag.unit,
				_last_tag.unit and nil or _last_tag.pos:unbox()
			)
		end
	end
end)
