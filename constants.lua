width = 1200
height = 900

sensitivity_multiplier = 140
herbivore_interaction_limit = 150

scavenger_cell_size = 75

local buffer = 20
left_bound = -buffer
right_bound= width + buffer
lower_bound = -buffer
upper_bound = height + buffer

volume = 0.8
flip_stereo = true

draw_phases = {
  creature_bg_glow_setup = 1,
  creature_bg_glow = 2,
  creature_bg_mask_setup = 3,
  creature_bg_mask = 4,
  creature_fg_glow_setup = 5,
  creature_fg_glow = 6,
  creature_fg_mask_setup = 7,
  creature_fg_mask = 8,
  debug = 9
}

foliage_colors = {
  normal = {0.5, 0.3, 0.15},
  corpse = {0.8, 0.3, 0.15}
}
