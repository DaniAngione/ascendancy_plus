local EquipmentPieceComponent = require 'stonehearth.components.equipment_piece.equipment_piece_component'

local AcendancyPlusEquipmentPieceComponent = class()

AcendancyPlusEquipmentPieceComponent._ascendancy_plus_old__setup_item_rendering = EquipmentPieceComponent._setup_item_rendering
function AcendancyPlusEquipmentPieceComponent:_setup_item_rendering()
   local combat_equipment = self._json.combat_equipment
   if combat_equipment then
      self._combat_listener = radiant.events.listen(self._sv.owner, 'stonehearth:combat:in_combat_changed', self, self._on_combat_state_changed)
   end

   self:_ascendancy_plus_old__setup_item_rendering()
end

function AcendancyPlusEquipmentPieceComponent:get_combat_equipment()
   return self._json.combat_equipment
end

function AcendancyPlusEquipmentPieceComponent:_on_combat_state_changed()
   local combat_equipment = self:get_combat_equipment()
   local additional_equipment = self:get_additional_equipment()
   local is_in_combat, equipment_component
   if self._sv.owner and self._sv.owner:is_valid() then
      is_in_combat = self._sv.owner:add_component('stonehearth:combat_state'):is_in_combat()
      equipment_component = self._sv.owner:get_component('stonehearth:equipment')
   end

   if combat_equipment and equipment_component and is_in_combat then
      for uri, should_equip in pairs(combat_equipment) do
         if should_equip then
            local old_item = equipment_component:equip_item(uri, false)
            if old_item then
               equipment_component:drop_item(old_item)
            end
         end
      end
   elseif combat_equipment and equipment_component then
      for unequip_uri, _ in pairs(combat_equipment) do
         local old_item = equipment_component:unequip_item(unequip_uri, true)
         if old_item then
            equipment_component:drop_item(old_item)
         end
      end
      if additional_equipment then
         for uri, should_equip in pairs(additional_equipment) do
            if should_equip then
               local old_item = equipment_component:equip_item(uri, false)
               if old_item then
                  equipment_component:drop_item(old_item)
               end
            end
         end
      end
   end
end

return AcendancyPlusEquipmentPieceComponent