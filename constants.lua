local C = {}

C.width = 1200
C.height = 900

C.sensitivity_multiplier = 140

C.scavenger_cell_size = 75

local buffer = 20
C.left_bound = -buffer
C.right_bound= C.width + buffer
C.lower_bound = -buffer
C.upper_bound = C.height + buffer

C.volume = 0.8
C.flip_stereo = true

return C
