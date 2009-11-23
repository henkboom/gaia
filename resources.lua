local mixer = require 'mixer'
local graphics = require 'dokidoki.graphics'

local dummy_sound = {play = function() print('playing non-existent file!') end}

local function try_load_wav (filename)
  return mixer.load_wav(filename) or dummy_sound
end

return {
  
  --- Sprite Graphics --------------------------------------------------------
  
  predator_outline = graphics.sprite_from_image('sprites/predator_head_outline.png', nil, 'center'),
  predator_fill = graphics.sprite_from_image('sprites/predator_head_fill.png', nil, 'center'),

  herbivore_outline = graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center'),
  herbivore_fill = graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center'),
  
  herbivore_inner_outline = graphics.sprite_from_image('sprites/herbivore_inner_outline.png', nil, 'center'),
  herbivore_inner_fill = graphics.sprite_from_image('sprites/herbivore_inner_fill.png', nil, 'center'),

  --- Sounds -----------------------------------------------------------------
  
  --predator_hunting = try_load_wav("sounds/predator_hunting.wav"),
  --predator_mating = try_load_wav("predator.wav"),
  predator_attack = try_load_wav("sounds/predator_attack.wav"),
  predator_eat = try_load_wav("sounds/predator_eat.wav"),
  --predator_reproduce = try_load_wav("predator.wav"),
  --predator_starve = try_load_wav("sounds/predator_starve.wav"),
  
  --herbivore_drone = try_load_wav("sounds/herbivore_drone.wav"),
  herbivore_reproduce = try_load_wav("sounds/herbivore_reproduce.wav"),
  herbivore_starve = try_load_wav("sounds/herbivore_starve.wav"),
  herbivore_eat1 = try_load_wav("sounds/herbivore_eat1.wav"),
  herbivore_eat2 = try_load_wav("sounds/herbivore_eat2.wav"),
  herbivore_eat3 = try_load_wav("sounds/herbivore_eat3.wav"),
  herbivore_eat4 = try_load_wav("sounds/herbivore_eat4.wav"),
  herbivore_eat5 = try_load_wav("sounds/herbivore_eat5.wav"),
}
