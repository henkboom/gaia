--TODO render jobs

local dokidoki_base = require 'dokidoki.base'

local render_jobs = {}
local needs_sorting = false

function add_job(component, order, callback)
  assert(component)
  assert(type(order) == 'number')
  assert(callback)

  render_jobs[#render_jobs+1] = {
    component=component,
    order=order,
    callback=callback
  }
  needs_sorting = true
end

function draw()
  if needs_sorting then
    table.sort(render_jobs, function (a, b) return a.order < b.order end)
    needs_sorting = false
  end

  local needs_culling = false
  for i = 1, #render_jobs do
    local job = render_jobs[i]
    if job.component.dead then
      needs_culling = true
    else
      job.callback()
    end
  end

  if needs_culling then
    render_jobs = dokidoki_base.ifilter(
      function (c) return not c.dead end,
      render_jobs)
  end
end
