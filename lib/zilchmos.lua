zilchmos = {}

--[[
    focus_hold is only [0,1] -> change this to a boolean
    which_bank is a global & being set from inside of here
    bpm
    grid_alt should be boolean
]]--


----------------------------------------
--- helper functions

-- this function tanks a single bank, and applies function fn to each pad
-- varargs (...) allows an optional set of args to be applied to all pads
function zilchmos.map( fn, bank, ... ) -- this is a local bank, represents bank[i]
  for pad,_ in ipairs( bank ) do -- will execute for each of the 16 elements in bank
    fn( pad, ... ) -- pass each pad to the supplied function
  end
end


-- FIXME factor out this function and just map over .window
function zilchmos.map_window( bank )
  for j = 1,16 do
    zilchmos.window( b[j], j )
  end
end

-- FIXME factor out this function and just map over .window
function zilchmos.map_fixed_window( bank )
  for j = 1,16 do
    zilchmos.fixed_window( b[j], j )
  end
end


--------------------------------------
--- actions


-- pads

function zilchmos.start_point( pad )
  pad.start_point = (8*(pad.clip-1)) + 1
end

function zilchmos.pan( pad, position )
  pad.pan = position
end

function zilchmos.level_inc( pad, delta )
  pad.level = util.clamp( pad.level + delta, 0, 2 )
end

function zilchmos.window( pad, p ) -- TODO can get p from pad? add k to line:1883?
  -- p represents which # pad it is. this should be inherent to the pad table
  pad.start_point = 1+((8/16)*(p-1))+(8*(pad.clip-1))
  pad.end_point   = 1+((8/16)*p)+(8*(pad.clip-1))
end

function zilchmos.fixed_window( pad, p ) -- TODO can get p from pad? add k to line:1883?
  pad.start_point = (1+((8/16)*(p-1)))+(8*(pad.clip-1))
  pad.end_point   = pad.start_point + (60/bpm)/4
end

function zilchmos.end_point( pad )
  pad.end_point = (8*pad.clip)+1
end


-- softcut

function zilchmos.sc_loop_point( pad, i )
  softcut.loop_start(i+1,pad.start_point)
end

function zilchmos.sc_pan( pad, i )
  softcut.pan(i+1,pad.pan)
end

function zilchmos.sc_level( pad, i )
  if not pad.enveloped then
    softcut.level_slew_time(i+1,1.0)
    softcut.level(i+1,pad.level)
    softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
    softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
  end
end

-- TODO should combine these
function zilchmos.sc_loop_window( pad, i )
  softcut.loop_start(i+1,pad.start_point)
  softcut.loop_end(i+1,pad.end_point)
end

function zilchmos.sc_loop_end( pad, i )
  softcut.loop_end(i+1,pad.end_point)
end



---------------------------------------
--- main function

