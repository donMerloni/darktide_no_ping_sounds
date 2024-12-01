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

for _, v in ipairs(sorted) do
	if v.smart_tag_target_type then
		widgets[#widgets + 1] = {
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

for k, v in pairs(widgets) do
	if not v.sub_widgets or not (#v.sub_widgets > 0) then
		mod:dump(v)
	end
end

-- for k, v in pairs(Pickups.by_name) do
-- 	if not v.smart_tag_target_type then
-- 		mod:echo(k)
-- 	end
-- end

widgets[#widgets + 1] = {
	setting_id = "ping_mute_enemies",
	type = "checkbox",
	default_value = false,
	sub_widgets = {
		{
			setting_id = "ping_unmute_enemies_behind",
			type = "checkbox",
			default_value = false,
		},
	},
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_items",
	type = "checkbox",
	default_value = false,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_ping",
	type = "checkbox",
	default_value = false,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_attention",
	type = "checkbox",
	default_value = false,
}
widgets[#widgets + 1] = {
	setting_id = "ping_mute_location_threat",
	type = "checkbox",
	default_value = false,
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
}

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = widgets,
	},
}
