require 'dokidoki.module' [[]]

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local creatures = require 'creatures'

import 'gl'

kernel.start_main_loop(actor_scene.make_actor_scene(
  {'update'},
  {'draw_setup', 'draw_outline', 'draw_fill'},
  function (game)
    game.resources = require 'resources'
    game.add_actor{
      draw_setup = function ()
        glClearColor(0.0, 0.0, 0.0, 0)
        glClear(GL_COLOR_BUFFER_BIT)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        glOrtho(0, 640, 0, 480, 1, -1)
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        glColor3d(1, 1, 1)
      end,
    }
    game.add_actor(creatures.make_predator(game, v2(300, 300)))
  end))

