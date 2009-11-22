require 'dokidoki.module'
[[ make_predator, make_herbivore, make_foliage ]]

local v2 = require 'dokidoki.v2'
local C = require 'constants'
import 'gl'

--- Predator Head ------------------------------------------------------------

function make_predator(game, _pos)
  -- constants
  local min_speed = 1
  local max_speed = 5.5
  local speed_increment = 0.1
  local max_turn_speed = math.pi/64
  local turn_speed_factor = math.pi/256

  local self = {}
  self.pos = _pos

  local angle = 0
  local turn = 0
  local tail = nil
  local speed = min_speed
  local length = math.random(4, 30)
  local scale = length / 150 + 0.5
  
  local attacking =false

  local function food_direction()
    local left_pos = self.pos + v2.unit(angle + math.pi/6) * 90
    local right_pos = self.pos + v2.unit(angle - math.pi/6) * 90
    local radius = 60
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

  local function eat()
    local eat_radius = 20
    game.trace_circle(self.pos, self.pos, eat_radius)
    local food = game.nearby(self.pos, eat_radius, 'prey')
    for _, f in ipairs(food) do
      game.resources.predator_eat:play(.08)
      f.is_dead = true      
    end
  end

  function self.update()
    if not tail then
      tail = make_predator_cell(game, self.pos, self, length-1)
      game.add_actor(tail)
    end

    -- handle seeing food
    local fd = food_direction()
    if fd then
      -- play sound when on the attack
      if attacking == false then
        game.resources.predator_attack:play(.04)
        attacking=true
      end
      speed = math.min(speed + speed_increment, max_speed)
      turn = turn + fd * turn_speed_factor
    else
      speed = math.max(speed - speed_increment, min_speed)
      attacking = false
    end
    -- add a random component
    turn = turn + (math.random() - 0.5) * turn_speed_factor
    -- damp it so that they don't spiral too much
    turn = turn * 0.99
    -- clamp it to limit turn speed
    turn = math.max(-max_turn_speed, math.min(turn, max_turn_speed))

    angle = angle + turn
    if self.pos.x < C.left_bound  then angle = 0 end
    if self.pos.x > C.right_bound then angle = math.pi end
    if self.pos.y < C.lower_bound then angle = math.pi/2 end
    if self.pos.y > C.upper_bound then angle = 3 * math.pi/2 end
    self.pos = self.pos + v2.unit(angle) * speed

    eat()
  end

  function self.draw_outline()
    glColor3d(1.0, 0.4, 0.7)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_outline:draw()
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_fill:draw()
  end

  return self
end

--- Predator Cell ------------------------------------------------------------

function make_predator_cell(game, _pos, head, length)
  local self = {}
  self.pos = _pos

  local angle = 0
  local tail = nil
  local scale = length / 150 + 0.25
  local follow_distance = 40 * scale

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

--- Herbivore ----------------------------------------------------------------

function make_herbivore(game, _pos)
	local self = {}
	self.pos = _pos
  self.tags = {'prey'}

	local vel = v2(0,0)
	local target_vel
	local count = 0
	local offset = v2.random() * 4
	local reproduce_timer = math.random(800)
	local hunger = 0.5
	
	local function eat()
    local eat_radius = 20
    --game.trace_circle(self.pos, self.pos, eat_radius)
    local food = game.nearby(self.pos, eat_radius, 'foliage')
    
    for _, f in ipairs(food) do
      
      -- random sound played for eating (1-5)
      local random_num = math.random(5)
      if random_num == 1 then
        game.resources.herbivore_eat1:play(.02)
      elseif random_num == 2 then
        game.resources.herbivore_eat2:play(.02)
      elseif random_num == 3 then
        game.resources.herbivore_eat3:play(.02)
      elseif random_num == 4 then
        game.resources.herbivore_eat4:play(.02)
      else
        game.resources.herbivore_eat5:play(.02)
      end

      hunger =  hunger + 0.28
      f.is_dead = true
    end
  end
  
  local function reproduce()
    game.resources.herbivore_reproduce:play(.25)
    game.add_actor(make_herbivore(game, self.pos))
  end 
	
	function self.update()
	  eat()
	  hunger = hunger - 0.0005
	  
	  if hunger>=1 then
	    reproduce()
	    hunger = 0.5
	  elseif hunger<=0 then
	    game.resources.herbivore_starve:play(.06)
	    self.is_dead = true
	  end 
	  
	  -- Measuring Hunger
	  game.trace_circle(self.pos, self.pos, 100)
	  game.trace_circle(self.pos, self.pos, hunger * 100)
	  
    if count >0 then
      count= count - 1
    else
      count=30 + math.random(100)
      target_vel = v2.random()
    end
    
    self.pos = self.pos + vel
	  vel = vel * 0.98 + target_vel *0.02
	  
	  --bound herbivores to screen
	  if self.pos.x < C.left_bound  then self.pos.x = C.left_bound end
    if self.pos.x > C.right_bound then self.pos.x = C.right_bound end
    if self.pos.y < C.lower_bound then self.pos.y = C.lower_bound end
    if self.pos.y > C.upper_bound then self.pos.y = C.upper_bound end
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

--- Foliage -----------------------------------------------------------------

function make_foliage(game, _pos)
  local self = {}
  self.pos = _pos
  self.tags = {'foliage'}
  
  function self.draw_outline()
		glColor3d(1, 0.3, 0.2)
		game.resources.herbivore_inner_outline:draw()
	  glColor3d(1, 1, 1)
	end
  
  function self.draw_fill()
    game.resources.herbivore_inner_fill:draw()
  end

  return self
end

return get_module_exports()
