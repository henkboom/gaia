require 'dokidoki.module' [[]]

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local C = require 'constants'
local creatures = require 'creatures'
local sensor = require 'sensor'

import 'gl'
import 'dokidoki.base'
kernel.set_video_mode(1024,768)
kernel.set_ratio(C.width/C.height)

function nwipe(t)
  for i = 1, t.n do
    t[i] = nil
  end
end

function init_sensing(game)
  local countdown = 0;
  local activity_level = 0;

  function game.get_activity_level()
    return activity_level
  end

  game.add_actor{
    preupdate = function ()
      countdown = countdown - 1
      if countdown <= 0 then
        countdown = 6
        local ret, err = sensor.read_activity_level()
        if ret then
          local measurement = math.max(0, math.min(1, (ret - 0.001)*50))
          activity_level = activity_level * 0.8 + measurement * 0.2
          print('sensed ' .. activity_level)
        else
          print(err)
        end
      end
    end,
    draw_debug = function ()
      local width = activity_level * C.width
      glColor3d(0, 0, 0.5)
      glBegin(GL_QUADS)
      glVertex2d(0, 0)
      glVertex2d(width, 0)
      glVertex2d(width, 10)
      glVertex2d(0, 10)
      glEnd()
      glColor3d(1, 1, 1)
      local tex = nil
      if game.is_key_down(string.byte("1")) then
        tex = sensor.get_texture(false)
      elseif game.is_key_down(string.byte("2")) then
        tex = sensor.get_texture(true)
      end
      if tex then
        glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, tex)
        glBegin(GL_QUADS)
        glTexCoord2d(0, 1)
        glVertex2d(0, 0)
        glTexCoord2d(1, 1)
        glVertex2d(C.width, 0)
        glTexCoord2d(1, 0)
        glVertex2d(C.width, C.height)
        glTexCoord2d(0, 0)
        glVertex2d(0, C.height)
        glEnd()
        glBindTexture(GL_TEXTURE_2D, 0)
        glDisable(GL_TEXTURE_2D)
      end
    end
  }
end

function init_collision_detection(game, tags)
  local cell_size = 32
  local grids

  game.add_actor{
    preupdate = function ()
      grids = {}
      for _, tag in ipairs(tags) do
        grids[tag] = grids[tag] or {}
        local grid = grids[tag]
        for _, a in ipairs(game.get_actors_by_tag(tag)) do
          local i = math.floor(a.pos.x / cell_size)
          local j = math.floor(a.pos.y / cell_size)
          grid[i] = grid[i] or {}
          local col = grid[i]
          col[j] = col[j] or {n=0}
          local bucket = col[j]
          if bucket.n < 2 then
            bucket[bucket.n + 1] = a
            bucket.n = bucket.n + 1
          end
        end
      end
    end
  }

  function game.nearby(pos, radius, tag)
    local mini = math.floor((pos.x - radius) / cell_size)
    local maxi = math.ceil((pos.x + radius) / cell_size)
    local minj = math.floor((pos.y - radius) / cell_size)
    local maxj = math.ceil((pos.y + radius) / cell_size)

    local grid = grids[tag]
    assert(grid, 'game.nearby called on non-indexed tag')
    local actors = {}
    local n = 1

    for i = mini, maxi do
      if grid[i] then
        for j = minj, maxj do
          --game.trace_circle(pos, v2((i+0.5) * cell_size, (j+0.5) * cell_size), 2)
          if grid[i][j] then
            for _, a in ipairs(grid[i][j]) do
              if not a.is_dead and v2.sqrmag(a.pos - pos) <= radius*radius then
                actors[n] = a
                n = n + 1
              end
            end
          end
        end
      end
    end

    return actors
  end
end

function init_interaction(game)
  local radius = 350

  local interaction_set = {}
  
  local function interact_with(actors)
    for a in pairs(interaction_set) do
      a.set_interaction_level(0)
      interaction_set[a] = nil
    end
    for _, a in ipairs(actors) do
      interaction_set[a] = true
    end
  end

  local function update_interaction_level ()
    for a in pairs(interaction_set) do
      a.set_interaction_level(0.001 + game.get_activity_level())
      game.trace_circle(a.pos, a.pos, 20)
    end
  end

  local wait = coroutine.yield

  local manage_narrative = coroutine.wrap(function ()
    print(1)
    while true do
      local position = v2(
        math.random(C.left_bound, C.right_bound),
        math.random(C.lower_bound, C.upper_bound))
      local actors = irandomize(game.nearby(position, radius, 'interactive'))
      for i = 25, #actors do actors[i] = nil end
      interact_with(actors)
      for i = 1, 600 do
        wait()
      end
    end
  end)

  game.add_actor{
    preupdate = function ()
      manage_narrative()
      update_interaction_level()
    end
  }
