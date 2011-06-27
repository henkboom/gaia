local v2 = require 'dokidoki.v2'
local C = game.constants
local predator_countdown = false
local herbivore_countdown = false

function preupdate()
  if game.predator_collision.count() == 0 then
    predator_countdown = predator_countdown or 600
    predator_countdown = predator_countdown - 1
    if predator_countdown <= 0 then
      predator_countdown = nil
      game.add_component(self, 'predator', {
        pos = v2(math.random() * C.width, math.random() * C.height)
      })
    end
  end
  if game.prey_collision.count() == 0 then
    herbivore_countdown = herbivore_countdown or 600
    herbivore_countdown = herbivore_countdown - 1
    if herbivore_countdown <= 0 then
      herbivore_countdown = nil
      game.add_component(self, 'herbivore', {
        pos = v2(math.random() * C.width, math.random() * C.height)
      })
    end
  end
end

