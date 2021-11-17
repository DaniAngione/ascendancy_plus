local FarmingBasicTaskGroup = class()
FarmingBasicTaskGroup.name = 'farming_basic'
FarmingBasicTaskGroup.does = 'stonehearth:work'
FarmingBasicTaskGroup.priority = {0.48, 0.56}

return stonehearth.ai:create_task_group(FarmingBasicTaskGroup)
         :work_order_tag("job")
         :declare_permanent_task('ascendancy_plus:plant_crop_basic', {}, 0)
         :declare_permanent_task('stonehearth:till_entire_field', {}, 0)
         :declare_permanent_task('stonehearth:harvest_field', {}, 1)
         :declare_permanent_task('ascendancy_plus:harvest_field_basic', {}, 1)
         