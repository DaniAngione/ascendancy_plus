local Entity = _radiant.om.Entity

local HarvestFieldBasic = radiant.class()
HarvestFieldBasic.name = 'harvest field basic'
HarvestFieldBasic.status_text_key = 'stonehearth:ai.actions.status_text.harvest_field'
HarvestFieldBasic.does = 'ascendancy_plus:harvest_field_basic'
HarvestFieldBasic.args = {}
HarvestFieldBasic.priority = 0

local function _is_farm_field_harvestable(player_id, entity)
   if not entity or not entity:is_valid() then
      return false
   end
   if entity:get_uri() ~= 'stonehearth:farmer:field_layer:harvestable' then
      return false -- not a farm
   end

   local farm_player_id = radiant.entities.get_player_id(entity)
   if player_id ~= farm_player_id then
      return false -- not our farm
   end

   local farmer_field_component = entity:get_component('stonehearth:farmer_field_layer'):get_farmer_field()
   if not farmer_field_component then
      return false -- no farmer field component
   end

   local crop_details = farmer_field_component:get_crop_details()
   for _, crop in ipairs(stonehearth.constants.farming.BASIC_CROPS) do
      if crop == crop_details.uri then
         return true 
      end
   end

   return false
end

function HarvestFieldBasic:start_thinking(ai, entity, args)
   local player_id = radiant.entities.get_player_id(entity)
   
   local filter_fn = stonehearth.ai:filter_from_key('ascendancy_plus:harvest_field_basic', player_id, function(item)
         return _is_farm_field_harvestable(player_id, item)
      end)

   ai:set_think_output({ filter_fn = filter_fn })
end

local ai = stonehearth.ai
return ai:create_compound_action(HarvestFieldBasic)
         :execute('stonehearth:wait_for_town_inventory_space')
         :execute('stonehearth:find_best_reachable_entity_by_type', {
            filter_fn = ai.BACK(2).filter_fn,
            rating_fn = stonehearth.farming.rate_field,
            description = 'find harvest layer',
         })
         :execute('stonehearth:find_path_to_reachable_entity', {
            destination = ai.PREV.item
         })
         :execute('stonehearth:follow_path', {
            path = ai.PREV.path,
            stop_distance = ai.CALL(radiant.entities.get_harvest_range, ai.ENTITY),
         })
         :execute('stonehearth:reserve_entity_destination', {
            entity = ai.BACK(3).item,
            location = ai.BACK(2).path:get_destination_point_of_interest()
         })
         :execute('stonehearth:register_farm_field_worker', {
            field_layer = ai.BACK(4).item
         })
         :execute('stonehearth:harvest_crop_adjacent', {
            field_layer = ai.BACK(5).item,
            location = ai.BACK(2).location,
         })
         :execute('stonehearth:trigger_event', {
            source = stonehearth.personality,
            event_name = 'stonehearth:journal_event',
            event_args = {
               entity = ai.ENTITY,
               description = 'harvest_entity',
            },
         })
         :execute('stonehearth:drop_carrying_if_stacks_full', {})
