math.randomseed(os.time())

local glfw = require 'glfw'
local v2 = require 'dokidoki.v2'

glfw.Disable(glfw.SYSTEM_KEYS)

constants = game.add_component(self, 'constants')
local C = constants

opengl_2d = game.add_component(self, 'dokidoki.opengl_2d', {
  width = C.width,
  height = C.height
})
exit_handler = game.add_component(self, 'dokidoki.exit_handler', {
  exit_on_esc = true
})
keyboard = game.add_component(self, 'dokidoki.keyboard')

resources = game.add_component(self, 'resources')
renderer = game.add_component(self, 'renderer')
sound = game.add_component(self, 'sound')

sensing = game.add_component(self, 'sensing')
sensing_interaction = game.add_component(self, 'sensing_interaction')
tracing = game.add_component(self, 'tracing')

prey_collision = game.add_component(self, 'collision_detection')
foliage_collision = game.add_component(self, 'collision_detection')
carrion_collision = game.add_component(self, 'collision_detection')
interaction_collision = game.add_component(self, 'collision_detection')
predator_collision = game.add_component(self, 'collision_detection')

game.add_component(self, 'sensing_interaction')
game.add_component(self, 'apocalypse_recovery')
game.add_component(self, 'foliage_growth')
game.add_component(self, 'creature_render_setup')
game.add_component(self, 'fast_forward')
game.add_component(self, 'pause')

-- should these functions be here?
function get_bounds_correction(pos)
  return v2(
    pos.x < 0 and 1 or pos.x > C.width and -1 or 0,
    pos.y < 0 and 1 or pos.y > C.height and -1 or 0)
end

function out_of_world(pos, distance)
  return pos.x - distance < C.left_bound or
         pos.x + distance > C.right_bound or
         pos.y - distance < C.lower_bound or
         pos.y + distance > C.upper_bound
end

-- add scavengers
for x = 0, C.width, C.scavenger_cell_size do
  for y = 0, C.height, C.scavenger_cell_size do
    game.add_component(self, 'scavenger', { pos = v2(x, y) })
  end
end

-- add predators
for i = 1, C.initial_predators do
  game.add_component(self, 'predator', {
    pos = v2(math.random() * C.width, math.random() * C.height)
  })
end
 
-- add herbivores
for i = 1, C.initial_herbivores do 
  game.add_component(self, 'herbivore', {
    pos = v2(math.random() * C.width, math.random() * C.height)
  })
end
 
 -- add foliage
 for i = 1, C.initial_foliage do 
   game.add_component(self, 'foliage', {
     pos = v2(math.random() * C.width, math.random() * C.height),
     foliage_type = 'normal'
   })
 end