function zilchmos.init(k,i)

  -- TODO remove this global access? at least wrap it in a function
  which_bank = i -- just setting this global? why here?

  local b = bank[i] -- just alias for shorter lines
  local p = (b.focus_hold == 1) and b.focus_pad or b.id -- was 'which_pad'

  if menu == 8 then
    help_menu = "zilchmo_"..k
  end

  if fingers[k][i].con == "1" then
    if k == 4 then
      if grid.alt == 0 then
        zilchmos.start_point(b[p])
      else
        zilchmos.map( zilchmos.start_point, b ) -- map start_point over the whole bank
      end
      if b.focus_hold == 0 then
        zilchmos.sc_loop_point(b[p], i)
      end
    elseif k == 3 then
      if grid.alt == 0 then
        zilchmos.pan( b[p], -1 )
      else
        zilchmos.map( zilchmos.pan, b, -1 )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_pan( b[p], i )
      end
    elseif k == 2 then
      if grid.alt == 0 then
        zilchmos.level_inc( b[p], -0.125 )
      else
        zilchmos.map( zilchmos.level_inc, b, -0.125 )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_level( b[p], i )
      end
    end
  end
  if fingers[k][i].con == "2" then
    if k == 4 then
      if grid.alt == 0 then
        zilchmos.window( b[p], p )
      else
        zilchmos.map_window( b ) -- FIXME update sigs so we can use .map( .window )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_loop_window( b[p], i )
      end
    elseif k == 3 then
      if grid.alt == 0 then
        zilchmos.pan( b[p], 0 ) -- pan centre
      else
        zilchmos.map( zilchmos.pan, b, 0 )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_pan( b[p], i )
      end
    elseif k == 2 then
      if grid.alt == 0 then
        zilchmos.level_inc( b[p], 0.125 )
      else
        zilchmos.map( zilchmos.level_inc, b, 0.125 )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_level( pad, i )
      end
    end
  end
  if fingers[k][i].con == "3" then
    if k == 4 then
      if grid.alt == 0 then
        zilchmos.fixed_window( b[p], p )
      else
        zilchmos.map_fixed_window( b )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_loop_window( b[p], i )
      end
    elseif k == 3 then
      if grid.alt == 0 then
        zilchmos.pan( b[p], 1 )
      else
        zilchmos.map( zilchmos.pan, b, 1 )
      end
      if b.focus_hold == 0 then
        zilchmos.sc_pan( b[p], i )
      end
    end
  end
  if fingers[k][i].con == "4" then
    if grid.alt == 0 then
      zilchmos.end_point( b[p] )
    else
      zilchmos.map( zilchmos.end_point, b )
    end
    if b.focus_hold == 0 then
      zilchmos.sc_loop_end( b[p], i )
    end
  end



