local v2 = require 'dokidoki.v2'

local C = game.constants
local args = ...

local pos = assert(args.pos)
local facing = assert(args.facing)

local scale = v2(args.scale or 1, args.scale or 1)
local glow_image = args.glow_image
local mask_image = args.mask_image

-- if we're off the edge completely, just stop now
if game.out_of_world(pos, -C.collision_cell_size) then
  game.remove_component(self)
  return
end

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', {
  pos = pos,
  facing = facing
})

---- Renderer Components ------------------------------------------------------
local glow_sprite
if glow_image then
  glow_sprite = game.add_component(self, 'sprite', {
    phase = C.draw_phases.creature_bg_glow,
    color = {unpack(C.carrion_color)}, -- we mutate this, so copy
    scale = scale,
    image = glow_image
  })
end

local mask_sprite
if mask_image then
  mask_sprite = game.add_component(self, 'sprite', {
    phase = C.draw_phases.creature_bg_mask,
    color = {1, 1, 1, 1},
    scale = scale,
    image = mask_image
  })
end

---- Behaviour ----------------------------------------------------------------
local health = 1

game.carrion_collision.register(self)

function get_nibbled()
  health = health - 0.001

  if glow_sprite then
    glow_sprite.color[4] = health
  end

  if mask_sprite then
    mask_sprite.color[4] = health * 2
  end

  if math.random(200) == 1 then
    game.add_component(parent, 'foliage', {
      pos = transform.pos +
        25 * math.random() * v2.unit(math.random() * math.pi * 2),
      foliage_type = 'corpse'
    })
  end

  if math.random() < 1/20 then
    game.sound.play_random_from(
      game.resources.scavenger_nibble_sounds,
      transform.pos,
      0.2)
  end

  if health <= 0 then
    game.remove_component(self)
  end
end
