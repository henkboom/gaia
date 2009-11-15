require 'dokidoki.module' [[]]

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local C = require 'constants'
local creatures = require 'creatures'

import 'gl'
import 'dokidoki.base'

kernel.start_main_loop(actor_scene.make_actor_scene(
  {'update'},
  {'draw_setup', 'draw_outline', 'draw_fill'},
  function (game)
    math.randomseed(os.time())
    game.resources = require 'resources'

    -- for collision detection
    function game.nearby(pos, radius, tag)
      local function close_enough(actor)
        return v2.sqrmag(actor.pos - pos) <= radius * radius
      end
      return ifilter(close_enough, game.get_actors_by_tag(tag))
    end

    game.add_actor{
      draw_setup = function ()
        glClearColor(0.0, 0.0, 0.0, 0)
        glClear(GL_COLOR_BUFFER_BIT)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        glOrtho(0, C.width, 0, C.height, 1, -1)
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        glColor3d(1, 1, 1)
      end,
    }

    for i = 1, 10 do
      game.add_actor(creatures.make_predator(
        game,
        v2(100 + math.random() * 400, 100 + math.random() * 400)))
    end
  end))

