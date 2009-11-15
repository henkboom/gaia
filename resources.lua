local graphics = require 'dokidoki.graphics'

return {
  predator_outline = graphics.sprite_from_image('sprites/predator_outline.png', nil, 'center'),
  predator_fill = graphics.sprite_from_image('sprites/predator_fill.png', nil, 'center'),

	herbivore_outline = graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center'),
	herbivore_fill = graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center'),
}
