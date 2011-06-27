local v2 = require 'dokidoki.v2'

local C = game.constants
local args = ...

local scale = assert(args.scale)
local tail = args.tail

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', { pos=args.pos })

---- Renderer Components ------------------------------------------------------
local glow_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  color = args.color, -- points directly to the head's color
  scale = v2(scale, scale),
  image = game.resources.predator_tail_sprites[1]
})

local mask_sprite = game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_mask,
  scale = v2(scale, scale),
  image = game.resources.predator_tail_sprites[2]
})

---- Behaviour ----------------------------------------------------------------

local follow_distance = 40 * scale

function follow(pos)
  local displacement = pos - transform.pos
  local direction = v2.sqrmag(displacement) > 0 and v2.norm(displacement)

  if v2.sqrmag(displacement) > follow_distance*follow_distance then
    transform.pos = pos - direction * follow_distance
  end
  if direction then
    transform.facing = direction
  end

  if tail and not tail.dead then
    tail.follow(transform.pos)
  end
end

function starve()
  starve_countdown = starve_countdown or 5
end

local function actually_starve()
  game.remove_component(self)
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

function update()
  if not starve_countdown then
    return
  end
  starve_countdown = starve_countdown - 1
  if starve_countdown <= 0 then
    actually_starve()
  end
end
