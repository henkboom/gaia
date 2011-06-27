local gl = require 'gl'
local log = require 'log'
local sensor = require 'sensor'

local C = game.constants

local countdown = 0;
local activity_level = 0;

function get_activity_level()
  return activity_level
end

local display_type = nil

function preupdate () -- CHANGE TO REMOVEpreupdate to disable sensing
  if game.keyboard.key_pressed(string.byte("1")) then
    display_type = nil
  elseif game.keyboard.key_pressed(string.byte("2")) then
    display_type = 'image'
  elseif game.keyboard.key_pressed(string.byte("3")) then
    display_type = 'diff'
  end

  countdown = countdown - 1
  if countdown <= 0 then
    countdown = 3
    local ret, err = sensor.read_activity_level()
    --log.log_message('sensing ' .. ret)
    if ret then
      local measurement = math.max(0, math.min(1, (ret - 0.001)*C.sensitivity_multiplier))
      if measurement < activity_level then
        activity_level = activity_level * 0.95 + measurement * 0.05
      else
        activity_level = activity_level * 0.5 + measurement * 0.5
      end
      if activity_level > 0.4 then activity_level = 0.4 end
    else
      log.log_message(err)
    end
  end
end

game.renderer.add_job(self, C.draw_phases.debug, function ()
  --local width = activity_level * C.width
  --gl.glColor3d(0, 0.7, 0)
  --gl.glBegin(gl.GL_QUADS)
  --gl.glVertex2d(0, 0)
  --gl.glVertex2d(width, 0)
  --gl.glVertex2d(width, 10)
  --gl.glVertex2d(0, 10)
  --gl.glEnd()
  --gl.glColor3d(1, 1, 1)

  local tex = nil
  tex = display_type and sensor.get_texture(display_type == 'diff')
  
  if display_type then
  end

  if tex then
    gl.glColor3d(1, 1, 1)

    gl.glEnable(gl.GL_TEXTURE_2D)
    gl.glBindTexture(gl.GL_TEXTURE_2D, tex)

    gl.glBegin(gl.GL_QUADS)
    gl.glTexCoord2d(0, 1)
    gl.glVertex2d(0, 0)
    gl.glTexCoord2d(1, 1)
    gl.glVertex2d(C.width, 0)
    gl.glTexCoord2d(1, 0)
    gl.glVertex2d(C.width, C.height)
    gl.glTexCoord2d(0, 0)
    gl.glVertex2d(0, C.height)
    gl.glEnd()

    gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
    gl.glDisable(gl.GL_TEXTURE_2D)
  end
end)
