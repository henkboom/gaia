local v2 = require 'dokidoki.v2'
local gl = require 'gl'

local args = ...
color = args.color or {1, 1, 1}
scale = args.scale or v2(1, 1) 
local phase = assert(args.phase)
local transform = assert(args.transform or parent.transform)

image = assert(args.image)

game.renderer.add_job(self, phase, function ()
  if color[4] == 0 then
    return
  end
  -- TODO: do these transforms directly, much faster!
  gl.glPushMatrix()
  gl.glTranslated(transform.pos.x, transform.pos.y, 0)
  -- slooooow and stupid rotation:
  local f = transform.facing
  gl.glRotated(180/math.pi * math.atan2(f.y, f.x), 0, 0, 1)
  gl.glScaled(scale.x, scale.y, 1)

  gl.glColor4d(color[1], color[2], color[3], color[4] or 1)
  image:draw()
  gl.glColor3d(1, 1, 1)

  gl.glPopMatrix()
end)
