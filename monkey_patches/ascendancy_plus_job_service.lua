local JobService = require 'stonehearth.services.server.job.job_service'
local AscendancyPlusJobService = class()

AscendancyPlusJobService._ascendancy_plus_old_get_job_info = JobService.get_job_info
function AscendancyPlusJobService:get_job_info(player_id, job_id, population_override)
   local kingdom = stonehearth.player:get_kingdom(player_id)
   if kingdom == "ascendancy_plus:kingdoms:ascendancy_plus" and job_id == "stonehearth:jobs:farmer" then
      return self:_ascendancy_plus_old_get_job_info(player_id, "stonehearth:jobs:worker", population_override)
  else
      return self:_ascendancy_plus_old_get_job_info(player_id, job_id, population_override)
 end
end

return AscendancyPlusJobService
