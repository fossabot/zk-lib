data:extend({
	-- {
	-- 	type = "bool-setting",
	-- 	name = "zk_commands",
	-- 	setting_type = "runtime-global",
	-- 	default_value = true
	-- },
	{
		type = "bool-setting",
		name = "EL_debug-mode",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "EL_logs-mode",
		setting_type = "runtime-global",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "zk-lib_special-message",
		setting_type = "runtime-per-user",
		default_value = true
	}
})

local addons_list = require("addons/addons-list")

addons_settings = {}
for name, _ in pairs(addons_list) do
	table.insert(addons_settings, {
		type = "string-setting",
		name = "zk-lib_" .. name,
		setting_type = "startup",
		default_value = "disabled",
		allowed_values = {"disabled", "enabled", "mutable"},
    localised_name = {"mod-name." .. name},
    localised_description = {"mod-description." .. name}
	})
end
data:extend(addons_settings)

require("addons/settings/scan-rocket-with-radars")
