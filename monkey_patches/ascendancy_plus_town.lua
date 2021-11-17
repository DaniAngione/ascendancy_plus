local AscendancyPlusTown = class()

function AscendancyPlusTown:enable_town_alert()
   self:_destroy_town_alert_thoughts()
   self:_destroy_town_alert_tasks()
   self:_clear_town_alert_leashes()

   local citizens = self:get_citizens()
   for id, citizen in citizens:each() do
      local jc = citizen:get_component('stonehearth:job')
      if jc and not jc:has_role('combat') then
         stonehearth.combat:set_panicking_from(citizen, nil)
         local thought = citizen:add_component('stonehearth:thought_bubble')
               :add_bubble('stonehearth:effects:thoughts:alert',
                           stonehearth.constants.thought_bubble.priorities.TOWN_ALERT)

         table.insert(self._town_alert_thoughts, thought)
         radiant.entities.add_buff(citizen, 'stonehearth:buffs:minor_courage_buff')
         stonehearth.combat:set_stance(citizen, 'aggressive')
         if jc:has_role('worker_job') and citizen:get_component('stonehearth:equipment') then
            local ec = citizen:get_component('stonehearth:equipment')
            for item, buff in pairs(stonehearth.constants.combat.town_alert_equipment_buffs) do
               if ec:has_item_type(item) then
                  radiant.entities.add_buff(citizen, buff)
               end
            end
         end
      end
   end

   local tasks = self:_create_town_alert_tasks()
   self._town_alert_tasks = tasks

   self._sv.town_alert_enabled = true
   radiant.events.trigger_async(self, 'stonehearth:town_alert:alert_enabled', { enabled = true })

   self.__saved_variables:mark_changed()
end

function AscendancyPlusTown:disable_town_alert()
   self:_destroy_town_alert_thoughts()
   self:_destroy_town_alert_tasks()
   self:_clear_town_alert_leashes()

   for _, citizen in self:get_citizens():each() do
      radiant.entities.remove_buff(citizen, 'stonehearth:buffs:defender', true);
      radiant.entities.remove_buff(citizen, 'stonehearth:buffs:minor_courage_buff', true)
      radiant.entities.remove_buff(citizen, 'stonehearth:buffs:town_alert_courage', true)
      for _, buff in pairs(stonehearth.constants.combat.town_alert_equipment_buffs) do
         radiant.entities.remove_buff(citizen, buff, true)
      end

      local jc = citizen:add_component('stonehearth:job')
      if not jc:has_role('combat') then
         radiant.entities.unset_posture(citizen, 'stonehearth:combat')
         jc:reset_to_default_combat_stance()
      end
   end

   self._sv.town_alert_enabled = false
   radiant.events.trigger_async(self, 'stonehearth:town_alert:alert_enabled', { enabled = false })

   self.__saved_variables:mark_changed()
end

return AscendancyPlusTown
