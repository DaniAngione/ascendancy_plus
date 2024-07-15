local Entity = _radiant.om.Entity
local validator = radiant.validator

local ChoppingBlockCallHandler = class()

function ChoppingBlockCallHandler:add_to_chopping_block_queue(session, response, entity, value)
   validator.expect_argument_types({'Entity'}, entity)

   local chopping_block_component = entity:get_component('ascendancy_plus:chopping_block')
   if chopping_block_component then
      chopping_block_component:_set_queue(chopping_block_component:_get_queue() + value, true)
   else
      return false
   end
end

return ChoppingBlockCallHandler