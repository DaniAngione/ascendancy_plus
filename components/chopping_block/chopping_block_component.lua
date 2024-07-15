local rng = _radiant.math.get_default_rng()
local firewood_uri = 'stonehearth_ace:resources:fuel:bundle_of_firewood'

local ChoppingBlockComponent = class()

function ChoppingBlockComponent:initialize()
   self._log = radiant.log.create_logger('chopping_block')
                              :set_entity(self._entity)
end

function ChoppingBlockComponent:activate()
   local inventory = stonehearth.inventory:get_inventory(radiant.entities.get_player_id(self._entity))
   self._tracker = inventory:get_item_tracker('ascendancy_plus:firewood_tracker')
end

function ChoppingBlockComponent:post_activate()
   if not self._timer then
      self._timer = stonehearth.calendar:set_timer('Chopping Block check...', '4m+2m', function()
         self:_check_if_should_start()
      end)
   end

   if not self._sv._added_commands then
      self:_create_commands()
   end
end

function ChoppingBlockComponent:destroy()
   if self._timer then
      self._timer:destroy()
      self._timer = nil
   end
end

function ChoppingBlockComponent:_check_if_should_start()
   local below_limit = self:check_limit()
   local queue_size = 0  

   if self._sv._queue and self._sv._queue > 0 then
      self._log:debug('reconsidered, there is firewood in queue')
      self:_request_transform()
   elseif below_limit then
      self._log:debug('reconsidered, firewood needed')
      self:_set_queue(self:determine_queue_size())
      self:_request_transform()
   else
      self._log:debug('creating long timer')
      
      self._timer = stonehearth.calendar:set_timer('Chopping Block - long timer', '1h+25m', function()
         self:_check_if_should_start()
      end)
   end
end

function ChoppingBlockComponent:check_limit()
   local tracking_data = self._tracker:get_tracking_data()
   local limit = self:_calculate_firewood_limit()
   local count = 0

   if tracking_data and tracking_data:contains(firewood_uri) then
      count = tracking_data:get(firewood_uri).count
   end

   if count and limit and count < self:get_firewood_threshold(limit) then
      return (limit - count)
   end

   return false
end

function ChoppingBlockComponent:determine_queue_size()
   local inventory = stonehearth.inventory:get_inventory(radiant.entities.get_player_id(self._entity))
   local limit = self:_calculate_firewood_limit()
   local chopping_block_amount = 0

   local chopping_blocks = inventory and inventory:get_items_of_type('ascendancy_plus:chopping_block')
   if chopping_blocks and chopping_blocks.items then
      for id, entity in pairs(chopping_blocks.items) do
         if radiant.entities.exists_in_world(entity) then
            chopping_block_amount = chopping_block_amount + 1
         end
      end
   end

   return math.min(limit, math.ceil(limit / chopping_block_amount))
end

function ChoppingBlockComponent:_request_transform()
   local transform_comp = self._entity:get_component('stonehearth_ace:transform')
   if not transform_comp then
      self._log:debug('no transform comp!')
      return
   end
   self._log:debug('transforming!')
   transform_comp:set_transform_option('chop_wood')
   transform_comp:request_transform(radiant.entities.get_player_id(self._entity), true)
end

function ChoppingBlockComponent:_calculate_firewood_limit()
   local inventory = stonehearth.inventory:get_inventory(radiant.entities.get_player_id(self._entity))
   local firewood_limit = 0

   local large_fuel_holders
   for _, uri in ipairs(stonehearth.constants.fuel_holders.large) do
      large_fuel_holders = inventory and inventory:get_items_of_type(uri)
      if large_fuel_holders and large_fuel_holders.items then
         for id, entity in pairs(large_fuel_holders.items) do
            if radiant.entities.exists_in_world(entity) then
               firewood_limit = firewood_limit + 18
            end
         end
      end
   end

   local fuel_holders
   for _, uri in ipairs(stonehearth.constants.fuel_holders.medium) do
      fuel_holders = inventory and inventory:get_items_of_type(uri)
      if fuel_holders and fuel_holders.items then
         for id, entity in pairs(fuel_holders.items) do
            if radiant.entities.exists_in_world(entity) then
               firewood_limit = firewood_limit + 8
            end
         end
      end
   end

   local small_fuel_holders
   for _, uri in ipairs(stonehearth.constants.fuel_holders.small) do
      small_fuel_holders = inventory and inventory:get_items_of_type(uri)
      if small_fuel_holders and small_fuel_holders.items then
         for id, entity in pairs(small_fuel_holders.items) do
            if radiant.entities.exists_in_world(entity) then
               firewood_limit = firewood_limit + 4
            end
         end
      end
   end

   return firewood_limit
end

function ChoppingBlockComponent:get_firewood_threshold(limit)
   return math.max(4, math.ceil((0.75 * limit)))
end

function ChoppingBlockComponent:_create_commands()
   self._sv._added_commands = true
   local commands_component = self._entity:add_component('stonehearth:commands')
   commands_component:add_command('ascendancy_plus:commands:chopping_block:add_1')
   commands_component:add_command('ascendancy_plus:commands:chopping_block:add_2')
   commands_component:add_command('ascendancy_plus:commands:chopping_block:add_5')
   commands_component:add_command('ascendancy_plus:commands:chopping_block:add_10')
end

function ChoppingBlockComponent:_get_queue()
   return self._sv._queue or 0
end

function ChoppingBlockComponent:_set_queue(value, should_check)
   self._sv._queue = value
   self.__saved_variables:mark_changed()

   if should_check then
      self:_check_if_should_start()
   end
end

return ChoppingBlockComponent