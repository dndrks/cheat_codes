zilchmos = {}

function zilchmos.init(k,i)
  
  local which_pad = nil

  local alt = grid.alt
  
  if bank[i].focus_hold == false then
    which_pad = bank[i].id
  else
    which_pad = bank[i].focus_pad
  end

  local pad = bank[i][which_pad]

  which_bank = i
  if menu == 8 then
    help_menu = "zilchmo_"..k
  end
    if fingers[k][i].con == "1" then
      if k == 4 then
        --function loop_start_one()
          if grid.alt == 0 then
            pad.start_point = (8*(pad.clip-1)) + 1
          else
            for j = 1,16 do
              bank[i][j].start_point = (8*(bank[i][j].clip-1)) + 1
            end
          end
          if bank[i].focus_hold == false then
            softcut.loop_start(i+1,pad.start_point)
          end
        --end
      elseif k == 3 then
        if grid.alt == 0 then
          pad.pan = -1
        else
          for j = 1,16 do
            bank[i][j].pan = -1
          end
        end
        if bank[i].focus_hold == false then
          softcut.pan(i+1,-1)
        end
      elseif k == 2 then
        if grid.alt == 0 then
          if pad.level > 0 then
            pad.level = pad.level-0.125
          end
        else
          for j = 1,16 do
            if bank[i][j].level > 0 then
              bank[i][j].level = bank[i][j].level-0.125
            end
          end
        end
        if not pad.enveloped then
          if bank[i].focus_hold == false then
            softcut.level_slew_time(i+1,1.0)
            softcut.level(i+1,pad.level)
            softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
            softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
          end
        end
      end
    end
    if fingers[k][i].con == "2" then
      if k == 4 then
        if grid.alt == 0 then
          pad.start_point = 1+((8/16)*(which_pad-1))+(8*(pad.clip-1))
          pad.end_point = 1+((8/16)*which_pad)+(8*(pad.clip-1))
        else
          for j = 1,16 do
            bank[i][j].start_point = 1+((8/16)*(j-1))+(8*(bank[i][j].clip-1))
            bank[i][j].end_point = 1+((8/16)*j)+(8*(pad.clip-1))
          end
        end
        if bank[i].focus_hold == false then
          softcut.loop_start(i+1,pad.start_point)
          softcut.loop_end(i+1,pad.end_point)
        end
      elseif k == 3 then
        if grid.alt == 0 then
          pad.pan = 0
        else
          for j = 1,16 do
            bank[i][j].pan = 0
          end
        end
        if bank[i].focus_hold == false then
          softcut.pan(i+1,0)
        end
      elseif k == 2 then
        if grid.alt == 0 then
          if pad.level < 2.0 then
            pad.level = pad.level+0.125
          end
        else
          for j = 1,16 do
            if bank[i][j].level < 2.0 then
              bank[i][j].level = bank[i][j].level+0.125
            end
          end
        end
        if not pad.enveloped then
          if bank[i].focus_hold == false then
            softcut.level_slew_time(i+1,1.0)
            softcut.level(i+1,pad.level)
            softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
            softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
          end
        end
      end
    end
    if fingers[k][i].con == "3" then
      if k == 4 then
        local bpm_to_sixteenth = (60/bpm)/4
        if grid.alt == 0 then
          pad.start_point = (1+((8/16)*(which_pad-1)))+(8*(pad.clip-1))
          pad.end_point = pad.start_point + bpm_to_sixteenth
        else
          for j= 1,16 do
            bank[i][j].start_point = (1+((8/16)*(j-1)))+(8*(bank[i][j].clip-1))
            bank[i][j].end_point = bank[i][j].start_point + bpm_to_sixteenth
          end
        end
        if bank[i].focus_hold == false then
          softcut.loop_start(i+1,pad.start_point)
          softcut.loop_end(i+1,pad.end_point)
        end
      elseif k == 3 then
        if grid.alt == 0 then
          pad.pan = 1
        else
          for j = 1,16 do
            bank[i][j].pan = 1
          end
        end
        if bank[i].focus_hold == false then
          softcut.pan(i+1,1)
        end
      end
    end
    if fingers[k][i].con == "4" then
      if grid.alt == 0 then
        pad.end_point = (8*pad.clip)+1
      else
        for j = 1,16 do
          bank[i][j].end_point = (8*bank[i][j].clip)+1
        end
      end
      if bank[i].focus_hold == false then
        softcut.loop_end(i+1,pad.end_point)
      end
    end
    if fingers[k][i].con == "12" then
      if k == 4 then
        if grid.alt == 0 then
          local current_end = math.floor(pad.end_point * 100)
          local min_start = math.floor(((8*(pad.clip-1))+1) * 100)
          pad.start_point = math.random(min_start,current_end)/100
        else
          for j = 1,16 do
            local current_end = math.floor(bank[i][j].end_point*100)
            local min_start = math.floor(((8*(bank[i][j].clip-1))+1) * 100)
            bank[i][j].start_point = math.random(min_start,current_end)/100
          end
        end
        if pad.loop == true and pad.enveloped == false then
          if bank[i].focus_hold == false then
            cheat(i,which_pad)
          end
        end
      elseif k == 3 then
        if grid.alt == 0 then
          if pad.pan >= -0.9 then
            pad.pan = pad.pan - 0.1
          end
        else
          for j = 1,16 do
            if bank[i][j].pan >= -0.9 then
              bank[i][j].pan = bank[i][j].pan - 0.1
            end
          end
        end
        if bank[i].focus_hold == false then
          softcut.pan(i+1,pad.pan)
        end
      elseif k == 2 then
        if pad.pause == false then
          if grid.alt == 0 then
            pad.pause = true
          else
            for j = 1,16 do
              bank[i][j].pause = true
            end
          end
          if bank[i].focus_hold == false then
            softcut.level(i+1,0.0)
            softcut.rate(i+1,0.0)
          end
        else
          if grid.alt == 0 then
            pad.pause = false
          else
            for j = 1,16 do
              bank[i][j].pause = false
            end
          end
          if bank[i].focus_hold == false then
            if not pad.enveloped then
              softcut.level(i+1,pad.level)
            else
              cheat(i,which_pad)
            end
            softcut.rate(i+1,pad.rate*pad.offset)
          end
        end
      end
    end
    if fingers[k][i].con == "23" then
      if k == 4 then
        if grid.alt == 0 then
          local jump = math.random(100,900)/100+(8*(pad.clip-1))
          local current_difference = (pad.end_point - pad.start_point)
          if jump+current_difference >= 9+(8*(pad.clip-1)) then
            pad.end_point = 9+(8*(pad.clip-1))
            pad.start_point = pad.end_point - current_difference
          else
            pad.start_point = jump
            pad.end_point = pad.start_point + current_difference
          end
        else
          for j = 1,16 do
            local jump = math.random(100,900)/100+(8*(bank[i][j].clip-1))
            local current_difference = (bank[i][j].end_point - bank[i][j].start_point)
            if jump+current_difference >= 9+(8*(bank[i][j].clip-1)) then
              bank[i][j].end_point = 9+(8*(bank[i][j].clip-1))
              bank[i][j].start_point = bank[i][j].end_point - current_difference
            else
              bank[i][j].start_point = jump
              bank[i][j].end_point = bank[i][j].start_point + current_difference
            end
          end
        end
        -- ok
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      elseif k == 3 then
        if grid.alt == 0 then
          if pad.pan <= 0.9 then
            pad.pan = pad.pan + 0.1
          end
        else
          for j = 1,16 do
            if bank[i][j].pan <= 0.9 then
              bank[i][j].pan = bank[i][j].pan + 0.1
            end
          end
        end
        softcut.pan(i+1,bank[i][bank[i].id].pan)
      end
    end
    if fingers[k][i].con == "34" then
        if grid.alt == 0 then
          local current_start = math.floor(pad.start_point * 100)
          local max_end = math.floor(((8*pad.clip)+1) * 100)
          pad.end_point = math.random(current_start,max_end)/100
        else
          for j = 1,16 do
            local current_start = math.floor(bank[i][j].start_point * 100)
            local max_end = math.floor(((8*bank[i][j].clip)+1) * 100)
            bank[i][j].end_point = math.random(current_start,max_end)/100
          end
        end
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
    end
    if fingers[k][i].con == "13" then
      if k == 4 then
        if grid.alt == 0 then
          local double = (pad.end_point - pad.start_point)*2
          local maximum_val = 9+(8*(pad.clip-1))
          local minimum_val = 1+(8*(pad.clip-1))
          if pad.start_point - double >= minimum_val then
            pad.start_point = pad.end_point - double
          elseif pad.start_point - double < minimum_val then
            if pad.end_point + double < maximum_val then
              pad.end_point = pad.end_point + double
            end
          end
        else
          for j = 1,16 do
            local double = (bank[i][j].end_point - bank[i][j].start_point)*2
            local maximum_val = 9+(8*(bank[i][j].clip-1))
            local minimum_val = 1+(8*(bank[i][j].clip-1))
            if bank[i][j].start_point - double >= minimum_val then
              bank[i][j].start_point = bank[i][j].end_point - double
            elseif bank[i][j].start_point - double < minimum_val then
              if bank[i][j].end_point + double < maximum_val then
                bank[i][j].end_point = bank[i][j].end_point + double
              end
            end
          end
        end
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      elseif k == 3 then
        if grid.alt == 0 then
          pad.pan = pad.pan * -1
        else
          for j = 1,16 do
            bank[i][j].pan = bank[i][j].pan * -1
          end
        end
        softcut.pan(i+1,bank[i][bank[i].id].pan)
      end
    end
    if fingers[k][i].con == "24" then
      if k == 4 then
        local halve = ((pad.end_point - pad.start_point)/2)/2
        pad.start_point = pad.start_point + halve
        pad.end_point = pad.end_point - halve
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      end
    end
    if fingers[k][i].con == "14" then
      if grid.alt == 0 then
        pad.rate = pad.rate*-1
      else
        for j = 1,16 do
          bank[i][j].rate = bank[i][j].rate*-1
        end
      end
      if bank[i][bank[i].id].pause == false then
        softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
      end
    end
    if fingers[k][i].con == "124" then
      if grid.alt == 0 then
        if math.abs(pad.rate) < 4 then
          pad.rate = pad.rate*2
        end
      else
        for j = 1,16 do
          if math.abs(bank[i][j].rate) < 4 then
            bank[i][j].rate = bank[i][j].rate*2
          end
        end
      end
      if bank[i][bank[i].id].pause == false then
        softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
      end
    end
    if fingers[k][i].con == "134" then
      if grid.alt == 0 then
        if math.abs(pad.rate) > 0.125 then
          pad.rate = pad.rate/2
        end
      else
        for j = 1,16 do
          if math.abs(bank[i][j].rate) > 0.125 then
            bank[i][j].rate = bank[i][j].rate/2
          end
        end
      end
      if bank[i][bank[i].id].pause == false then
        softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
      end
    end
    if fingers[k][i].con == "123" then
      if k == 4 then
        if i == 1 then
          pad.start_point = bank[2][bank[2].id].start_point - (8*(bank[2][bank[2].id].clip-1))
          pad.end_point = bank[2][bank[2].id].end_point - (8*(bank[2][bank[2].id].clip-1))
        elseif i == 2 or 3 then
          pad.start_point = bank[1][bank[1].id].start_point + (8*(pad.clip-1))
          pad.end_point = bank[1][bank[1].id].end_point + (8*(pad.clip-1))
        end
        if bank[i].focus_hold == false then
          softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
          softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
          softcut.position(i+1,bank[i][bank[i].id].start_point)
        end
        -- LEFT OFF HERE
      elseif k == 3 then
        if grid.alt == 0 then
          pad.pan = math.random(-100,100)/100
        else
          for j = 1,16 do
            bank[i][j].pan = math.random(-100,100)/100
          end
        end
        softcut.pan(i+1,bank[i][bank[i].id].pan)
      end
    end
    if fingers[k][i].con == "234" then
      if k == 4 then
        if i == 3 then
          bank[3][bank[3].id].start_point = (bank[2][bank[2].id].start_point - (8*(bank[2][bank[2].id].clip-1))) + (8*(bank[3][bank[3].id].clip-1))
          bank[3][bank[3].id].end_point = (bank[2][bank[2].id].end_point - (8*(bank[2][bank[2].id].clip-1))) + (8*(bank[3][bank[3].id].clip-1))
        elseif i == 1 or 2 then
          pad.start_point = (bank[3][bank[3].id].start_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(pad.clip-1))
          pad.end_point = (bank[3][bank[3].id].end_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(pad.clip-1))
        end
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
        softcut.position(i+1,bank[i][bank[i].id].start_point)
      end
    end
    if fingers[k][i].con == "1234" then
      if grid.alt == 0 then
        if math.abs(pad.rate) < 4 then
          if pad.fifth == false then
            pad.rate = pad.rate*1.5
            pad.fifth = true
          else
            pad.rate = pad.rate < 0 and math.ceil(math.abs(pad.rate)) * -1 or pad.rate > 0 and math.ceil(math.abs(pad.rate))
            pad.fifth = false
            if math.abs(pad.rate) == 3 then
              pad.rate = pad.rate == 3 and 4 or pad.rate == -3 and -4
            end
          end
        end
      else
        for j = 1,16 do
          if math.abs(bank[i][j].rate) < 4 then
            if bank[i][j].fifth == false then
              bank[i][j].rate = bank[i][j].rate*1.5
              bank[i][j].fifth = true
            else
              bank[i][j].rate = bank[i][j].rate < 0 and math.ceil(math.abs(bank[i][j].rate)) * -1 or bank[i][j].rate > 0 and math.ceil(math.abs(bank[i][j].rate))
              bank[i][j].fifth = false
              if math.abs(bank[i][j].rate) == 3 then
                bank[i][j].rate = bank[i][j].rate == 3 and 4 or bank[i][j].rate == -3 and -4
              end
            end
          end
        end
      end
      if bank[i][bank[i].id].pause == false then
        softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
      end
    end

end

return zilchmos