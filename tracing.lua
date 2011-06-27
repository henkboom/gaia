local dokidoki_base = require 'dokidoki.base'
local v2 = require 'dokidoki.v2'
local gl = require 'gl'

local circle_points = {}
for i = 1, 12 do
  circle_points[i] = v2.unit(i*2*math.pi/12)
end

local circles = {}

function trace_circle(source, pos, radius)
  if game.keyboard.key_held(('D'):byte()) then
    circles[#circles+1] = {source=source, pos=pos, radius=radius}
  end
end

function preupdate()
  if #circles > 0 then
    circles = {}
  end
end

game.renderer.add_job(self, game.constants.draw_phases.debug, function ()
  for i = 1, #circles do
    local source = circles[i].source
    local pos = circles[i].pos
    local radius = circles[i].radius

    if source then
      gl.glColor4d(1, 1, 1, 1/4)
      gl.glBegin(gl.GL_LINES)
      gl.glVertex2d(source.x, source.y)
      gl.glVertex2d(pos.x, pos.y)
      gl.glEnd()
    end
    gl.glColor4d(1, 1, 1, 1/2)
    gl.glBegin(gl.GL_LINE_LOOP)
    for j = 1, #circle_points do
      local v = circle_points[j]
      gl.glVertex2d(pos.x + v.x * radius, pos.y + v.y * radius)
    end
    gl.glEnd()
    gl.glColor3d(1, 1, 1)
  end
end)
