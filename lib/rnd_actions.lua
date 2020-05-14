local rnd_actions = {}

rnd = {}

function rnd.init(t)
    rnd[t] = {}
    for i = 1,6 do
        rnd[t][i] = {}
        rnd[t][i].param = "rate slew"
        rnd[t][i].playing = false
        rnd[t][i].time = 1/4
        rnd[t][i].rate_slew_min = 0
        rnd[t][i].rate_slew_max = 1
        rnd[t][i].pan_min = -100
        rnd[t][i].pan_max = 100
        rnd[t][i].clock = clock.run(rnd.go, t, i)
    end
    math.randomseed(os.time())
end

local param_targets =
{   ['rate slew'] = rnd.rate_slew
}

function rnd.go(t,i)
    while true do
        clock.sync(rnd[t][i].time)
        if rnd[t][i].playing then
            if rnd[t][i].param == "rate slew" then
                rnd.rate_slew(t,i)
            elseif rnd[t][i].param == "pan" then
                rnd.pan(t,i)
            end
        end
    end
end

function rnd.rate_slew(t,i)
    local min = rnd[t][i].rate_slew_min * 1000
    local max = rnd[t][i].rate_slew_max * 1000
    local random_slew = math.random(min,max)/10000
    softcut.rate_slew_time(t+1,random_slew)
end

function rnd.pan(t,i)
    --[[
    local min = rnd[t][i].rate_slew_min
    local max = rnd[t][i].rate_slew_max
    local random_pan = math.random(min,max)/100
    softcut.pan(t+1,random_pan)
    --]]
    --rightangleslice.pan_random(bank[t].id)
    rightangleslice.actions[3]['123'][1](bank[t][bank[t].id])
    rightangleslice.actions[3]['123'][2](bank[t][bank[t].id],t)
end
return rnd