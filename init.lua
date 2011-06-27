require 'dokidoki.module' [[]]
local jit = require 'jit'
jit.off()

local dokidoki_kernel = require 'dokidoki.kernel'
local dokidoki_game = require 'dokidoki.game'

dokidoki_kernel.set_video_mode(3072, 768)
dokidoki_kernel.set_fullscreen(true)

dokidoki_kernel.set_max_frameskip(4)

dokidoki_kernel.start_main_loop(dokidoki_game.make_game(
  {'preupdate', 'update', 'postupdate'},
  {'predraw', 'draw', 'postdraw'}, 
  'gaia'))
