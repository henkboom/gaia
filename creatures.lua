require 'dokidoki.module'
[[ make_predator, make_herbivore, make_scavenger, make_foliage, make_carrion ]]

local v2 = require 'dokidoki.v2'
local C = require 'constants'
import 'gl'

--- Predator Head ------------------------------------------------------------

function make_predator(game, _pos)
  -- constants
  local min_speed = 0.7
  local max_speed = 3
  local speed_increment = 0.05
  local max_turn_speed = math.pi/64
  local turn_speed_factor = math.pi/256

  local self = {}
  self.pos = _pos
  self.tags = {'predator'}

  local angle = math.random() * 2 * math.pi
  local turn = 0
  local tail = nil
  local speed = min_speed
  local length = 5
  local scale = length / 150 + 0.5
  local hunger = 0.5
  local attacking =false

  local function lengthen ()
    local old_tail = tail
    tail = make_predator_cell(game, self.pos, self, length, old_tail)
    old_tail.set_head(tail)
    game.add_actor(tail)
    length = length + 1
    if length >= 12 and length % 6 == 0 then
      game.add_actor(make_predator(game, self.pos))
      game.resources.predator_reproduce:play(1.8*C.volume)
    end
  end

  local countdown = 0
  local cache = nil
  local function food_direction()
    countdown = countdown - 1
    if countdown > 0 then return cache end
    countdown = math.random(5, 6)
    local left_pos = self.pos + v2.unit(angle + math.pi/6) * 90
    local right_pos = self.pos + v2.unit(angle - math.pi/6) * 90
    local radius = 60
    local left_count = #game.nearby(left_pos, radius, 'prey') +
                       (game.out_of_world(left_pos, radius) and -0.5 or 0)
    local right_count = #game.nearby(right_pos, radius, 'prey') +
                       (game.out_of_world(right_pos, radius) and -0.5 or 0)

    game.trace_circle(self.pos, left_pos, radius)
    game.trace_circle(self.pos, right_pos, radius)

    if left_count == 0 and right_count == 0 then
      cache = false
    elseif left_count < right_count then
      cache = -1
    elseif left_count > right_count then
      cache = 1
    else
      cache = 0
    end
    return cache
  end

  local function eat()
    local eat_radius = 20
    game.trace_circle(self.pos, self.pos, eat_radius)
    local food = game.nearby(self.pos, eat_radius, 'prey')
    for _, f in ipairs(food) do
      
      -- PREDATOR EAT SOUNDS
      local random = math.random(3)
      if random == 1 then
        game.resources.predator_eat1:play(.18*C.volume)
      elseif random == 2 then
        game.resources.predator_eat2:play(.18*C.volume)
      else
        game.resources.predator_eat3:play(.18*C.volume)
      end
      
      hunger = hunger - 0.1
      f.is_dead = true
    end
  end

  local function starve()
    --make carrion
    game.add_actor(make_carrion(game, self.pos, angle, scale,
      game.resources.predator_outline, game.resources.predator_head_fill))
   
    -- PREDATOR STARVE SOUNDS
    game.resources.predator_starve:play(1.2*C.volume)
    self.is_dead = true
  end

  function self.update()
    if not tail then
      tail = make_predator_cell(game, self.pos, self, length-1)
      game.add_actor(tail)
    end

    local bounds_correction = game.get_bounds_correction(self.pos)
    if bounds_correction == v2.zero then
      -- handle seeing food
      local fd = food_direction()
      if fd then
        -- play sound when on the attack
        if attacking == false then
          
          -- PREDATOR ATTACK SOUNDS
          local random = math.random(3)
          if random == 1 then
           game.resources.predator_attack1:play(.3*C.volume)
          elseif random == 2 then
            game.resources.predator_attack2:play(.3*C.volume)
          else
           game.resources.predator_attack3:play(.3*C.volume)
          end
          
          
          attacking=true
        end
        speed = math.min(speed + speed_increment, max_speed)
        turn = turn + fd * turn_speed_factor
      else
        speed = math.max(speed - speed_increment, min_speed)
        attacking = false
      end
    else
      local left = v2.cross(v2.unit(angle), bounds_correction) >= 0
      turn = turn + turn_speed_factor * (left and 0.5 or -0.5)
    end

    -- add a random component
    turn = turn + (math.random() - 0.5) * turn_speed_factor

    -- damp it so that they don't spiral too much
    turn = turn * 0.98
    -- clamp it to limit turn speed
    turn = math.max(-max_turn_speed, math.min(turn, max_turn_speed))

    angle = angle + turn
    self.pos = self.pos + v2.unit(angle) * speed

    -- hunger/food
    hunger = hunger + 0.002/60 * (2 + length*0.75)
    eat()
    if hunger >= 1 then
      starve()
    elseif hunger <= 0 then
      hunger = hunger + 0.5
      lengthen()
    end
    if tail then tail.set_hunger(hunger) end
    -- Measuring Hunger
    game.trace_circle(self.pos, self.pos, 50)
    game.trace_circle(self.pos, self.pos, (1 - hunger) * 50)
  end

  function self.draw_outline()
    glColor3d(1.0 - hunger, 0.2 * hunger, 0.7 - 0.2 * hunger)    
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_outline:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_head_fill:draw()
  end

  return self
