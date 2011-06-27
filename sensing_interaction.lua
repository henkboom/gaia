local v2 = require 'dokidoki.v2'
local C = game.constants

local radius = 10000

local interaction_set = {}

local function interact_with(components)
  for c in pairs(interaction_set) do
    c.set_interaction_level(0)
    interaction_set[c] = nil
  end
  for _, c in ipairs(components) do
    interaction_set[c] = true
  end
end

local function update_interaction_level ()
  for c in pairs(interaction_set) do
    c.set_interaction_level(0.001 + game.sensing.get_activity_level())
    game.tracing.trace_circle(c.transform.pos, c.transform.pos, 10)
  end
end

local wait = coroutine.yield

local manage_narrative = coroutine.wrap(function ()
  while true do
    local position = v2(
      math.random(C.left_bound, C.right_bound),
      math.random(C.lower_bound, C.upper_bound))
    local components = game.interaction_collision.get_nearby(position, radius)
    table.sort(components, function (a, b)
      return v2.sqrmag(a.transform.pos - position) <
        v2.sqrmag(b.transform.pos - position)
    end)
    for i = 10, #components do components[i] = nil end
    interact_with(components)
    for i = 1, 8*60 do
      wait()
    end
  end
end)

function preupdate ()
  manage_narrative()
  update_interaction_level()
end

-- interaction sound stuff
local interaction_countdown = 0
local interaction_level = 0
update = function ()
  interaction_level = interaction_level * 0.99 +
                      game.sensing.get_activity_level() * 0.01
  interaction_countdown = interaction_countdown - interaction_level
  if interaction_countdown <= 0 then
    interaction_countdown = 4
    game.resources.interaction_wave:play(interaction_level * 4)
  end
end
