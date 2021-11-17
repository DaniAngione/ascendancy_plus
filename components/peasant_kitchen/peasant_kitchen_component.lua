local PeasantKitchenComponent = class()

function PeasantKitchenComponent:initialize()
   self._log = radiant.log.create_logger('peasant_kitchen')
                              :set_entity(self._entity)
end

function PeasantKitchenComponent:restore()
   if self._anytime then
      self:_start_cooking()
   end
end

function PeasantKitchenComponent:activate()
   local json = radiant.entities.get_json(self) or {}
   self._anytime = json.anytime or nil
   self._log:debug('creating alarms')

   local calendar_constants = stonehearth.calendar:get_constants()
   local event_times = calendar_constants.event_times
   local jitter = '+10m'

   if not self._sunrise_alarm then
      local sunrise_alarm_time = stonehearth.calendar:format_time(event_times.sunrise) .. jitter
      self._sunrise_alarm = stonehearth.calendar:set_alarm(sunrise_alarm_time, function()
            self:_start_cooking()
         end)
   end

   if anytime then
      self:_start_cooking()
   end
end

function PeasantKitchenComponent:destroy()
   self._log:debug('destroy')

   if self._sunrise_alarm then
      self._sunrise_alarm:destroy()
      self._sunrise_alarm = nil
   end
end

function PeasantKitchenComponent:_start_cooking()
   self._log:debug('grabbing inventory')
   local inventory = stonehearth.inventory:get_inventory(radiant.entities.get_player_id(self._entity))
   local usable_item_tracker = inventory:get_item_tracker('stonehearth:usable_item_tracker')
   local transform_comp = self._entity:get_component('stonehearth_ace:transform')
   if not transform_comp:is_transformable() then
      self._log:debug('no transform comp!')
      return
   end
   local data = radiant.entities.get_entity_data(self._entity, 'stonehearth_ace:transform_data').transform_options
   local possibilities = {}

   for option, info in pairs(data) do
      local ingredient_material = info.transform_ingredient_material or nil
      local ingredient_uri = info.transform_ingredient_uri or nil
      if ingredient_material then
         if usable_item_tracker and usable_item_tracker:contains_item_with_material(ingredient_material) then
            table.insert(possibilities, option)
         end
      else
         if inventory and inventory:get_items_of_type(ingredient) then
            table.insert(possibilities, option)
         end
      end
   end

   self._log:debug('choosing a possibility')
   local chosen_possibility = possibilities[math.random(1, #possibilities)]
   transform_comp:set_transform_option(chosen_possibility)
end

return PeasantKitchenComponent
