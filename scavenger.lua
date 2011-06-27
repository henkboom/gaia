local gl = require 'gl'
local v2 = require 'dokidoki.v2'

local C = game.constants
local args = ...

local pos = assert(args.pos)

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', { pos = pos })

---- Renderer Components ------------------------------------------------------
local sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  color = {unpack(C.scavenger_color)}, -- we mutate this, so copy
  image = game.resources.scavenger_sprites[1]
})

---- Behaviour ----------------------------------------------------------------

local initial_pos = transform.pos
local max_speed = 4
local speed_delta = 1/10
local speed = 0.25

local target_countdown = 0
local target_carrion = nil
local target_direction = v2(1, 0)

local energy = 0
local home = true

local function find_target()
    local eat_radius = 50 + math.random(6)^3
    game.tracing.trace_circle(transform.pos, transform.pos, eat_radius)

    local food = game.carrion_collision.get_nearby(transform.pos, eat_radius)

    if #food == 0 then
      target_carrion = nil
    else
      target_carrion = food[math.random(#food)]
      target_direction = target_carrion.transform.pos - transform.pos
      if v2.sqrmag(target_direction) == 0 then
        target_direction = v2(1, 0)
      else
        target_direction = v2.norm(target_direction)
      end
      transform.facing = target_direction
    end
end

function update()
  if target_carrion then
    home = false
    sprite.color[4] = math.min(1, sprite.color[4] + 1/120)
    if target_carrion.dead then
      find_target()
      if not target_carrion then
        target_direction = initial_pos - transform.pos
        transform.facing = target_direction
        if v2.sqrmag(target_direction) == 0 then
          target_direction = v2(1, 0)
        else
          target_direction = v2.norm(target_direction)
        end
        speed = 0
      end
    else
      game.tracing.trace_circle(transform.pos, target_carrion.transform.pos, 5)
      if v2.sqrmag(transform.pos - target_carrion.transform.pos) < 15*15 then
        speed = 0
        --eat carrion and get energy
        target_carrion.get_nibbled()
        energy = energy + 1

        transform.facing =
          v2.rotate(target_direction, (math.random() - 0.5) * math.pi/4)
      else
        speed = math.min(max_speed, speed + speed_delta)
        transform.pos = transform.pos + target_direction * speed
      end
    end
  else
    sprite.color[4] = math.max(0, sprite.color[4] - 1/60)
    if speed > 0 and v2.sqrmag(transform.pos - initial_pos) < 9 then
      speed = 0
      home = true
    end
    if home then
      energy = math.max(0, energy - 0.1)
      target_countdown = target_countdown - 1
      if target_countdown <= 0 then
        target_countdown = math.random(120, 180)
        find_target()
      end
    else
      speed = math.min(max_speed, speed + speed_delta)
      transform.pos = transform.pos + target_direction * speed
    end
  end

  local scale = math.min(0.8, 0.5 + energy/1200)
  sprite.scale = v2(scale, scale)
end

game.renderer.add_job(self, C.draw_phases.creature_bg_glow, function ()
  local color = sprite.color
  if color[4] > 0 then
    gl.glBegin(gl.GL_LINES)
    gl.glColor4d(color[1], color[2], color[3], color[4])
    gl.glVertex2d(transform.pos.x, transform.pos.y)
    gl.glColor4d(color[1], color[2], color[3], 0)
    gl.glVertex2d(initial_pos.x, initial_pos.y)
    gl.glEnd()
  end
end)

