local mod = get_mod("NoTaggingSound")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
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
			},
			{
				setting_id = "ping_mute_items",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_ping",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_attention",
				type = "checkbox",
				default_value = false,
			},
			{
				setting_id = "ping_mute_location_threat",
				type = "checkbox",
				default_value = false,
			},
			{
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
			},
		},
	},
}
