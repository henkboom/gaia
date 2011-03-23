local gl = require 'gl'
local args = ...
color = args.color or {1, 1, 1}
scale = args.scale or 1
sprites = assert(args.sprites)

local phases = game.constants.draw_phases

local pos = parent.transform.pos

local function make_render(sprite)
  return function ()
    gl.glColor3d(unpack(color))
    gl.glPushMatrix()
    gl.glTranslated(pos.x, pos.y, 0)
    gl.glScaled(scale, scale, scale)
    sprite:draw()
    gl.glPopMatrix()
  end
end

if sprites[1] then
  game.renderer.add_job(self, phases.creature_bg_glow, make_render(sprites[1]))
end
if sprites[2] then
  game.renderer.add_job(self, phases.creature_bg_glow, make_render(sprites[1]))
end
if sprites[3] then
  game.renderer.add_job(self, phases.creature_bg_glow, make_render(sprites[1]))
end
if sprites[4] then
  game.renderer.add_job(self, phases.creature_bg_glow, make_render(sprites[1]))
end
