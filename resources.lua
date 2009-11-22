local mixer = require 'mixer'
local graphics = require 'dokidoki.graphics'

return {
  
  --- Sprite Graphics --------------------------------------------------------
  
  predator_outline = graphics.sprite_from_image('sprites/predator_head_outline.png', nil, 'center'),
  predator_fill = graphics.sprite_from_image('sprites/predator_head_fill.png', nil, 'center'),

	herbivore_outline = graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center'),
	herbivore_fill = graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center'),
	
	herbivore_inner_outline = graphics.sprite_from_image('sprites/herbivore_inner_outline.png', nil, 'center'),
	herbivore_inner_fill = graphics.sprite_from_image('sprites/herbivore_inner_fill.png', nil, 'center'),

  --- Sounds -----------------------------------------------------------------
  
  --predator_hunting = mixer.load_wav("sounds/predator_hunting.wav"),
  --predator_mating = mixer.load_wav("predator.wav"),
  predator_attack = mixer.load_wav("sounds/predator_attack.wav"),
  predator_eat = mixer.load_wav("sounds/predator_eat.wav"),
  --predator_reproduce = mixer.load_wav("predator.wav"),
  --predator_starve = mixer.load_wav("sounds/predator_starve.wav"),
  
  --herbivore_drone = mixer.load_wav("sounds/herbivore_drone.wav"),
  herbivore_reproduce = mixer.load_wav("sounds/herbivore_reproduce.wav"),
  herbivore_starve = mixer.load_wav("sounds/herbivore_starve.wav"),
  herbivore_eat1 = mixer.load_wav("sounds/herbivore_eat1.wav"),
  herbivore_eat2 = mixer.load_wav("sounds/herbivore_eat2.wav"),
  herbivore_eat3 = mixer.load_wav("sounds/herbivore_eat3.wav"),
  herbivore_eat4 = mixer.load_wav("sounds/herbivore_eat4.wav"),
  herbivore_eat5 = mixer.load_wav("sounds/herbivore_eat5.wav"),
}
