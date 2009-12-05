local C = {}

C.width = 1200
C.height = 900

C.scavenger_width = C.width/100
C.scavenger_height = C.height/100

local buffer = 20
C.left_bound = -buffer
C.right_bound= C.width + buffer
C.lower_bound = -buffer
C.upper_bound = C.height + buffer

C.volume= 1

return C
