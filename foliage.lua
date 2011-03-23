local C = game.constants
local args = ...

transform = game.add_component(self, 'dokidoki.transform', { pos=args.pos })
creature_renderer = game.add_component(self, 'creature_renderer', {
  color = C.foliage_colors[args.foliage_type],
  scale = 1,
  sprites = game.resources.foliage_sprites
})
