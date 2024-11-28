local dmf = get_mod("DMF")

local util = {}

-- ╔═╗┬ ┬┌┐┌┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
-- ╠╣ │ │││││   │ ││ ││││└─┐
-- ╚  └─┘┘└┘└─┘ ┴ ┴└─┘┘└┘└─┘

local function local_player()
	local player = Managers.player:local_player(1)
	return player and player.player_unit
	-- local manager = Managers.player
	-- if manager then
	-- 	local player = manager:local_player(1)
	-- 	return player and player.player_unit
	-- end
end
util.player = local_player

util.smart_tag = function(template_name, tagger_unit, target_unit, target_location)
	local smart_tag_extension = Managers.state.extension:system("smart_tag_system")
	if target_unit then
		smart_tag_extension:set_contextual_unit_tag(tagger_unit, target_unit)
	else
		smart_tag_extension:set_tag(template_name, tagger_unit, nil, target_location)
	end
end

local function increment_wrap(limit, i, inc)
	i = i + (inc or 1)
	i = (i - 1) % limit + 1
	return i
end

local Store = {}
function Store:new(name) return setmetatable(dmf:persistent_table(name), self) end
function Store:__index(key) return rawget(self, key) end
function Store:__newindex(key, value) rawset(self, key, value) end
Store.get = Store.__index
function Store:cycle(key, list, increment)
	local list_index = rawget(self, key) or 1
	if increment then
		list_index = increment_wrap(#list, list_index, increment) --(list_index + increment - 1) % #list + 1
		self.store[name] = list_index
	end
	local value = list[list_index]
	-- dmf:echo("%s[%d] == %s", name, list_index, value)
	return value
end

local v = Store:new("VARIABLES")
v.fav_color = "reeeeeeeed"
v.name = "Merldadadadoni"
v.age = 4444444

dmf:echo(v.name)

local Variables = dmf:persistent_table("VARIABLES")
-- dmf:dtf(Variables, "ierjgiuejgie_2", 5)
util.get = function(name) return Variables[name] end
util.set = function(name, value) Variables[name] = value end

-- ╔╦╗┌─┐┌┐ ┬ ┬┌─┐
--  ║║├┤ ├┴┐│ ││ ┬
-- ═╩╝└─┘└─┘└─┘└─┘

local Debug = {
	store = dmf:persistent_table("DEBUG"),
	radii = { 0.1, 0.2, 0.5, 1, 2.0 },
}
util.debug = Debug

function Debug:_line_obj(name, world)
	-- Line object management
	local line_name = "line_" .. name
	local obj = self.store[line_name]
	if not obj then
		obj = world:create_line_object()
		self.store[line_name] = obj
	end
	return obj
end

function Debug:set(name, newvalue)
	local value = self.store[name]
	if value == newvalue then return false end

	self.store[name] = newvalue
	-- dmf:echo("%s CHANGED TO %s", name, newvalue)
	return true
end

function Debug:get_cycle(name, list, inc)
	local list_index = self.store[name] or 1
	if inc then
		list_index = (list_index % #list) + 1
		self.store[name] = list_index
	end
	local value = list[list_index]
	-- dmf:echo("%s[%d] == %s", name, list_index, value)
	return value
end

function Debug:draw_sphere(name, pos, color, radius)
	local player = local_player()
	if not player then return end

	local world = Unit.world(player)
	local line = self:_line_obj(name, world)
	radius = radius or self:get_cycle(name .. "radius", self.radii, not self:set(name .. "pos", pos))

	if pos.unbox then pos = pos:unbox() end

	LineObject.reset(line)
	LineObject.add_sphere(line, color, pos, radius, 30, 30)
	LineObject.dispatch(world, line)
end

return util