end

--- Predator Cell ------------------------------------------------------------

-- tail is optional
function make_predator_cell(game, _pos, head, length, tail)
  local self = {}
  self.pos = _pos

  local angle = 0
  local scale = length / 150 + 0.25
  local follow_distance = 40 * scale
  
  -- for drawing only
  local hunger = 0

  local function starve()
    --make carrion
    game.add_actor(make_carrion(game, self.pos, angle, scale,
      game.resources.predator_outline, game.resources.predator_cell_fill))
    
    self.is_dead = true
  end

  function self.update()
    if not tail and length > 1 then
      tail = make_predator_cell(game, self.pos, self, length-1)
      game.add_actor(tail)
    end

    if head.is_dead then
      starve()
    else
      if v2.mag(self.pos - head.pos) > follow_distance then
        self.pos = head.pos + v2.norm(self.pos - head.pos) * follow_distance
      end
      angle = math.atan2(head.pos.y - self.pos.y, head.pos.x - self.pos.x)
    end
  end

  function self.draw_outline()
    glColor3d(1.0 - hunger, 0.2 * hunger, 0.7 - 0.2 * hunger)
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_outline:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_fill()
    glRotated(angle * 180 / math.pi, 0, 0, 1)
    glScaled(scale, scale, 1)
    game.resources.predator_cell_fill:draw()
  end

  function self.set_head(new_head)
    head = new_head
  end
  
  function self.set_hunger(new_hunger)
    hunger = new_hunger
    if tail then tail.set_hunger(new_hunger) end
  end

  return self
end

--- Herbivore ----------------------------------------------------------------

