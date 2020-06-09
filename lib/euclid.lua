local euclid = {}

local er = require 'er'

function euclid.reer(i)
    if euclid.track[i].k == 0 then
      for n=1,32 do euclid.track[i].s[n] = false end
    else
      --euclid.track[i].s = er.gen(euclid.track[i].k,euclid.track[i].n)
      euclid.track[i].s = euclid.rotate_pattern(er.gen(euclid.track[i].k,euclid.track[i].n), euclid.track[i].rotation)
    end
end

function euclid.trig()
    for i=1,3 do
        if euclid.track[i].s[euclid.track[i].pos] then
            cheat(i,euclid.track[i].pos + euclid.track[i].pad_offset)
        end
    end
end

function euclid.init()

    euclid.reset = false
    euclid.alt = false
    euclid.running = false
    euclid.track_edit = 1
    euclid.current_pattern = 0
    euclid.clock_div = 1/4
    euclid.clock = clock.run(euclid.step)

    euclid.track = {}
    for i = 1,3 do
        euclid.track[i] = {
            k = 0,
            n = 9 - i,
            pos = 1,
            s = {},
            rotation = 0,
            focus = 1,
            pad_offset = 0
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
end

function euclid.step()
    while true do
        clock.sync(euclid.clock_div)

        if euclid.reset then
            for i=1,3 do euclid.track[i].pos = 1 end
            euclid.reset = false
        else
            for i=1,3 do
                euclid.track[i].pos = (euclid.track[i].pos % euclid.track[i].n) + 1
            end
        end
        euclid.trig()
        redraw()
        --er.redraw()
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

return euclid