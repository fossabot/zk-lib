--[[
Copyright (c) 2018-2020 ZwerOxotnik <zweroxotnik@gmail.com>
Licensed under the MIT licence;
]]--

local module = {}
module.events = {}

local function find_near_enemy(created_entity)
	local created_entity_force = created_entity.force
	local x, y = created_entity.position.x, created_entity.position.y
	local r = settings.global["restrict_building_radius"].value
	local near_entities = created_entity.surface.find_entities({{x - r, y - r}, {x + r, y + r}})

	for _, entity in pairs(near_entities) do
		local entity_force = entity.force
		if (entity and entity_force ~= created_entity_force
			and entity_force.name ~= "neutral"
			and not created_entity_force.get_cease_fire(entity_force)) then
			return true
		end
	end
	return false
end

local function on_built_entity(event)
	if settings.global["restrict_building_radius"].value == 0 then return end
	local created_entity = event.created_entity
	if not (created_entity and created_entity.valid) then return end
	if created_entity.force.name == "neutral" then return end
	local player = game.players[event.player_index]
	if not (player and player.valid) then return end
	if not (player.controller_type == defines.controllers.character or player.controller_type == defines.controllers.god) then return end

	if not find_near_enemy(created_entity) then return end

	if event.player_index and event.item and created_entity.type ~= "entity-ghost" then
		player.insert{name = event.item.name}
		rendering.draw_text{
			text = {"messages.warning_restricted_building"},
			surface = created_entity.surface,
			target = created_entity.position,
			players = {player},
			visible = true,
			alignment = "center",
			time_to_live = 60 * 3,
			color = {r = 1, g = 0, b = 0, a = 0.5}
		}
	end
	created_entity.destroy()
end

local function on_robot_built_entity(event)
	local created_entity = event.created_entity
	if not (created_entity and created_entity.valid) then return end
	if created_entity.force.name == "neutral" then return end

	if not find_near_enemy(created_entity) then return end
	rendering.draw_text{
		text = {"messages.warning_restricted_building"},
		surface = created_entity.surface,
		target = created_entity.position,
		forces = {created_entity.force},
		visible = true,
		alignment = "center",
		time_to_live = 60 * 3,
		color = {r = 1, g = 0, b = 0, a = 0.5}
	}
	created_entity.destroy()
end

-- local function on_runtime_mod_setting_changed(event)
--     if event.setting_type ~= "runtime-global" then return end

--     if event.setting == "restrict_building_radius" then
--         if settings.global[event.setting].value > 0 then
--             module.events[defines.events.on_built_entity] = restrict_building_on_built_entity
--             module.events[defines.events.on_robot_built_entity] = restrict_building_on_built_entity
--         else
--             module.events[defines.events.on_built_entity] = function() end
--             module.events[defines.events.on_robot_built_entity] = function() end
--         end
--         event_listener.update_event(lib, defines.events.on_built_entity)
-- 		event_listener.update_event(lib, defines.events.on_robot_built_entity)
--     end
-- end

module.get_default_events = function()
	local events = {
		[defines.events.on_built_entity] = on_built_entity,
		[defines.events.on_robot_built_entity] = on_robot_built_entity
		-- module.events[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
	}

	local on_nth_tick = {}

	return events, on_nth_tick
end

return module