function make_herbivore(game, _pos)
  local self = {}
  self.pos = _pos
  self.tags = {'prey', 'herbivore', 'interactive'}

  local vel = v2(0,0)
  local target_vel
  local count = 0
  local offset = v2.random() * 4
  local reproduce_timer = math.random(800)
  local hunger = 0.5
  local desperation = 0
  local inner_rotation = math.random(360)
  local interaction_level = 0
  
  local function eat()
    local eat_radius = 20
    local food = game.nearby(self.pos, eat_radius, 'foliage')
    
    for _, f in ipairs(food) do
      -- HERBIVORE EAT SOUNDS
      local random = math.random(5)
      if random == 1 then
        game.resources.herbivore_eat1:play(.06*C.volume)
      elseif random == 2 then
        game.resources.herbivore_eat2:play(.06*C.volume)
      elseif random == 3 then
        game.resources.herbivore_eat3:play(.06*C.volume)
      elseif random == 4 then
        game.resources.herbivore_eat4:play(.06*C.volume)
      else
        game.resources.herbivore_eat5:play(.06*C.volume)
      end

      hunger =  hunger - 0.28
      f.is_dead = true
    end
  end
  
  local function reproduce()
    game.resources.herbivore_reproduce:play(.6*C.volume)
    game.add_actor(make_herbivore(game, self.pos))
  end 
  
  local function starve()
    --make carrion
    local r = game.resources
    game.add_actor(make_carrion(game, self.pos, 0, 1,
      r.herbivore_outline, r.herbivore_fill))

    -- HERBIVORE STARVE SOUNDS
    local random = math.random(3)
    if random == 1 then
      game.resources.herbivore_starve1:play(.36*C.volume)
    elseif random == 2 then
      game.resources.herbivore_starve2:play(.36*C.volume)
    else
      game.resources.herbivore_starve3:play(.36*C.volume)
    end
    self.is_dead = true
  end
  
  function self.update()
    eat()
    hunger = hunger + 0.0003
    
    if inner_rotation+1 >= 360 then
      inner_rotation = 0
    else
      inner_rotation = inner_rotation + 1
    end
    
    if hunger <= 0 then
      reproduce()
      hunger = 0.5
    elseif hunger >= 1 then
      starve()
    end 
    
    -- Measuring Hunger
    game.trace_circle(self.pos, self.pos, 50)
    game.trace_circle(self.pos, self.pos, (1 - hunger) * 50)
    
    if count > 0 then
      count = count - 1
    else
      game.trace_circle(self.pos, self.pos, 100)
      local food = game.nearby(self.pos, 100, 'foliage')
      if #food > 0 then
        desperation = 0
        -- sort food
        table.sort(food, function (a, b)
          return v2.sqrmag(a.pos - self.pos) < v2.sqrmag(b.pos - self.pos)
        end)
        -- eat closest one
        if food[1].pos ~= self.pos then
          target_vel = v2.norm(food[1].pos - self.pos) / 2
        end
      else
        desperation = desperation + 1

        local bounds_correction = game.get_bounds_correction(self.pos)
        if bounds_correction ~= v2.zero then
          target_vel = bounds_correction + v2.random() / 2
        else
          target_vel = v2.random() * (1 + desperation/5) / 2
        end
      end

      count = 20 + desperation * 20 + math.random(20)
    end
    
    self.pos = self.pos + vel
    vel = vel * 0.98 + target_vel * 0.02

  end

  function self.set_interaction_level(level)
    interaction_level = level
  end
  
  local function get_angle()
    return (self.pos.x + self.pos.y)*5
  end

  function self.draw_outline()
    if interaction_level == 0 then
      glColor3d(0, 1, 0.2)
    end
    game.resources.herbivore_outline:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_inner_outline()
    glColor4d(0, 0.43, 1, 1-(hunger^2))
    glRotated(get_angle(), 0, 0, 1)
    game.resources.herbivore_inner_outline:draw()
    glColor3d(1, 1, 1)
  end
  
  function self.draw_fill()
    game.resources.herbivore_fill:draw()
  end
  
  function self.draw_inner_fill()
    glRotated(get_angle(), 0, 0, 1)
    game.resources.herbivore_inner_fill:draw()
  end
  
  return self
end

--- Scavenger -----------------------------------------------------------------

