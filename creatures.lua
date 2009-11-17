require 'dokidoki.module'
[[ make_predator, make_herbivore ]]

local v2 = require 'dokidoki.v2'

import 'gl'

local C = require 'constants'

function make_predator(game, _pos)
  -- constants
  local min_speed = 1
  local max_speed = 5
  local speed_increment = 0.1

  local self = {}
  self.pos = _pos

  local angle = 0
  local turn = 0
  local tail = nil
  local speed = min_speed

  local function food_direction()
    local left_pos = self.pos + v2.unit(angle + math.pi/6) * 60
    local right_pos = self.pos + v2.unit(angle - math.pi/6) * 60
    local radius = 40
    local left_count = #game.nearby(left_pos, radius, 'prey')
    local right_count = #game.nearby(right_pos, radius, 'prey')

    game.trace_circle(self.pos, left_pos, radius)
    game.trace_circle(self.pos, right_pos, radius)

    if left_count == 0 and right_count == 0 then
      return false
    elseif left_count < right_count then
      return -1
    elseif left_count > right_count then
      return 1
    else
      return 0
    end
  end

  function self.update()
    if not tail then
      tail = make_predator_cell(game, self.pos, self, 20)
      game.add_actor(tail)
    end

    -- handle seeing food
    local fd = food_direction()
    if fd then
      speed = math.min(speed + speed_increment, max_speed)
      turn = turn + fd * math.pi/128
    else
      speed = math.max(speed - speed_increment, min_speed)
    end
    -- add a random component
    turn = turn + (math.random() - 0.5) * math.pi/128
    -- damp it so that they don't spiral too much
    turn = turn * 0.99
    -- clamp it to limit turn speed
    turn = math.max(-math.pi/32, math.min(turn, math.pi/32))

    angle = angle + turn

    if self.pos.x < C.left_bound  then angle = 0 end
    if self.pos.x > C.right_bound then angle = math.pi end
    if self.pos.y < C.lower_bound then angle = math.pi/2 end
    if self.pos.y > C.upper_bound then angle = 3 * math.pi/2 end

    self.pos = self.pos + v2.unit(angle) * speed
  end

  function self.draw_outline()
    glColor3d(1.0, 0.4, 0.7)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(1.25, 1.25, 1)
    game.resources.predator_outline:draw()
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(1.25, 1.25, 1)
    game.resources.predator_fill:draw()
  end

  return self
end

function make_predator_cell(game, _pos, head, length)
  local self = {}
  self.pos = _pos

  local angle = 0
  local tail = nil
  local scale = length / 40 + 0.75
  local follow_distance = 7 * scale

  function self.update()
    if not tail and length > 1 then
      tail = make_predator_cell(game, self.pos, self, length-1)
      game.add_actor(tail)
    end

    if v2.mag(self.pos - head.pos) > follow_distance then
      self.pos = head.pos + v2.norm(self.pos - head.pos) * follow_distance
      angle = math.atan2(head.pos.y - self.pos.y, head.pos.x - self.pos.x)
    end
  end

  function self.draw_outline()
    glColor3d(1.0, 0.4, 0.7)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_outline:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_fill:draw()
  end

  return self
end

function make_herbivore(game, _pos)
	local self = {}
	self.pos = _pos
  self.tags = {'prey'}


	local vel = v2(0,0)
	local target_vel
	local count = 0
	local offset = v2.random() * 4
	
	function self.update()
    if count >0 then
      count= count - 1
    else
      count=30 + math.random(100)
      target_vel = v2.random()
    end
    
    self.pos = self.pos + vel
	  vel = vel * 0.98 + target_vel *0.02
  end
	
	function self.draw_outline()
		glColor3d(0, 1, 0.2)
		game.resources.herbivore_outline:draw()
	  glColor3d(1, 1, 1)
	end
	
	function self.draw_inner_outline()
		glColor3d(0, 0.5, 0.8)
		glTranslated(offset.x,offset.y,0)
		game.resources.herbivore_inner_outline:draw()
	  glColor3d(1, 1, 1)
	end
	
	function self.draw_fill()
    game.resources.herbivore_fill:draw()
  end
  
  function self.draw_inner_fill()
    glTranslated(offset.x,offset.y,0)
    game.resources.herbivore_inner_fill:draw()
  end
	
	return self
end

return get_module_exports()
