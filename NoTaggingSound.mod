return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`NoTaggingSound` encountered an error loading the Darktide Mod Framework.")

		new_mod("NoTaggingSound", {
			mod_script       = "NoTaggingSound/scripts/NoTaggingSound",
			mod_data         = "NoTaggingSound/scripts/NoTaggingSound_data",
			mod_localization = "NoTaggingSound/scripts/NoTaggingSound_localization",
		})
	end,
	packages = {},
}
