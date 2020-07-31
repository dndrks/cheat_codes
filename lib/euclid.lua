local euclid = {}

local er = require 'er'

function euclid.reer(i)
  if euclid.track[i].k == 0 then
    for n=1,32 do euclid.track[i].s[n] = false end
  else
    euclid.track[i].s = euclid.rotate_pattern(er.gen(euclid.track[i].k,euclid.track[i].n), euclid.track[i].rotation)
  end
end

function euclid.trig(target)
  if euclid.track[target].s[euclid.track[target].pos] then
    if euclid.track[target].mode == "single" then
      cheat(target,euclid.rotate_pads(bank[target].id + euclid.track[target].pad_offset))
    elseif euclid.track[target].mode == "span" then
      bank[target].id = euclid.rotate_pads(euclid.track[target].pos + euclid.track[target].pad_offset)
      selected[target].x = (5*(target-1)+1)+(math.ceil(bank[target].id/4)-1)
      if (bank[target].id % 4) ~= 0 then
        selected[target].y = 9-(bank[target].id % 4)
      else
        selected[target].y = 5
      end
      cheat(target,euclid.rotate_pads(euclid.track[target].pos + euclid.track[target].pad_offset))
    end
  end
end

function euclid.init()

  euclid.reset = false
  euclid.alt = false
  euclid.running = false
  euclid.track_edit = 1
  euclid.current_pattern = 0
  euclid.clock_div = {1/2,1/2,1/2}
  euclid.clock =
    { clock.run(euclid.step,1)
    , clock.run(euclid.step,2)
    , clock.run(euclid.step,3)
    }
  euclid.screen_focus = "left"

  euclid.track = {}
  for i = 1,3 do
    euclid.track[i] = {
      k = 0,
      n = 8,
      pos = 1,
      s = {},
      rotation = 0,
      focus = 1,
      pad_offset = 0,
      mode = "single"
    }
  end

  euclid.pattern = {}
  for i = 1,112 do
      euclid.pattern[i] = {
        data = 0,
        k = {},
        n = {}
      }
    for x=1,3 do
      euclid.pattern[i].k[x] = 0
      euclid.pattern[i].n[x] = 0
    end
  end

  for i=1,3 do euclid.reer(i) end

end

function euclid.reset_pattern()
  euclid.reset = true
  for i=1,3 do euclid.track[i].pos = 1 end
  euclid.reset = false
end

function euclid.step(target)
  while true do
    clock.sync(euclid.clock_div[target])
    euclid.track[target].pos = (euclid.track[target].pos % euclid.track[target].n) + 1
    euclid.trig(target)
    redraw()
  end
end

function euclid.rotate_pattern(t, rot, n, r)
  -- rotate_pattern comes to us via okyeron and stackexchange, which appeared originally in justmat's foulplay
  n, r = n or #t, {}
  rot = rot % n
  for i = 1, rot do
    r[i] = t[n - rot + i]
  end
  for i = rot + 1, n do
    r[i] = t[i - rot]
  end
  return r
end

function euclid.rotate_pads(i)
  if i < 1 then
    i = (16 - (1 - i) % (15))+1;
  end
  return 1 + (i - 1) % 16
end

return euclid