end

function init_tracing(game)
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
    function self.draw_debug()
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
end

kernel.start_main_loop(actor_scene.make_actor_scene(
  {'trace_cleanup', 'preupdate', 'update'},
  {'draw_setup', 'draw_outline', 'draw_fill', 'draw_inner_outline',
   'draw_inner_fill', 'draw_debug'},
  function (game)
    math.randomseed(os.time())
    game.resources = require 'resources'

    init_sensing(game)
    init_collision_detection(game,
      {'prey', 'foliage', 'carrion', 'interactive'})
    init_interaction(game)
    init_tracing(game)

    function game.get_bounds_correction(pos)
      return v2(
        pos.x < 0 and 1 or pos.x > C.width and -1 or 0,
        pos.y < 0 and 1 or pos.y > C.height and -1 or 0)
    end

    function game.out_of_world(pos, distance)
      return pos.x - distance < C.left_bound or
             pos.x + distance > C.right_bound or
             pos.y - distance < C.lower_bound or
             pos.y + distance > C.upper_bound
    end

    game.add_actor{
      draw_setup = function ()
        glClearColor(0.0, 0.0, 0.0, 0)
        glClear(GL_COLOR_BUFFER_BIT)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        if(game.is_key_down(string.byte('`'))) then
          glOrtho(-C.width, 2*C.width, -C.height, 2*C.height, 1, -1)
        else
          glOrtho(0, C.width, 0, C.height, 1, -1)
        end
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
      draw_debug = function ()
        glBegin(GL_LINE_LOOP)
        glVertex2d(C.left_bound, C.lower_bound)
        glVertex2d(C.right_bound, C.lower_bound)
        glVertex2d(C.right_bound, C.upper_bound)
        glVertex2d(C.left_bound, C.upper_bound)
        glEnd()
      end,
    }

    local predator_countdown
    local herbivore_countdown
    game.add_actor{
      preupdate = function ()
        if #game.get_actors_by_tag('predator') == 0 then
          predator_countdown = predator_countdown or 600
          predator_countdown = predator_countdown - 1
          if predator_countdown <= 0 then
            predator_countdown = nil
            game.add_actor(creatures.make_predator(
              game,
              v2(math.random() * C.width, math.random() * C.height)))
          end
        end
        if #game.get_actors_by_tag('herbivore') == 0 then
          herbivore_countdown = herbivore_countdown or 600
          herbivore_countdown = herbivore_countdown - 1
          if herbivore_countdown <= 0 then
            herbivore_countdown = nil
            game.add_actor(creatures.make_herbivore(
              game,
              v2(math.random() * C.width, math.random() * C.height)))
          end
        end
      end
    }
    
    ----- Generate Foliage Over Time -------------------------------------------
    game.add_actor{
      update=function()
        if math.random(100) < 5   then
          game.add_actor(creatures.make_foliage(game,v2(math.random() * C.width, math.random() * C.height), 0))
        end
      end
    }
    
    --- Load Scavengers ------------------------------------------------------
    for x = 0, C.width, C.scavenger_cell_size do
      for y = 0, C.height, C.scavenger_cell_size do
        game.add_actor(creatures.make_scavenger(game,v2(x, y)))
      end
    end

    --- Load Predators -------------------------------------------------------
    for i = 1, 3 do
      game.add_actor(creatures.make_predator(
        game,
        v2(math.random() * C.width, math.random() * C.height)))  
    end

    --- Load Herbivores ------------------------------------------------------
    for i = 1, 18 do 
      game.add_actor(creatures.make_herbivore(
        game,
        v2(math.random() * C.width, math.random() * C.height)))  
    end
    
    ----- Load Foliage -------------------------------------------------------
    for i = 1, 70 do 
      game.add_actor(creatures.make_foliage(
      game,
      v2(math.random() * C.width, math.random() * C.height), 0))
    end
    
    end))

