local v2 = require 'dokidoki.v2'

local C = game.constants
local args = ...

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', { pos=args.pos })

---- Renderer Components ------------------------------------------------------
local glow_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  color = {unpack(C.predator_color)}, -- we mutate this, so copy
  scale = v2(C.predator_base_scale, C.predator_base_scale);
  image = game.resources.predator_head_sprites[1]
})

local mask_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_mask,
  image = game.resources.predator_head_sprites[2]
})

---- Behaviour ----------------------------------------------------------------
game.predator_collision.register(self)

local min_speed = 1.7
local max_speed = 3.5
local speed_increment = 0.05
local max_angular_velocity = math.pi/64
local angular_velocity_increment = math.pi/256

local speed = min_speed
local angular_velocity = 0
local attacking = false
local hunger = 0.5

local length = 1
local tail

local function lengthen()
  local old_tail = tail
  tail = game.add_component(parent, 'predator_tail', {
    pos = transform.pos,
    scale = glow_sprite.scale.x - 0.20,
    color = glow_sprite.color,
    tail = old_tail
  })
  length = length + 1
  if length >= 15 and length % 15 == 0 then
    game.add_component(parent, 'predator', { pos = transform.pos })
    game.sound.play(game.resources.predator_reproduce, transform.pos, 1.8)
  end
  local scale = (length-1) / 75 + C.predator_base_scale
  local scale_v = v2(scale, scale)
  glow_sprite.scale = scale_v
  mask_sprite.scale = scale_v
end

lengthen()
lengthen()
lengthen()
lengthen()

local eat_timeout = 0
local function eat()
  eat_timeout = eat_timeout - 1

  if eat_timeout <= 0 then
    -- find food
    local radius = 20
    game.tracing.trace_circle(transform.pos, transform.pos, radius)
    local food = game.prey_collision.get_nearby(transform.pos, radius)[1]

    -- eat it
    if food then
      game.sound.play_random_from(
        game.resources.predator_eat_sounds,
        transform.pos)
      hunger = hunger - 0.1
      game.remove_component(food)
      eat_timeout = math.random(5, 6)
    end
  end
end

local function starve()
  game.remove_component(self)
  game.sound.play(game.resources.predator_starve, transform.pos, 2)
  game.add_component(parent, 'carrion', {
    pos = transform.pos,
    facing = transform.facing,
    scale = glow_sprite.scale.x,
    glow_image = glow_sprite.image,
    mask_image = mask_sprite.image,
  })
  if tail and not tail.dead then
    tail.starve()
  end
end

-- food_direction returns false if no prey, otherwise 1, -1, or 0 depending on
-- where to turn
local food_offset_left = v2.unit(math.pi/6) * 90
local food_offset_right = v2.unit(-math.pi/6) * 90
local food_direction_cache_timeout = 0
local food_direction_cache = false
local function food_direction()
  -- only recalculate periodically
  food_direction_cache_timeout = food_direction_cache_timeout - 1
  if food_direction_cache_timeout > 0 then
    return food_direction_cache
  end
  food_direction_cache_timeout = math.random(2, 3)

  -- find left and right prey
  local pos = transform.pos

  local radius = 60
  local left_pos = pos + v2.rotate_to(food_offset_left, transform.facing)
  local right_pos = pos + v2.rotate_to(food_offset_right, transform.facing)

  local left_count = #game.prey_collision.get_nearby(left_pos, radius) -
                     (game.out_of_world(left_pos, radius) and 0.5 or 0)
  local right_count = #game.prey_collision.get_nearby(right_pos, radius) -
                     (game.out_of_world(right_pos, radius) and 0.5 or 0)

  game.tracing.trace_circle(pos, left_pos, radius)
  game.tracing.trace_circle(pos, right_pos, radius)

  -- turn towards more prey
  if left_count == 0 and right_count == 0 then
    food_direction_cache = false
  elseif left_count < right_count then
    food_direction_cache = -1
  elseif left_count > right_count then
    food_direction_cache = 1
  else
    food_direction_cache = 0
  end

  return food_direction_cache
end

function update()
  local bounds_correction = game.get_bounds_correction(transform.pos)
  if bounds_correction ~= v2.zero then
    -- turn away from the edge
    local turn_left = v2.cross(transform.facing, bounds_correction) > 0
    angular_velocity = angular_velocity +
      angular_velocity_increment * (turn_left and 0.5 or -0.5)
  else
    -- look for food
    local dir = food_direction()
    if dir then
      -- attacking
      if not attacking then
        attacking = true
        game.sound.play_random_from(
          game.resources.predator_attack_sounds,
          transform.pos)
      end
      speed = math.min(speed + speed_increment, max_speed)
      angular_velocity = angular_velocity + dir * angular_velocity_increment
    else
      -- not attacking
      attacking = false
      speed = math.max(speed - speed_increment,
        min_speed + math.max(0, hunger - 0.5) * 3)
    end
  end

  -- angular wandering, damping, clamping
  angular_velocity = (angular_velocity +
  (math.random() - 0.5) * angular_velocity_increment) * 0.98
  angular_velocity =
    math.max(-max_angular_velocity,
             math.min(angular_velocity, max_angular_velocity))

  -- actual movement
  transform.facing = v2.rotate(transform.facing, angular_velocity)
  transform.pos = transform.pos + transform.facing * speed

  -- hunger/food
  eat()
  hunger = hunger + 0.002/60 * (3 + length*0.3)
  if hunger >= 1 then
    starve()
  elseif hunger <= 0 then
    hunger = hunger + 0.5
    lengthen()
  end
  local c = C.predator_color
  glow_sprite.color[1] = c[1] - hunger
  glow_sprite.color[2] = c[2] - hunger
  glow_sprite.color[3] = c[3] - 0.2 * hunger

  -- tail update
  if tail and tail.dead then
    tail = nil
  end
  if tail then
    tail.follow(transform.pos)
  end

  game.tracing.trace_circle(transform.pos, transform.pos, 50)
  game.tracing.trace_circle(transform.pos, transform.pos, (1-hunger) * 50)
end
