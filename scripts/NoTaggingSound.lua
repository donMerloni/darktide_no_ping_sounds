local mod = get_mod("NoTaggingSound")
local Data = mod:io_dofile("NoTaggingSound/scripts/NoTaggingSound_data")

local _player = nil
local _player_first_person_system = nil
local _settings = {}

local function _update_player()
	local player = Managers.player:local_player_safe(1)
	_player = player and player.player_unit
	_player_first_person_system = _player and ScriptUnit.has_extension(_player, "first_person_system")
end
local function _update_settings(parent)
	for _, v in pairs(parent) do
		_settings[v.setting_id] = mod:get(v.setting_id)
		if v.sub_widgets then
			_update_settings(v.sub_widgets)
		end
	end
end

local function _check_visible(pos)
	_update_player()
	if not _player_first_person_system then
		mod:error("_player_first_person_system is nil")
		return false
	end

	return _player_first_person_system:is_within_default_view(pos)
end

_update_player()
_update_settings(Data.options.widgets)

function mod.on_setting_changed(setting_id)
	_settings[setting_id] = mod:get(setting_id)
end

local _groups = {
	enemy = function(tag)
		return _settings.ping_mute_enemies
			and (not _settings.ping_unmute_enemies_behind or _check_visible(POSITION_LOOKUP[tag._target_unit]))
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

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local group = tag_instance._template.group

	if _settings.ping_duration then
		local t = Managers.time:time("gameplay")
		tag_instance._expire_time = t + _settings.ping_duration_seconds
	end

	if _groups[group](tag_instance) then
		return -- mute
	end

	return func(self, tag_instance, event_name)
end)
