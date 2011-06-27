local v2 = require 'dokidoki.v2'
local C = game.constants

function update()
    if math.random(100) <= 9 then
      game.add_component(game, 'foliage', {
        pos = v2(math.random() * C.width, math.random() * C.height),
        foliage_type = 'normal'
      })
    end
end
