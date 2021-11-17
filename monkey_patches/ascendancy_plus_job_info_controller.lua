local AscendancyPlusJobInfoController = class()

local log = radiant.log.create_logger('job_info')

AscendancyPlusJobInfoController._ascendancy_plus_old_manually_unlock_crop = AscendancyPlusJobInfoController.manually_unlock_crop
function AscendancyPlusJobInfoController:manually_unlock_crop(crop_key, ignore_missing)
   if self._sv.alias ~= 'stonehearth:jobs:farmer' or self._sv.alias ~= 'stonehearth:jobs:worker' then
      radiant.verify(false, "Attempting to manually unlock crop %s when job %s does not have crops!", crop_key, self._sv.alias)
      return false
   end
   local found_crop = false

   local crop_list = radiant.resources.load_json('stonehearth:farmer:all_crops').crops
   if not crop_list[crop_key] then
      if not ignore_missing then
         radiant.verify(false, "Attempting to manually unlock crop %s when job %s does not have such a crop!", crop_key, self._sv.alias)
      end
      return false
   end

   local already_unlocked = self._sv.manually_unlocked[crop_key]
   if already_unlocked then
      return false
   end

   self._sv.manually_unlocked[crop_key] = true
   self.__saved_variables:mark_changed()
   return true
end

return AscendancyPlusJobInfoController
