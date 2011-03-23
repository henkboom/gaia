local gl = require 'gl'
local mixer = require 'mixer'
local graphics = require 'dokidoki.graphics'

local dummy_sound = {play = function() print('playing non-existent file!') end}

local function try_load_wav (filename)
  return mixer.load_wav(filename) or dummy_sound
end

--- Sprite Graphics -----------------------------------------------------------

local predator_outline = graphics.sprite_from_image('sprites/predator_head_outline.png', nil, 'center')
predator_head_sprites = {
  predator_outline,
  graphics.sprite_from_image('sprites/predator_head_fill.png', nil, 'center')
}
predator_cell_sprites = {
  predator_outline,
  graphics.sprite_from_image('sprites/predator_cell_fill.png', nil, 'center')
}

herbivore_glow = graphics.sprite_from_image('sprites/herbivore_glow.png', nil, 'center')
herbivore_sprites = {
  graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center'),
  graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center'),
  graphics.sprite_from_image('sprites/herbivore_inner_outline.png', nil, 'center'),
  graphics.sprite_from_image('sprites/herbivore_inner_fill.png', nil, 'center')
}

scavenger_sprites = {
  graphics.sprite_from_image('sprites/scavenger_outline.png', nil, 'center')
}

foliage_sprites = {
  graphics.sprite_from_image('sprites/foliage_outline.png', nil, 'center')
}

--- Sounds --------------------------------------------------------------------

herbivore_eat1 = try_load_wav("sounds/herbivore_eat1.wav")
herbivore_eat2 = try_load_wav("sounds/herbivore_eat2.wav")
herbivore_eat3 = try_load_wav("sounds/herbivore_eat3.wav")
herbivore_eat4 = try_load_wav("sounds/herbivore_eat4.wav")
herbivore_eat5 = try_load_wav("sounds/herbivore_eat5.wav")
herbivore_reproduce = try_load_wav("sounds/herbivore_reproduce.wav")
herbivore_starve1 = try_load_wav("sounds/herbivore_starve1.wav")
herbivore_starve2 = try_load_wav("sounds/herbivore_starve2.wav")
herbivore_starve3 = try_load_wav("sounds/herbivore_starve3.wav")

interaction_wave = try_load_wav("sounds/interaction_fast_attack.wav")

predator_attack1 = try_load_wav("sounds/predator_attack1.wav")
predator_attack2 = try_load_wav("sounds/predator_attack2.wav")
predator_attack3 = try_load_wav("sounds/predator_attack3.wav")
predator_eat1 = try_load_wav("sounds/predator_eat1.wav")
predator_eat2 = try_load_wav("sounds/predator_eat2.wav")
predator_eat3 = try_load_wav("sounds/predator_eat3.wav")
predator_reproduce = try_load_wav("sounds/predator_reproduce.wav")
predator_starve = try_load_wav("sounds/predator_starve.wav")

--scavenger_attack = try_load_wav("sounds/scavenger_attack.wav")
--scavenger_leave = try_load_wav("sounds/scavenger_leave.wav")
scavenger_nibble1 = try_load_wav("sounds/scavenger_nibble1.wav")
scavenger_nibble2 = try_load_wav("sounds/scavenger_nibble2.wav")
scavenger_nibble3 = try_load_wav("sounds/scavenger_nibble3.wav")
scavenger_nibble4 = try_load_wav("sounds/scavenger_nibble4.wav")
scavenger_nibble5 = try_load_wav("sounds/scavenger_nibble5.wav")

local function smoothen(sprite)
  gl.glBindTexture(gl.GL_TEXTURE_2D, sprite.tex.name)
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
end

local function smoothen_all(sprites)
  for i = 1, #sprites do
    smoothen(sprites[i])
  end
end

smoothen_all(predator_head_sprites)
smoothen(herbivore_glow)
smoothen_all(herbivore_sprites)
smoothen_all(scavenger_sprites)
smoothen_all(foliage_sprites)
