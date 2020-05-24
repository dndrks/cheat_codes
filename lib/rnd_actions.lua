local rnd_actions = {}

rnd = {}

function rnd.init(t)
    rnd[t] = {}
    local targets = {"pan","rate","rate slew","delay send","loop"}
    for i = 1,5 do
        rnd[t][i] = {}
        rnd[t][i].param = targets[i]
        rnd[t][i].playing = false
        rnd[t][i].num = 1
        rnd[t][i].denom = 1
        rnd[t][i].time = rnd[t][i].num / rnd[t][i].denom
        rnd[t][i].rate_slew_min = 0
        rnd[t][i].rate_slew_max = 1
        rnd[t][i].pan_min = -100
        rnd[t][i].pan_max = 100
        rnd[t][i].rate_min = 0.125
        rnd[t][i].rate_max = 4
        rnd[t][i].clock = clock.run(rnd.go, t, i)
    end
    math.randomseed(os.time())
end

local param_targets =
{   ['rate slew'] = rnd.rate_slew
,   ['pan'] = rnd.pan
,   ['rate'] = rnd.rate
}

function rnd.go(t,i)
    while true do
        clock.sync(rnd[t][i].time)
        if rnd[t][i].playing then
            if rnd[t][i].param == "rate slew" then
                rnd.rate_slew(t,i)
            elseif rnd[t][i].param == "pan" then
                rnd.pan(t)
            elseif rnd[t][i].param == "delay send" then
                rnd.delay_send(t,i)
            elseif rnd[t][i].param == "rate" then
                rnd.rate(t,i)
            elseif rnd[t][i].param == "loop" then
                rnd.loop(t)
            end
        end
    end
end

function rnd.rate_slew(t,i)
    local min = util.round(rnd[t][i].rate_slew_min * 1000)
    local max = util.round(rnd[t][i].rate_slew_max * 1000)
    local random_slew = math.random(min,max)/10000
    softcut.rate_slew_time(t+1,random_slew)
end

function rnd.pan(t)
    rightangleslice.actions[3]['123'][1](bank[t][bank[t].id])
    rightangleslice.actions[3]['123'][2](bank[t][bank[t].id],t)
end

function rnd.rate(t,i)
    local rates = {0.125,0.25,0.5,1,2,4}
    local rates_to_int =
    {   [0.125] = 1
    ,   [0.25] = 2
    ,   [0.5] = 3
    ,   [1] = 4
    ,   [2] = 5
    ,   [4] = 6
    }
    local min = rates_to_int[rnd[t][i].rate_min]
    local max = rates_to_int[rnd[t][i].rate_max]
    local rand_rate = rates[math.random(min,max)]
    local rev = math.random(0,1)
    softcut.rate(t+1,rand_rate*(rev == 0 and -1 or 1))
end

function rnd.loop(t)
    local pre_loop = bank[t][bank[t].id].loop
    local loop = math.random(0,1)
    if loop == 0 then
        bank[t][bank[t].id].loop = true
        cheat(t,bank[t].id)
    else
        bank[t][bank[t].id].loop = false
        softcut.loop(t+1,0)
    end
end

function rnd.delay_send(t,i)
    local delay_send = math.random(0,1)
    for j = 1,16 do
        bank[t][j].left_delay_level = delay_send
        bank[t][j].right_delay_level = delay_send
    end
end

return rnd