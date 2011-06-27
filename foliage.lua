local C = game.constants
local args = ...

---- Basic Components ---------------------------------------------------------
transform = game.add_component(self, 'dokidoki.transform', { pos=args.pos })

---- Renderer Components ------------------------------------------------------
game.add_component(self, 'sprite', {
  phase = C.draw_phases.creature_bg_glow,
  color = C.foliage_colors[args.foliage_type],
  image = game.resources.foliage_sprites[1]
})

---- Initialization -----------------------------------------------------------
game.foliage_collision.register(self)
