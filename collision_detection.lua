local dokidoki_base = require 'dokidoki.base'
local v2 = require 'dokidoki.v2'

local C = game.constants
local cell_size = C.collision_cell_size
local grid_width = math.ceil(C.width / cell_size)
local grid_height = math.ceil(C.height / cell_size)

local component_list = {}
local grid = {}

function register(component)
  component_list[#component_list+1] = component
end

function count()
  return #component_list
end

function preupdate()
  grid = {}

  local needs_culling = false
  for n = 1, #component_list do
    local component = component_list[n]
    if component.dead then
      needs_culling = true
    else
      local pos = component.transform.pos
      local i = math.floor(pos.x / cell_size)
      local j = math.floor(pos.y / cell_size)

      -- still include dudes right on the edge
      if i == -1 then i = 0 end
      if i == grid_width then i = grid_width-1 end
      if j == -1 then j = 0 end
      if j == grid_height then j = grid_height-1 end

      if i >= 0 and i < grid_width and j >= 0 and j < grid_height then
        grid[i + j*grid_width] = component
        game.tracing.trace_circle(
          pos,
          v2((i+0.5) * cell_size, (j+0.5) * cell_size), cell_size/2)
      end
    end
  end

  if needs_culling then
    component_list = dokidoki_base.ifilter(
      function (c) return not c.dead end,
      component_list)
  end
end

function get_nearby(pos, radius)
  local mini = math.max(0, math.floor((pos.x - radius) / cell_size))
  local maxi = math.min(grid_width-1, math.ceil((pos.x + radius) / cell_size))
  local minj = math.max(0, math.floor((pos.y - radius) / cell_size))
  local maxj = math.min(grid_height-1, math.ceil((pos.y + radius) / cell_size))

  local near = {}

  for i = mini, maxi do
    for j = minj, maxj do
      --game.trace_circle(pos, v2((i+0.5) * cell_size, (j+0.5) * cell_size), 2)
      local c = grid[i + j*grid_width]
      if c and v2.sqrmag(c.transform.pos - pos) <= radius*radius then
        near[#near+1] = c
      end
    end
  end

  return near
end
