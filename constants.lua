local C = {}

C.width = 1024
C.height = 768

local buffer = 50
C.left_bound = -buffer
C.right_bound= C.width + buffer
C.lower_bound = -buffer
C.upper_bound = C.height + buffer

return C
