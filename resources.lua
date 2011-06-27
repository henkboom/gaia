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
predator_tail_sprites = {
  predator_outline,
  graphics.sprite_from_image('sprites/predator_cell_fill.png', nil, 'center')
}

herbivore_interaction_glow = graphics.sprite_from_image('sprites/herbivore_glow.png', nil, 'center')
herbivore_bg_glow = graphics.sprite_from_image('sprites/herbivore_outline.png', nil, 'center')
herbivore_bg_mask = graphics.sprite_from_image('sprites/herbivore_fill.png', nil, 'center')
herbivore_fg_glows = {
  graphics.sprite_from_image('sprites/herbivore_detail1.png', nil, 'center'),
  --graphics.sprite_from_image('sprites/herbivore_detail2.png', nil, 'center'),
}

scavenger_sprites = {
  graphics.sprite_from_image('sprites/scavenger_outline.png', nil, 'center')
}

foliage_sprites = {
  graphics.sprite_from_image('sprites/foliage_outline.png', nil, 'center')
}

--- Sounds --------------------------------------------------------------------

herbivore_eat_sounds = {
  try_load_wav("sounds/herbivore_eat1.wav"),
  try_load_wav("sounds/herbivore_eat2.wav"),
  try_load_wav("sounds/herbivore_eat3.wav"),
  try_load_wav("sounds/herbivore_eat4.wav"),
  try_load_wav("sounds/herbivore_eat5.wav")
}
herbivore_reproduce = try_load_wav("sounds/herbivore_reproduce.wav")
herbivore_starve_sounds = {
  try_load_wav("sounds/herbivore_starve1.wav"),
  try_load_wav("sounds/herbivore_starve2.wav"),
  try_load_wav("sounds/herbivore_starve3.wav")
}

interaction_wave = try_load_wav("sounds/interaction_fast_attack.wav")

predator_attack_sounds = {
  try_load_wav("sounds/predator_attack1.wav"),
  try_load_wav("sounds/predator_attack2.wav"),
  try_load_wav("sounds/predator_attack3.wav")
}
predator_eat_sounds = {
  try_load_wav("sounds/predator_eat1.wav"),
  try_load_wav("sounds/predator_eat2.wav"),
  try_load_wav("sounds/predator_eat3.wav")
}
predator_reproduce = try_load_wav("sounds/predator_reproduce.wav")
predator_starve = try_load_wav("sounds/predator_starve.wav")

scavenger_nibble_sounds = {
  try_load_wav("sounds/scavenger_nibble1.wav"),
  try_load_wav("sounds/scavenger_nibble2.wav"),
  try_load_wav("sounds/scavenger_nibble3.wav"),
  try_load_wav("sounds/scavenger_nibble4.wav"),
  try_load_wav("sounds/scavenger_nibble5.wav")
}

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
smoothen(herbivore_interaction_glow)
smoothen(herbivore_bg_glow)
smoothen(herbivore_bg_mask)
smoothen_all(herbivore_fg_glows)
smoothen_all(scavenger_sprites)
smoothen_all(foliage_sprites)
