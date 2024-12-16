local mod = get_mod("NoTaggingSound")
local Breeds = require("scripts/settings/breed/breeds")
local Pickups = require("scripts/settings/pickup/pickups")

local sorted = {}
for _, v in pairs(Breeds) do
	if v.smart_tag_target_type then
		table.insert(sorted, v)
	end
end
table.sort(sorted, function(x, y)
	return x.display_name < y.display_name
end)

local widgets = {}

-- for k, v in pairs(Pickups.by_name) do
-- 	if not v.smart_tag_target_type then
-- 		mod:echo(k)
-- 	end
-- end

widgets[#widgets + 1] = {
	setting_id = "ping_mute_enemy",
	type = "checkbox",
	default_value = true,
	sub_widgets = {
		{
			setting_id = "ping_mute_in_front",
			type = "checkbox",
			default_value = true,
		},
	},
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_item",
	type = "checkbox",
	default_value = true,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_ping",
	type = "checkbox",
	default_value = true,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_attention",
	type = "checkbox",
	default_value = true,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_threat",
	type = "checkbox",
	default_value = true,
}
widgets[#widgets + 1] = {
	setting_id = "ping_duration",
	type = "checkbox",
	default_value = false,
	sub_widgets = {
		{
			setting_id = "ping_duration_seconds",
			type = "numeric",
			default_value = 15,
			range = { 1, 60 * 2 },
		},
	},
}
widgets[#widgets + 1] = {
	setting_id = "debug",
	type = "checkbox",
	default_value = false,
	sub_widgets = {
		{
			setting_id = "debug_repeat_ping",
			type = "keybind",
			default_value = {},
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "debug_repeat_ping",
		},
	},
}
local preview = {}
for _, v in ipairs(sorted) do
	if v.smart_tag_target_type then
		preview[#preview + 1] = {
			setting_id = "ping_mute_enemy_" .. v.name,
			type = "checkbox",
			default_value = false,
			sub_widgets = {
				{
					setting_id = "ping_mute_enemy_in_front_" .. v.name,
					title = "ping_mute_in_front",
					tooltip = "ping_mute_in_front_description",
					type = "checkbox",
					default_value = false,
				},
			},
		}
	end
end

widgets[#widgets + 1] = {
	setting_id = "coming_soon",
	type = "group",
	sub_widgets = preview,
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	},
}