-- UP TO HERE




  if fingers[k][i].con == "12" then
    if k == 4 then
      if grid.alt == 0 then
        local current_end = math.floor(b[p].end_point * 100)
        local min_start = math.floor(((8*(b[p].clip-1))+1) * 100)
        b[p].start_point = math.random(min_start,current_end)/100
      else
        for j = 1,16 do
          local current_end = math.floor(b[j].end_point*100)
          local min_start = math.floor(((8*(b[j].clip-1))+1) * 100)
          b[j].start_point = math.random(min_start,current_end)/100
        end
      end
      if b[p].loop == true and b[p].enveloped == false then
        if b.focus_hold == 0 then
          cheat(i,p)
        end
      end
    elseif k == 3 then
      if grid.alt == 0 then
        if b[p].pan >= -0.9 then
          b[p].pan = b[p].pan - 0.1
        end
      else
        for j = 1,16 do
          if b[j].pan >= -0.9 then
            b[j].pan = b[j].pan - 0.1
          end
        end
      end
      if b.focus_hold == 0 then
        softcut.pan(i+1,b[p].pan)
      end
    elseif k == 2 then
      if b[p].pause == false then
        if grid.alt == 0 then
          b[p].pause = true
        else
          for j = 1,16 do
            b[j].pause = true
          end
        end
        if b.focus_hold == 0 then
          softcut.level(i+1,0.0)
          softcut.rate(i+1,0.0)
        end
      else
        if grid.alt == 0 then
          b[p].pause = false
        else
          for j = 1,16 do
            b[j].pause = false
          end
        end
        if b.focus_hold == 0 then
          if not b[p].enveloped then
            softcut.level(i+1,b[p].level)
          else
            cheat(i,p)
          end
          softcut.rate(i+1,b[p].rate*b[p].offset)
        end
      end
    end
  end
  if fingers[k][i].con == "23" then
    if k == 4 then
      if grid.alt == 0 then
        local jump = math.random(100,900)/100+(8*(b[p].clip-1))
        local current_difference = (b[p].end_point - b[p].start_point)
        if jump+current_difference >= 9+(8*(b[p].clip-1)) then
          b[p].end_point = 9+(8*(b[p].clip-1))
          b[p].start_point = b[p].end_point - current_difference
        else
          b[p].start_point = jump
          b[p].end_point = b[p].start_point + current_difference
        end
      else
        for j = 1,16 do
          local jump = math.random(100,900)/100+(8*(b[j].clip-1))
          local current_difference = (b[j].end_point - b[j].start_point)
          if jump+current_difference >= 9+(8*(b[j].clip-1)) then
            b[j].end_point = 9+(8*(b[j].clip-1))
            b[j].start_point = b[j].end_point - current_difference
          else
            b[j].start_point = jump
            b[j].end_point = b[j].start_point + current_difference
          end
        end
      end
      -- ok
      softcut.loop_start(i+1,b[b.id].start_point)
      softcut.loop_end(i+1,b[b.id].end_point)
    elseif k == 3 then
      if grid.alt == 0 then
        if b[p].pan <= 0.9 then
          b[p].pan = b[p].pan + 0.1
        end
      else
        for j = 1,16 do
          if b[j].pan <= 0.9 then
            b[j].pan = b[j].pan + 0.1
          end
        end
      end
      softcut.pan(i+1,b[b.id].pan)
    end
  end
  if fingers[k][i].con == "34" then
      if grid.alt == 0 then
        local current_start = math.floor(b[p].start_point * 100)
        local max_end = math.floor(((8*b[p].clip)+1) * 100)
        b[p].end_point = math.random(current_start,max_end)/100
      else
        for j = 1,16 do
          local current_start = math.floor(b[j].start_point * 100)
          local max_end = math.floor(((8*b[j].clip)+1) * 100)
          b[j].end_point = math.random(current_start,max_end)/100
        end
      end
      softcut.loop_end(i+1,b[b.id].end_point)
  end
  if fingers[k][i].con == "13" then
    if k == 4 then
      if grid.alt == 0 then
        local double = (b[p].end_point - b[p].start_point)*2
        local maximum_val = 9+(8*(b[p].clip-1))
        local minimum_val = 1+(8*(b[p].clip-1))
        if b[p].start_point - double >= minimum_val then
          b[p].start_point = b[p].end_point - double
          --softcut.loop_start(i+1,b[p].start_point)
        elseif b[p].start_point - double < minimum_val then
          if b[p].end_point + double < maximum_val then
            b[p].end_point = b[p].end_point + double
            --softcut.loop_end(i+1,b[p].end_point)
          end
        end
      else
        for j = 1,16 do
          local double = (b[j].end_point - b[j].start_point)*2
          local maximum_val = 9+(8*(b[j].clip-1))
          local minimum_val = 1+(8*(b[j].clip-1))
          if b[j].start_point - double >= minimum_val then
            b[j].start_point = b[j].end_point - double
            --softcut.loop_start(i+1,b[j].start_point)
          elseif b[j].start_point - double < minimum_val then
            if b[j].end_point + double < maximum_val then
              b[j].end_point = b[j].end_point + double
              --softcut.loop_end(i+1,b[b.id].end_point)
            end
          end
        end
      end
      softcut.loop_start(i+1,b[b.id].start_point)
      softcut.loop_end(i+1,b[b.id].end_point)
    elseif k == 3 then
      if grid.alt == 0 then
        b[p].pan = b[p].pan * -1
      else
        for j = 1,16 do
          b[j].pan = b[j].pan * -1
        end
      end
      softcut.pan(i+1,b[b.id].pan)
    end
  end
  if fingers[k][i].con == "24" then
    if k == 4 then
      local halve = ((b[p].end_point - b[p].start_point)/2)/2
      b[p].start_point = b[p].start_point + halve
      b[p].end_point = b[p].end_point - halve
      softcut.loop_start(i+1,b[b.id].start_point)
      softcut.loop_end(i+1,b[b.id].end_point)
    end
  end
  if fingers[k][i].con == "14" then
    if grid.alt == 0 then
      b[p].rate = b[p].rate*-1
    else
      for j = 1,16 do
        b[j].rate = b[j].rate*-1
      end
    end
    if b[b.id].pause == false then
      softcut.rate(i+1, b[b.id].rate*b[b.id].offset)
    end
  end
  if fingers[k][i].con == "124" then
    if grid.alt == 0 then
      if math.abs(b[p].rate) < 4 then
        b[p].rate = b[p].rate*2
      end
    else
      for j = 1,16 do
        if math.abs(b[j].rate) < 4 then
          b[j].rate = b[j].rate*2
        end
      end
    end
    if b[b.id].pause == false then
      softcut.rate(i+1, b[b.id].rate*b[b.id].offset)
    end
  end
  if fingers[k][i].con == "134" then
    if grid.alt == 0 then
      if math.abs(b[p].rate) > 0.125 then
        b[p].rate = b[p].rate/2
      end
    else
      for j = 1,16 do
        if math.abs(b[j].rate) > 0.125 then
          b[j].rate = b[j].rate/2
        end
      end
    end
    if b[b.id].pause == false then
      softcut.rate(i+1, b[b.id].rate*b[b.id].offset)
    end
  end
  if fingers[k][i].con == "123" then
    if k == 4 then
      if i == 1 then
        b[p].start_point = bank[2][bank[2].id].start_point - (8*(bank[2][bank[2].id].clip-1))
        b[p].end_point = bank[2][bank[2].id].end_point - (8*(bank[2][bank[2].id].clip-1))
      elseif i == 2 or 3 then
        b[p].start_point = bank[1][bank[1].id].start_point + (8*(b[p].clip-1))
        b[p].end_point = bank[1][bank[1].id].end_point + (8*(b[p].clip-1))
      end
      if b.focus_hold == 0 then
        softcut.loop_start(i+1,b[b.id].start_point)
        softcut.loop_end(i+1,b[b.id].end_point)
        softcut.position(i+1,b[b.id].start_point)
      end
      -- LEFT OFF HERE
    elseif k == 3 then
      if grid.alt == 0 then
        b[p].pan = math.random(-100,100)/100
      else
        for j = 1,16 do
          b[j].pan = math.random(-100,100)/100
        end
      end
      softcut.pan(i+1,b[b.id].pan)
    end
  end
  if fingers[k][i].con == "234" then
    if k == 4 then
      if i == 3 then
        bank[3][bank[3].id].start_point = (bank[2][bank[2].id].start_point - (8*(bank[2][bank[2].id].clip-1))) + (8*(bank[3][bank[3].id].clip-1))
        bank[3][bank[3].id].end_point = (bank[2][bank[2].id].end_point - (8*(bank[2][bank[2].id].clip-1))) + (8*(bank[3][bank[3].id].clip-1))
      elseif i == 1 or 2 then
        b[p].start_point = (bank[3][bank[3].id].start_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(b[p].clip-1))
        b[p].end_point = (bank[3][bank[3].id].end_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(b[p].clip-1))
      end
      softcut.loop_start(i+1,b[b.id].start_point)
      softcut.loop_end(i+1,b[b.id].end_point)
      softcut.position(i+1,b[b.id].start_point)
    end
  end
  if fingers[k][i].con == "1234" then
    if grid.alt == 0 then
      if math.abs(b[p].rate) < 4 then
        if b[p].fifth == false then
          b[p].rate = b[p].rate*1.5
          b[p].fifth = true
        else
          b[p].rate = b[p].rate < 0 and math.ceil(math.abs(b[p].rate)) * -1 or b[p].rate > 0 and math.ceil(math.abs(b[p].rate))
          b[p].fifth = false
          if math.abs(b[p].rate) == 3 then
            b[p].rate = b[p].rate == 3 and 4 or b[p].rate == -3 and -4
          end
        end
      end
    else
      for j = 1,16 do
        if math.abs(b[j].rate) < 4 then
          if b[j].fifth == false then
            b[j].rate = b[j].rate*1.5
            b[j].fifth = true
          else
            b[j].rate = b[j].rate < 0 and math.ceil(math.abs(b[j].rate)) * -1 or b[j].rate > 0 and math.ceil(math.abs(b[j].rate))
            b[j].fifth = false
            if math.abs(b[j].rate) == 3 then
              b[j].rate = b[j].rate == 3 and 4 or b[j].rate == -3 and -4
            end
          end
        end
      end
    end
    if b[b.id].pause == false then
      softcut.rate(i+1, b[b.id].rate*b[b.id].offset)
    end
  end

end

return zilchmos
