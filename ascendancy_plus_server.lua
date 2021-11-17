ascendancy_plus = {}

local service_creation_order = {}

local monkey_patches = {
   ascendancy_plus_town = 'stonehearth.services.server.town.town',
   ascendancy_plus_job_info_controller = 'stonehearth.services.server.job.job_info_controller',
   --ascendancy_plus_job_service = 'stonehearth.services.server.job.job_service' --Commented out to allow "Level 1 Farmer" crops to be locked for Peasants
}

local function monkey_patching()
   for from, into in pairs(monkey_patches) do
      local monkey_see = require('monkey_patches.' .. from)
      local monkey_do = radiant.mods.require(into)
      radiant.log.write_('ascendancy_plus', 0, 'Ascendancy+ Mod server monkey-patching sources \'' .. from .. '\' => \'' .. into .. '\'')
      radiant.mixin(monkey_do, monkey_see)
   end
end

local function create_service(name)
   local path = string.format('services.server.%s.%s_service', name, name)
   local service = require(path)()
	
   local saved_variables = ascendancy_plus._sv[name]
   if not saved_variables then
      saved_variables = radiant.create_datastore()
      ascendancy_plus._sv[name] = saved_variables
   end

   service.__saved_variables = saved_variables
   service._sv = saved_variables:get_data()
   saved_variables:set_controller(service)
   saved_variables:set_controller_name('ascendancy_plus:' .. name)
   service:initialize()
   ascendancy_plus[name] = service
end

function ascendancy_plus:_on_init()
   ascendancy_plus._sv = ascendancy_plus.__saved_variables:get_data()

   for _, name in ipairs(service_creation_order) do
      create_service(name)
   end

   radiant.events.trigger_async(radiant, 'ascendancy_plus:server:init')
   radiant.log.write_('ascendancy_plus', 0, 'Ascendancy+ Mod server initialized')
end

function ascendancy_plus:_on_required_loaded()
	monkey_patching()
   
   radiant.events.trigger_async(radiant, 'ascendancy_plus:server:required_loaded')
end

radiant.events.listen(ascendancy_plus, 'radiant:init', ascendancy_plus, ascendancy_plus._on_init)
radiant.events.listen(radiant, 'stonehearth_ace:server:required_loaded', ascendancy_plus, ascendancy_plus._on_required_loaded)

return ascendancy_plus
