local rng = _radiant.math.get_default_rng()

local AcendancyPlusEquipmentComponent = class()

function AcendancyPlusEquipmentComponent:equip_item(item, destroy_old_item)
   destroy_old_item = destroy_old_item ~= false

   if type(item) == 'string' then
      item = radiant.entities.create_entity(item)
   elseif type(item) == 'table' then
      item = radiant.entities.create_entity(item[rng:get_int(1, #item)])
   end

   local inventory = stonehearth.inventory:get_inventory(radiant.entities.get_player_id(self._entity))
   if inventory then
      inventory:remove_item(item:get_id())
   end

   radiant.check.is_entity(item)
   local proxy = item:get_component('stonehearth:iconic_form')
   if proxy then
      item = proxy:get_root_entity()
   end
   local ep = item:get_component('stonehearth:equipment_piece')
   assert(ep, 'item is not an equipment piece')

   radiant.entities.set_player_id(item, self._entity)

   local slot = ep:get_slot()

   if not slot then
      slot = 'no_slot_' .. self._sv.no_slot_counter
      self._sv.no_slot_counter = self._sv.no_slot_counter + 1
   end

   local unequipped_item = self._sv.equipped_items[slot]
   if unequipped_item then
      local also_unequipped = unequipped_item:get_component('stonehearth:equipment_piece'):get_additional_equipment()
      local also_unequipped_combat = unequipped_item:get_component('stonehearth:equipment_piece'):get_combat_equipment()
      self:unequip_item(unequipped_item)
      if also_unequipped then
         for unequip_uri, _ in pairs(also_unequipped) do
            local old_item = self:unequip_item(unequip_uri, true)
            if old_item then
               self:drop_item(old_item)
            end
         end
      end
      if also_unequipped_combat then
         for unequip_uri, _ in pairs(also_unequipped_combat) do
            local old_item = self:unequip_item(unequip_uri, true)
            if old_item then
               self:drop_item(old_item)
            end
         end
      end
   end

   local additional_equipment = ep:get_additional_equipment()
   if additional_equipment then
      for uri, should_equip in pairs(additional_equipment) do
         if should_equip then
            local old_item = self:equip_item(uri, false)
            if old_item then
               self:drop_item(old_item)
            end
         end
      end
   end

   self._sv.equipped_items[slot] = item

   ep:equip(self._entity)

   if destroy_old_item and unequipped_item then
      radiant.entities.destroy_entity(unequipped_item)
   end

   self.__saved_variables:mark_changed()
   self:_trigger_equipment_changed()

   return unequipped_item, item
end

return AcendancyPlusEquipmentComponent
