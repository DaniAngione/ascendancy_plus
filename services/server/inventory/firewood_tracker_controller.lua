local entity_forms_lib = require 'stonehearth.lib.entity_forms.entity_forms_lib'
local FirewoodTracker = class()

function FirewoodTracker:create_key_for_entity(entity, storage)
   local uri = entity:get_uri()
   if uri == 'stonehearth_ace:resources:fuel:bundle_of_firewood' then
      return uri
   end

   return nil
end

function FirewoodTracker:add_entity_to_tracking_data(entity, tracking_data)
   if not tracking_data then
      --create the tracking data for this type of object

      tracking_data = {
         uri = entity:get_uri(),
         count = 0,
         items = {}
      }
   end

   local id = entity:get_id()
   if not tracking_data.items[id] then
      tracking_data.count = tracking_data.count + 1
      tracking_data.items[id] = entity
   end

   return tracking_data
end

function FirewoodTracker:remove_entity_from_tracking_data(entity_id, tracking_data)
   if not tracking_data then
      return nil
   end

   if tracking_data.items[entity_id] then
      tracking_data.items[entity_id] = nil
      tracking_data.count = tracking_data.count - 1
   end

   return tracking_data
end

return FirewoodTracker