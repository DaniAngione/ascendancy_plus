local FarmingBasicTaskGroup = class()
FarmingBasicTaskGroup.name = 'farming_basic_harvest'
FarmingBasicTaskGroup.does = 'stonehearth:work'
FarmingBasicTaskGroup.priority = {0.48, 0.56}

return stonehearth.ai:create_task_group(FarmingBasicTaskGroup)
         :work_order_tag("job")
         -- Plant and till HAVE TO BE THE SAME or the performance implications are staggering -yshan
         -- TODO: Is the above still true?
         :declare_permanent_task('ascendancy_plus:harvest_field_basic', {}, 1)
         :declare_permanent_task('stonehearth:harvest_resource', { category = "harvest" }, {0.5, 1.0})
         :declare_permanent_task('stonehearth:harvest_renewable_resource', { category = "harvest" }, {0.5, 1.0})         