local ace_transform_lib = require 'stonehearth_ace.lib.transform.transform_lib'

local ascendancy_plus_transform_lib = {}

local log = radiant.log.create_logger('transform_lib')

ascendancy_plus_transform_lib._ascendancy_plus_old_transform = ace_transform_lib.transform
function ascendancy_plus_transform_lib.transform(entity, transform_source, into_uri, options)
   local chopping_block_component = entity:get_component('ascendancy_plus:chopping_block')
   if chopping_block_component then 
      local chopping_block_queue = chopping_block_component:_get_queue()

      local transformed_form = ascendancy_plus_transform_lib._ascendancy_plus_old_transform(entity, transform_source, into_uri, options)

      local transformed_form_chopping_block_component = transformed_form:add_component('ascendancy_plus:chopping_block')
      if transformed_form_chopping_block_component then 
         transformed_form_chopping_block_component:_set_queue(math.max(0, chopping_block_queue - 1))
      end
      return transformed_form
   else
      return ascendancy_plus_transform_lib._ascendancy_plus_old_transform(entity, transform_source, into_uri, options)
   end
end

return ascendancy_plus_transform_lib