local mixer = require 'mixer'
local graphics = require 'dokidoki.graphics'

local dummy_sound = {play = function() print('playing non-existent file!') end}

local function try_load_wav (filename)
  return mixer.load_wav(filename) or dummy_sound
end

return {
  
  --- Sprite Graphics --------------------------------------------------------
  
  predator_outline = graphics.sprite_from_image('sprites/predator_head_outline.png', nil, 'center'),
  predator_head_fill = graphics.sprite_from_image('sprites/predator_head_fill.png', nil, 'center'),
  predator_cell_fill = graphics.sprite_from_image('sprites/predator_cell_fill.png', nil, 'center'),


  herbivore_outline = graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center'),
  herbivore_fill = graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center'),
  
  herbivore_inner_outline = graphics.sprite_from_image('sprites/herbivore_inner_outline.png', nil, 'center'),
  herbivore_inner_fill = graphics.sprite_from_image('sprites/herbivore_inner_fill.png', nil, 'center'),
  
  scavenger_outline = graphics.sprite_from_image('sprites/scavenger_outline.png', nil, 'center'),
  
  foliage_outline = graphics.sprite_from_image('sprites/foliage_outline.png', nil, 'center'),
  --- Sounds -----------------------------------------------------------------
  
  predator_attack1 = try_load_wav("sounds/predator_attack1.wav"),
  predator_attack2 = try_load_wav("sounds/predator_attack2.wav"),
  predator_attack3 = try_load_wav("sounds/predator_attack3.wav"),
  predator_eat1 = try_load_wav("sounds/predator_eat1.wav"),
  predator_eat2 = try_load_wav("sounds/predator_eat2.wav"),
  predator_eat3 = try_load_wav("sounds/predator_eat3.wav"),
  predator_reproduce = try_load_wav("sounds/predator_reproduce.wav"),
  predator_starve = try_load_wav("sounds/predator_starve.wav"),
  
  herbivore_reproduce = try_load_wav("sounds/herbivore_reproduce.wav"),
  herbivore_starve1 = try_load_wav("sounds/herbivore_starve1.wav"),
  herbivore_starve2 = try_load_wav("sounds/herbivore_starve2.wav"),
  herbivore_starve3 = try_load_wav("sounds/herbivore_starve3.wav"),
  herbivore_eat1 = try_load_wav("sounds/herbivore_eat1.wav"),
  herbivore_eat2 = try_load_wav("sounds/herbivore_eat2.wav"),
  herbivore_eat3 = try_load_wav("sounds/herbivore_eat3.wav"),
  herbivore_eat4 = try_load_wav("sounds/herbivore_eat4.wav"),
  herbivore_eat5 = try_load_wav("sounds/herbivore_eat5.wav"),
  
  scavenger_nibble1 = try_load_wav("sounds/scavenger_nibble1.wav"),
  scavenger_nibble2 = try_load_wav("sounds/scavenger_nibble2.wav"),
  scavenger_nibble3 = try_load_wav("sounds/scavenger_nibble3.wav"),
  scavenger_nibble4 = try_load_wav("sounds/scavenger_nibble4.wav"),
  scavenger_nibble5 = try_load_wav("sounds/scavenger_nibble5.wav"),
  scavenger_attack = try_load_wav("sounds/scavenger_attack.wav"),
  scavenger_leave = try_load_wav("sounds/scavenger_leave.wav"),
}
