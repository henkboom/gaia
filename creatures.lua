require 'dokidoki.module'
[[ make_predator ]]

local v2 = require 'dokidoki.v2'

import 'gl'

local C = require 'constants'

function make_predator(game, _pos)
  local self = {}
  self.pos = _pos

  local angle = 0
  local turn = 0
  local tail = nil

  function self.update()
    if not tail then
      tail = make_predator_cell(game, self.pos, self, 20)
      game.add_actor(tail)
    end

    turn = (turn + (math.random() - 0.5) * math.pi/128) * 0.99
    turn = math.max(-math.pi/32, math.min(turn, math.pi/32))
    angle = angle + turn

    if self.pos.x < 0        then angle = 0 end
    if self.pos.x > C.width  then angle = math.pi end
    if self.pos.y < 0        then angle = math.pi/2 end
    if self.pos.y > C.height then angle = 3 * math.pi/2 end

    self.pos = self.pos + v2.unit(angle) * 2
  end

  function self.draw_outline()
    glColor3d(1.0, 0.4, 0.7)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    game.resources.predator_outline:draw()
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    game.resources.predator_fill:draw()
  end

  return self
end

function make_predator_cell(game, _pos, head, length)
  local self = {}
  self.pos = _pos

  local angle = 0
  local tail = nil

  function self.update()
    if not tail and length > 1 then
      tail = make_predator_cell(game, self.pos, self, length-1)
      game.add_actor(tail)
    end

    if v2.mag(self.pos - head.pos) > 7 then
      self.pos = head.pos + v2.norm(self.pos - head.pos) * 7
      angle = math.atan2(head.pos.y - self.pos.y, head.pos.x - self.pos.x)
    end
  end

  function self.draw_outline()
    glColor3d(1.0, 0.4, 0.7)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    game.resources.predator_outline:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    game.resources.predator_fill:draw()
  end

  return self
end

return get_module_exports()
