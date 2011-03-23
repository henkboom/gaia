local gl = require 'gl'
local C = game.constants
local phases = C.draw_phases

game.renderer.add_job(self, phases.creature_bg_glow_setup, function ()
  gl.glClearColor(0.0, 0.0, 0.0, 0)
  gl.glClear(gl.GL_COLOR_BUFFER_BIT)
  gl.glEnable(gl.GL_BLEND)
  gl.glMatrixMode(gl.GL_PROJECTION)
  gl.glLoadIdentity()
  if(game.keyboard.key_held(string.byte('`'))) then
    gl.glOrtho(-C.width, 2*C.width, -C.height, 2*C.height, 1, -1)
  else
    gl.glOrtho(0, C.width, 0, C.height, 1, -1)
  end
  gl.glMatrixMode(gl.GL_MODELVIEW)
  gl.glLoadIdentity()
  gl.glColor3d(1, 1, 1)
  gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
end)

game.renderer.add_job(self, phases.creature_bg_mask_setup, function ()
  gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
end)

game.renderer.add_job(self, phases.creature_fg_glow_setup, function ()
  gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
end)

game.renderer.add_job(self, phases.creature_fg_mask_setup, function ()
  gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
end)

game.renderer.add_job(self, phases.debug, function ()
  gl.glBegin(gl.GL_LINE_LOOP)
  gl.glVertex2d(C.left_bound, C.lower_bound)
  gl.glVertex2d(C.right_bound, C.lower_bound)
  gl.glVertex2d(C.right_bound, C.upper_bound)
  gl.glVertex2d(C.left_bound, C.upper_bound)
  gl.glEnd()
end)
