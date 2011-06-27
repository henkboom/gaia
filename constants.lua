local on_pc = true
if on_pc then
  width = 3600
  height = 900
  initial_predators = 2
  initial_herbivores = 80
  initial_foliage = 100
else
  width = 1200
  height = 900
  initial_predators = 1
  initial_herbivores = 0
  initial_foliage = 0
end

sensitivity_multiplier = 140
herbivore_interaction_limit = 150

collision_cell_size = 32

scavenger_cell_size = 75

local buffer = 20
left_bound = -buffer
right_bound= width + buffer
lower_bound = -buffer
upper_bound = height + buffer

volume = 0.8
flip_stereo = true

draw_phases = {
  setup = -1,
  creature_interaction_glow_setup = 0,
  creature_interaction_glow= 0.5,
  creature_bg_glow_setup = 1,
  creature_bg_glow = 2,
  creature_bg_mask_setup = 3,
  creature_bg_mask = 4,
  creature_fg_glow_setup = 5,
  creature_fg_glow = 6,
  debug = 7
}

foliage_colors = {
  normal = {0.5, 0.3, 0.15},
  corpse = {0.8, 0.3, 0.15}
}

carrion_color = {0.72, 0.54, 0.27, 1}

scavenger_color = {1, 0.77, 0, 0}

herbivore_interaction_color = {0.3, 0.6, 0.6, 1}
herbivore_bg_color = {0.15, 0.6, 0.3}
herbivore_fg_color = {0, 0.43, 1}

predator_color = {1, 0.2, 0.7}

predator_base_scale = 0.5