function make_scavenger(game, initial_pos)
  local self = {}
  self.pos = initial_pos
  self.tags = {'scavenger'}
  
  local opacity = 0
  local max_speed = 4
  local min_speed = 0.0
  local speed_delta = 1/10
  local speed = 0.25

  local angle = math.random() * 2 * math.pi
  local drawn_angle = angle
  local idle_countdown = 0

  local target_carrion = nil
  local target_direction = v2(1, 0)
  
  local max_countdown = 20
  local countdown = max_countdown
  
  local function spawn_foliage()
    if countdown >0 then
      countdown = countdown - 1
    else
      game.add_actor(make_foliage(game,self.pos))
      countdown = max_countdown
    end
  end
    
  
  
  local function find_target()
    local eat_radius = 50 + math.random(6)^3
    local food = game.nearby(self.pos, eat_radius, 'carrion')

    game.trace_circle(self.pos, self.pos, eat_radius)

    if #food == 0 then
      target_carrion = nil
    else
      target_carrion = food[math.random(#food)]
      target_direction = v2.norm(target_carrion.pos - self.pos)
    end
  end
  
  function self.update()
    --spawn_foliage()

    if speed > 0 then game.trace_circle(self.pos, self.pos, speed * 10) end

    angle = math.atan2(target_direction.y, target_direction.x)
    drawn_angle = angle
    if target_carrion then
      opacity = math.min(1, opacity + 1/120)
      if target_carrion.is_dead then
        find_target()
        if not target_carrion then
          target_direction = v2.norm(initial_pos - self.pos)
          speed = min_speed
        end
      else
        game.trace_circle(self.pos, target_carrion.pos, 5)
        if v2.sqrmag(self.pos - target_carrion.pos) < 15*15 then
          speed = min_speed
          target_carrion.get_nibbled()
          drawn_angle = angle + (math.random() - 0.5) * math.pi/4
        else
          speed = math.min(max_speed, speed + speed_delta)
          self.pos = self.pos + target_direction * speed
        end
      end
    else
      opacity = math.max(0, opacity - 1/120)
      if v2.sqrmag(self.pos - initial_pos) < 9 then
        speed = min_speed
        idle_countdown = idle_countdown or math.random(120, 180)
        idle_countdown = idle_countdown - 1
        if idle_countdown <= 0 then
          idle_countdown = nil
          find_target()
        end
      else
        speed = math.min(max_speed, speed + speed_delta)
        self.pos = self.pos + target_direction * speed
      end
    end
  end
  
  function self.draw_outline()
    if opacity > 0 then

      glBegin(GL_LINES)
      glColor4d(1, 0.77, 0, opacity/4)
      glVertex2d(0, 0)
      glColor4d(1, 0.77, 0, 0)
      glVertex2d(initial_pos.x - self.pos.x, initial_pos.y - self.pos.y)
      glEnd()

      glColor4d(1, 0.77, 0, opacity)

      glScaled(0.5, 0.5, 0.5)
      glRotated(drawn_angle * 180/math.pi, 0, 0, 1)
      game.resources.scavenger_outline:draw()

      glColor3d(1, 1, 1)
    end
  end
  
  return self
  
end

--- Foliage -----------------------------------------------------------------

function make_foliage(game, _pos)
  local self = {}
  self.pos = _pos
  self.tags = {'foliage'}

  function self.draw_outline()
    glColor3d(0.15, 0.1, 0.05)
    game.resources.foliage_outline:draw()
    glColor3d(1, 1, 1)
  end
  
  function self.draw_fill()
    game.resources.foliage_fill:draw()
  end

  return self
end

--- Carrion -----------------------------------------------------------------

function make_carrion(game, _pos, angle, scale, outline, fill)
  local self = {}
  self.pos = _pos
  self.tags = {'carrion'}

  local health = 1

  function self.get_nibbled()
    health = health - 0.001
    if health <= 0 then self.is_dead = true end
  end

  local function generic_draw(sprite)
    glColor4d(0.4, 0.3, 0.15, health)
    glScaled(scale, scale, scale)
    glRotated(angle * 180/math.pi, 0, 0, 1)
    sprite:draw()
    glColor3d(1, 1, 1)
  end

  if outline then
    function self.draw_outline()
      generic_draw(outline)
    end
  end

  if fill then
    function self.draw_fill()
      generic_draw(fill)
    end
  end
  
  return self
end

return get_module_exports()
