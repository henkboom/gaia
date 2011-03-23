require 'dokidoki.module' [[]]

local dokidoki_kernel = require 'dokidoki.kernel'
local dokidoki_game = require 'dokidoki.game'

dokidoki_kernel.set_video_mode(800, 600)

dokidoki_kernel.start_main_loop(dokidoki_game.make_game(
  {'preupdate', 'update', 'postupdate'},
  {'predraw', 'draw', 'postdraw'}, 
  'gaia'))
