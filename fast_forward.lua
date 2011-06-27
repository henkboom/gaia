local kernel = require 'dokidoki.kernel'

function update()
  if game.keyboard.key_held(string.byte(' ')) then
    kernel.set_fps(300)
    kernel.set_max_frameskip(60)
  else
    kernel.set_fps(60)
    kernel.set_max_frameskip(6)
  end
end
