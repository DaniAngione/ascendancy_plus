local Point3 = _radiant.csg.Point3
local Cube3 = _radiant.csg.Cube3
local Region3 = _radiant.csg.Region3

local log = radiant.log.create_logger('build_chopping_block')

local build_chopping_block = {}

function build_chopping_block.on_initialize(entity)
end

return build_chopping_block