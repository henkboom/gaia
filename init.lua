require 'dokidoki.module' [[]]

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local C = require 'constants'
local creatures = require 'creatures'

import 'gl'
import 'dokidoki.base'
kernel.set_video_mode(1024,768)

kernel.start_main_loop(actor_scene.make_actor_scene(
  {'trace_cleanup', 'update'},
  {'draw_setup', 'draw_outline', 'draw_fill', 'draw_inner_outline',
   'draw_inner_fill', 'draw_foreground', 'draw_trace'},
  function (game)
    math.randomseed(os.time())
    game.resources = require 'resources'

    -- for debugging
    local circle =
      imap(function (a) return v2.unit(a*math.pi/6) end, range(0, 11))
    function game.trace_circle(source, pos, radius)
      if not game.is_key_down(('D'):byte()) then
        return
      end
      local self = {}
      function self.trace_cleanup()
        self.is_dead = true
      end
      function self.draw_trace()
        if source then
          glColor4d(1, 1, 1, 1/4)
          glBegin(GL_LINES)
          glVertex2d(source.x, source.y)
          glVertex2d(pos.x, pos.y)
          glEnd()
        end
        glColor4d(1, 1, 1, 1/2)
        glBegin(GL_LINE_LOOP)
        for _, v in ipairs(circle) do
          glVertex2d(pos.x + v.x * radius, pos.y + v.y * radius)
        end
        glEnd()
        glColor3d(1, 1, 1)
      end
      game.add_actor(self)
    end

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
      draw_outline = function ()
        glBlendFunc(GL_SRC_ALPHA, GL_ONE)
      end,
      draw_fill = function ()
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      end,
      draw_inner_outline = function ()
        glBlendFunc(GL_SRC_ALPHA, GL_ONE)
      end,
      draw_inner_fill = function ()
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      end,
      draw_foreground = function ()
        --game.resources.foreground:draw()
      end
    }
    for i = 1, 5 do
      game.add_actor(creatures.make_predator(
        game,
        v2(math.random() * C.width, math.random() * C.height)))  
    end
     for i = 1, 10 do 
        game.add_actor(creatures.make_herbivore(
          game,
          v2(math.random() * C.width, math.random() * C.height)))  
      end
    
  end))

