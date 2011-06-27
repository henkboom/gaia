local v2 = require 'dokidoki.v2'

local C = game.constants
local args = ...

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', { pos=args.pos })

---- Renderer Components ------------------------------------------------------
local interaction_glow_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  --color = {unpack(C.herbivore_interaction_color)}, -- we mutate this, so copy
  color = {0.3,0.6,0.6,0},
  image = game.resources.herbivore_interaction_glow,
  scale = v2(1 + math.random() * 0.5, 1.1)
})
interaction_glow_sprite.color[2] =
  interaction_glow_sprite.color[2] + math.random() * 0.4

local bg_glow_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  color = {unpack(C.herbivore_bg_color)}, -- we mutate this, so copy
  image = game.resources.herbivore_bg_glow
})
bg_glow_sprite.color[2] = interaction_glow_sprite.color[2]

local bg_mask_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_mask,
  image = game.resources.herbivore_bg_mask
})

local fg_glow_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_fg_glow,
  color = {unpack(C.herbivore_fg_color)}, -- we mutate this, so copy
  image = game.resources.herbivore_fg_glows[
            math.random(#game.resources.herbivore_fg_glows)]
})

---- Behaviour ----------------------------------------------------------------

local vel = v2.zero
local hunger = 0.5
local desperation = 0
local target_expiry = 0
local interaction_level = 0

game.prey_collision.register(self)
game.interaction_collision.register(self)

local eat_timeout = 0
local function eat ()
  eat_timeout = eat_timeout - 1
  if eat_timeout <= 0 then
    eat_timeout = math.random(5, 6)
    local food = game.foliage_collision.get_nearby(transform.pos, 20)

    for i = 1, #food do
      game.sound.play_random_from(
        game.resources.herbivore_eat_sounds,
        transform.pos)

      hunger = hunger - 0.23
      game.remove_component(food[i])
    end
  end
end

local function reproduce()
  game.sound.play(game.resources.herbivore_reproduce, transform.pos)
  game.add_component(parent, 'herbivore', {pos = transform.pos})
end

local function acquire_target()
  -- time to look for food
  game.tracing.trace_circle(false, transform.pos, 100)
  local food = game.foliage_collision.get_nearby(transform.pos, 100)

  if #food == 0 then
    -- every time we don't see food, we get more desperate
    desperation = desperation + 1

    -- pick a random new direction, but avoid the bounds
    local bounds_correction = game.get_bounds_correction(transform.pos)
    if bounds_correction ~= v2.zero then
      target_vel = bounds_correction + v2.random() / 2
    else
      target_vel = v2.random() * (1 + desperation/5) / 2
    end
  else
    -- food found, don't panic
    desperation = 0

    -- go towards the closest one
    local closest_food = food[1]
    local min_distance = v2.sqrmag(food[1].transform.pos - transform.pos)
    for i = 2, #food do
      local distance = v2.sqrmag(food[i].transform.pos - transform.pos)
      if distance < min_distance then
        closest_food = food[i]
        min_distance = distance
      end
    end
    if closest_food.transform.pos ~= transform.pos then
      target_vel = v2.norm(closest_food.transform.pos - transform.pos) * 0.5
    end
  end
end

local function starve()
  game.sound.play_random_from(
    game.resources.herbivore_starve_sounds,
    transform.pos)
  game.remove_component(self)
  game.add_component(parent, 'carrion', {
    pos = transform.pos,
    facing = transform.facing,
    glow_image = bg_glow_sprite.image,
    mask_image = bg_mask_sprite.image
  })
end

function update()
  local too_many_herbivores = game.prey_collision.count() > 300
  if too_many_herbivores then
    hunger = hunger + 0.0001
  else
    hunger = hunger - interaction_level * 0.0025
  end
  eat()

  -- hunger management
  hunger = hunger + 0.0004
  if hunger <= 0 then
    reproduce()
    hunger = 0.5
  elseif hunger >= 1 then
    starve()
  end
  fg_glow_sprite.color[4] = 1 - (hunger*hunger)
  game.tracing.trace_circle(transform.pos, transform.pos, 50)
  game.tracing.trace_circle(transform.pos, transform.pos, (1 - hunger) * 50)

  -- target management
  if target_expiry > 0 then
    target_expiry = target_expiry - 1
  else
    acquire_target()
    target_expiry = 20 + desperation * 20 + math.random(20)
  end

  -- movement
  transform.pos = transform.pos + vel
  vel = vel * 0.98 + target_vel * 0.02

  local angle = (transform.pos.x + transform.pos.y) / 180 * math.pi * 5
  transform.facing = v2.unit(angle)

  local interaction = interaction_level + game.sensing.get_activity_level() * 4
  interaction_glow_sprite.color[4] = interaction
end

function set_interaction_level(level)
  if level == 0 then
    interaction_level = 0
  else
    interaction_level = interaction_level * 0.7 + 0.3 * level * 10
  end
end
