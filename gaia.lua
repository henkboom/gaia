math.randomseed(os.time())

local v2 = require 'dokidoki.v2'

opengl_2d = game.add_component(self, 'dokidoki.opengl_2d', {
  width = 800,
  height = 600
})
exit_handler = game.add_component(self, 'dokidoki.exit_handler', {
  exit_on_esc = true
})
keyboard = game.add_component(self, 'dokidoki.keyboard')

constants = game.add_component(self, 'constants')
resources = game.add_component(self, 'resources')
tracing = game.add_component(self, 'tracing')
sound = game.add_component(self, 'sound')
sensing = game.add_component(self, 'sensing')
renderer = game.add_component(self, 'renderer')
collision_detection = game.add_component(self, 'collision_detection', {
  types = {'prey', 'foliage', 'carrion', 'interactive'}
})

game.add_component(self, 'sensing_interaction')
game.add_component(self, 'apocalypse_recovery')
game.add_component(self, 'foliage_growth')
game.add_component(self, 'creature_render_setup')

local C = constants

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

-- -- add scavengers
-- for x = 0, C.width, C.scavenger_cell_size do
--   for y = 0, C.height, C.scavenger_cell_size do
--     game.add_actor(creatures.make_scavenger(game,v2(x, y)))
--   end
-- end

-- -- add predators
-- for i = 1, 3 do
--   game.add_actor(creatures.make_predator(
--     game,
--     v2(math.random() * C.width, math.random() * C.height)))  
-- end
 
-- -- add herbivores
-- for i = 1, 18 do 
--   game.add_actor(creatures.make_herbivore(
--     game,
--     v2(math.random() * C.width, math.random() * C.height)))  
-- end
 
 -- add foliage
 for i = 1, 70 do 
   game.add_component(self, 'foliage', {
     pos = v2(math.random() * C.width, math.random() * C.height),
     foliage_type = 'normal'
   })
 end
