local mod = get_mod("NoTaggingSound")
local util = mod:io_dofile(mod:get_name() .. "/scripts/util")(mod)
local keybind = util.keybind
local print = util.print

local _player = nil
local _player_first_person_system = nil
local _settings = util.settings_cache()

local function _trace(...)
	if _settings.debug then
		util.print(...)
	end
end

local function _update_local_player()
	_player = util.player()
	_player_first_person_system = ScriptUnit.has_extension(_player, "first_person_system")
	_trace("PLAYER=%s FPS=%s", _player, _player_first_person_system)
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

-- local function _update_settings(parent)
-- 	for _, v in pairs(parent) do
-- 		_settings[v.setting_id] = mod:get(v.setting_id)
-- 		if v.sub_widgets then
-- 			_update_settings(v.sub_widgets)
-- 		end
-- 	end
-- end

local function _check_visible(pos)
	_update_local_player()
	if not _player_first_person_system then
		mod:error("_player_first_person_system is nil")
		return false
	end

	return _player_first_person_system:is_within_default_view(pos)
end

_update_local_player()

-- function mod.on_setting_changed(setting_id)
-- 	_settings[setting_id] = mod:get(setting_id)
-- end

local _groups = {
	enemy = function(tag)
		if not _settings.debug then
			return _settings.ping_mute_enemies
				and (not _settings.ping_unmute_enemies_behind or _check_visible(POSITION_LOOKUP[tag._target_unit]))
		end

		if _settings.ping_mute_enemies then
			if _settings.ping_unmute_enemies_behind then
				local pos = tag._target_location or POSITION_LOOKUP[tag._target_unit]
				if pos[1] == math.huge then
					pos = Unit.world_position(tag._target_unit, 1)
				end

				if _check_visible(pos) then
					_trace("enemy VISIBLE")
					return true
				else
					_trace("enemy NOT visible")
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

mod:hook("HudElementSmartTagging", "_play_tag_sound", function(func, self, tag_instance, event_name)
	local group = tag_instance._template.group

	if _settings.debug then
		local pos = (tag_instance._target_unit and Vector3Box(Unit.world_position(tag_instance._target_unit, 1)))
			or tag_instance._target_location
		util.set("last_tag", {
			template = tag_instance._template,
			tagger = tag_instance._tagger_unit,
			unit = tag_instance._target_unit,
			pos = pos,
		})
	end

	if _settings.ping_duration then
		local t = Managers.time:time("gameplay")
		tag_instance._expire_time = t + _settings.ping_duration_seconds
	end

	if _groups[group](tag_instance) then
		return -- mute
	end

	return func(self, tag_instance, event_name)
end)

if _settings.debug then
	keybind:press("t", function(t)
		util.get("last_tag", function(t)
			if not t.unit or HEALTH_ALIVE[t.unit] then
				util.smart_tag(t.template.name, t.tagger, t.unit, t.unit and nil or t.pos:unbox())
			end

			util.debug:draw_sphere("tag", t.pos, Color.red())
		end)
	end)

	mod:hook_safe("InputManager", "update", function(self, dt, t)
		keybind:check(t)
	end)

	mod:hook_require("scripts/managers/ui/ui_renderer", function(UIRenderer)
		mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
			util.debug:draw_input(UIRenderer, self, ui_scenegraph)
		end)
	end)

	Managers.event:trigger("event_clear_notifications")
end
