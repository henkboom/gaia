local C = game.constants

function play_random_from(sounds, position, volume)
  play(sounds[math.random(#sounds)], position, volume)
end

function play(sound, position, volume)
  volume = volume or 1

  local left = 1
  local right = 1
  local x = math.min(math.max(position.x / C.width, 0), 1)
  if x < 0.5 then
    right = x*2
  end
  if x > 0.5 then
    left = (1-x)*2
  end

  if flip_stereo then
    left, right = right, left
  end

  sound:play(left * volume * C.volume, right * volume * C.volume)
end
