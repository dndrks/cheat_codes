zilchmos = {}

function zilchmos.init(k,i)
  
  local which_pad = nil
  
  if bank[i].focus_hold == 0 then
    which_pad = bank[i].id
  elseif bank[i].focus_hold == 1 then
    which_pad = bank[i].focus_pad
  end

  which_bank = i
  if menu == 8 then
    help_menu = "zilchmo_"..k
  end
    if fingers[k][i].con == "1" then
      if k == 4 then
        if grid.alt == 0 then
          bank[i][which_pad].start_point = (8*(bank[i][which_pad].clip-1)) + 1
        else
          for j = 1,16 do
            bank[i][j].start_point = (8*(bank[i][j].clip-1)) + 1
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.loop_start(i+1,bank[i][which_pad].start_point)
        end
      elseif k == 3 then
        if grid.alt == 0 then
          bank[i][which_pad].pan = -1
        else
          for j = 1,16 do
            bank[i][j].pan = -1
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.pan(i+1,-1)
        end
      elseif k == 2 then
        if grid.alt == 0 then
          if bank[i][which_pad].level > 0 then
            bank[i][which_pad].level = bank[i][which_pad].level-0.125
          end
        else
          for j = 1,16 do
            if bank[i][j].level > 0 then
              bank[i][j].level = bank[i][j].level-0.125
            end
          end
        end
        if not bank[i][which_pad].enveloped then
          if bank[i].focus_hold == 0 then
            softcut.level_slew_time(i+1,1.0)
            softcut.level(i+1,bank[i][which_pad].level)
            softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,bank[i][which_pad].pan)*(bank[i][which_pad].left_delay_level*bank[i][which_pad].level))
            softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,bank[i][which_pad].pan)*(bank[i][which_pad].right_delay_level*bank[i][which_pad].level))
          end
        end
      end
    end
    if fingers[k][i].con == "2" then
      if k == 4 then
        if grid.alt == 0 then
          bank[i][which_pad].start_point = 1+((8/16)*(which_pad-1))+(8*(bank[i][which_pad].clip-1))
          bank[i][which_pad].end_point = 1+((8/16)*which_pad)+(8*(bank[i][which_pad].clip-1))
        else
          for j = 1,16 do
            bank[i][j].start_point = 1+((8/16)*(j-1))+(8*(bank[i][j].clip-1))
            bank[i][j].end_point = 1+((8/16)*j)+(8*(bank[i][which_pad].clip-1))
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.loop_start(i+1,bank[i][which_pad].start_point)
          softcut.loop_end(i+1,bank[i][which_pad].end_point)
        end
      elseif k == 3 then
        if grid.alt == 0 then
          bank[i][which_pad].pan = 0
        else
          for j = 1,16 do
            bank[i][j].pan = 0
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.pan(i+1,0)
        end
      elseif k == 2 then
        if grid.alt == 0 then
          if bank[i][which_pad].level < 2.0 then
            bank[i][which_pad].level = bank[i][which_pad].level+0.125
          end
        else
          for j = 1,16 do
            if bank[i][j].level < 2.0 then
              bank[i][j].level = bank[i][j].level+0.125
            end
          end
        end
        if not bank[i][which_pad].enveloped then
          if bank[i].focus_hold == 0 then
            softcut.level_slew_time(i+1,1.0)
            softcut.level(i+1,bank[i][which_pad].level)
            softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,bank[i][which_pad].pan)*(bank[i][which_pad].left_delay_level*bank[i][which_pad].level))
            softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,bank[i][which_pad].pan)*(bank[i][which_pad].right_delay_level*bank[i][which_pad].level))
          end
        end
      end
    end
    if fingers[k][i].con == "3" then
      if k == 4 then
        local bpm_to_sixteenth = (60/bpm)/4
        if grid.alt == 0 then
          bank[i][which_pad].start_point = (1+((8/16)*(which_pad-1)))+(8*(bank[i][which_pad].clip-1))
          bank[i][which_pad].end_point = bank[i][which_pad].start_point + bpm_to_sixteenth
        else
          for j= 1,16 do
            bank[i][j].start_point = (1+((8/16)*(j-1)))+(8*(bank[i][j].clip-1))
            bank[i][j].end_point = bank[i][j].start_point + bpm_to_sixteenth
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.loop_start(i+1,bank[i][which_pad].start_point)
          softcut.loop_end(i+1,bank[i][which_pad].end_point)
        end
      elseif k == 3 then
        if grid.alt == 0 then
          bank[i][which_pad].pan = 1
        else
          for j = 1,16 do
            bank[i][j].pan = 1
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.pan(i+1,1)
        end
      end
    end
    if fingers[k][i].con == "4" then
      if grid.alt == 0 then
        bank[i][which_pad].end_point = (8*bank[i][which_pad].clip)+1
      else
        for j = 1,16 do
          bank[i][j].end_point = (8*bank[i][j].clip)+1
        end
      end
      if bank[i].focus_hold == 0 then
        softcut.loop_end(i+1,bank[i][which_pad].end_point)
      end
    end
    if fingers[k][i].con == "12" then
      if k == 4 then
        if grid.alt == 0 then
          local current_end = math.floor(bank[i][which_pad].end_point * 100)
          local min_start = math.floor(((8*(bank[i][which_pad].clip-1))+1) * 100)
          bank[i][which_pad].start_point = math.random(min_start,current_end)/100
        else
          for j = 1,16 do
            local current_end = math.floor(bank[i][j].end_point*100)
            local min_start = math.floor(((8*(bank[i][j].clip-1))+1) * 100)
            bank[i][j].start_point = math.random(min_start,current_end)/100
          end
        end
        if bank[i][which_pad].loop == true and bank[i][which_pad].enveloped == false then
          if bank[i].focus_hold == 0 then
            cheat(i,which_pad)
          end
        end
      elseif k == 3 then
        if grid.alt == 0 then
          if bank[i][which_pad].pan >= -0.9 then
            bank[i][which_pad].pan = bank[i][which_pad].pan - 0.1
          end
        else
          for j = 1,16 do
            if bank[i][j].pan >= -0.9 then
              bank[i][j].pan = bank[i][j].pan - 0.1
            end
          end
        end
        if bank[i].focus_hold == 0 then
          softcut.pan(i+1,bank[i][which_pad].pan)
        end
      elseif k == 2 then
        if bank[i][which_pad].pause == false then
          if grid.alt == 0 then
            bank[i][which_pad].pause = true
          else
            for j = 1,16 do
              bank[i][j].pause = true
            end
          end
          if bank[i].focus_hold == 0 then
            softcut.level(i+1,0.0)
            softcut.rate(i+1,0.0)
          end
        else
          if grid.alt == 0 then
            bank[i][which_pad].pause = false
          else
            for j = 1,16 do
              bank[i][j].pause = false
            end
          end
          if bank[i].focus_hold == 0 then
            if not bank[i][which_pad].enveloped then
              softcut.level(i+1,bank[i][which_pad].level)
            else
              cheat(i,which_pad)
            end
            softcut.rate(i+1,bank[i][which_pad].rate*bank[i][which_pad].offset)
          end
        end
      end
    end
    if fingers[k][i].con == "23" then
      if k == 4 then
        if grid.alt == 0 then
          local jump = math.random(100,900)/100+(8*(bank[i][which_pad].clip-1))
          local current_difference = (bank[i][which_pad].end_point - bank[i][which_pad].start_point)
          if jump+current_difference >= 9+(8*(bank[i][which_pad].clip-1)) then
            bank[i][which_pad].end_point = 9+(8*(bank[i][which_pad].clip-1))
            bank[i][which_pad].start_point = bank[i][which_pad].end_point - current_difference
          else
            bank[i][which_pad].start_point = jump
            bank[i][which_pad].end_point = bank[i][which_pad].start_point + current_difference
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
          if bank[i][which_pad].pan <= 0.9 then
            bank[i][which_pad].pan = bank[i][which_pad].pan + 0.1
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
          local current_start = math.floor(bank[i][which_pad].start_point * 100)
          local max_end = math.floor(((8*bank[i][which_pad].clip)+1) * 100)
          bank[i][which_pad].end_point = math.random(current_start,max_end)/100
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
          local double = (bank[i][which_pad].end_point - bank[i][which_pad].start_point)*2
          local maximum_val = 9+(8*(bank[i][which_pad].clip-1))
          local minimum_val = 1+(8*(bank[i][which_pad].clip-1))
          if bank[i][which_pad].start_point - double >= minimum_val then
            bank[i][which_pad].start_point = bank[i][which_pad].end_point - double
            --softcut.loop_start(i+1,bank[i][which_pad].start_point)
          elseif bank[i][which_pad].start_point - double < minimum_val then
            if bank[i][which_pad].end_point + double < maximum_val then
              bank[i][which_pad].end_point = bank[i][which_pad].end_point + double
              --softcut.loop_end(i+1,bank[i][which_pad].end_point)
            end
          end
        else
          for j = 1,16 do
            local double = (bank[i][j].end_point - bank[i][j].start_point)*2
            local maximum_val = 9+(8*(bank[i][j].clip-1))
            local minimum_val = 1+(8*(bank[i][j].clip-1))
            if bank[i][j].start_point - double >= minimum_val then
              bank[i][j].start_point = bank[i][j].end_point - double
              --softcut.loop_start(i+1,bank[i][j].start_point)
            elseif bank[i][j].start_point - double < minimum_val then
              if bank[i][j].end_point + double < maximum_val then
                bank[i][j].end_point = bank[i][j].end_point + double
                --softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
              end
            end
          end
        end
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      elseif k == 3 then
        if grid.alt == 0 then
          bank[i][which_pad].pan = bank[i][which_pad].pan * -1
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
        local halve = ((bank[i][which_pad].end_point - bank[i][which_pad].start_point)/2)/2
        bank[i][which_pad].start_point = bank[i][which_pad].start_point + halve
        bank[i][which_pad].end_point = bank[i][which_pad].end_point - halve
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      end
    end
    if fingers[k][i].con == "14" then
      if grid.alt == 0 then
        bank[i][which_pad].rate = bank[i][which_pad].rate*-1
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
        if math.abs(bank[i][which_pad].rate) < 4 then
          bank[i][which_pad].rate = bank[i][which_pad].rate*2
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
        if math.abs(bank[i][which_pad].rate) > 0.125 then
          bank[i][which_pad].rate = bank[i][which_pad].rate/2
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
          bank[i][which_pad].start_point = bank[2][bank[2].id].start_point - (8*(bank[2][bank[2].id].clip-1))
          bank[i][which_pad].end_point = bank[2][bank[2].id].end_point - (8*(bank[2][bank[2].id].clip-1))
        elseif i == 2 or 3 then
          bank[i][which_pad].start_point = bank[1][bank[1].id].start_point + (8*(bank[i][which_pad].clip-1))
          bank[i][which_pad].end_point = bank[1][bank[1].id].end_point + (8*(bank[i][which_pad].clip-1))
        end
        if bank[i].focus_hold == 0 then
          softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
          softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
          softcut.position(i+1,bank[i][bank[i].id].start_point)
        end
        -- LEFT OFF HERE
      elseif k == 3 then
        if grid.alt == 0 then
          bank[i][which_pad].pan = math.random(-100,100)/100
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
          bank[i][which_pad].start_point = (bank[3][bank[3].id].start_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(bank[i][which_pad].clip-1))
          bank[i][which_pad].end_point = (bank[3][bank[3].id].end_point - (8*(bank[3][bank[3].id].clip-1))) + (8*(bank[i][which_pad].clip-1))
        end
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
        softcut.position(i+1,bank[i][bank[i].id].start_point)
      end
    end
    if fingers[k][i].con == "1234" then
      if grid.alt == 0 then
        if math.abs(bank[i][which_pad].rate) < 4 then
          if bank[i][which_pad].fifth == false then
            bank[i][which_pad].rate = bank[i][which_pad].rate*1.5
            bank[i][which_pad].fifth = true
          else
            bank[i][which_pad].rate = bank[i][which_pad].rate < 0 and math.ceil(math.abs(bank[i][which_pad].rate)) * -1 or bank[i][which_pad].rate > 0 and math.ceil(math.abs(bank[i][which_pad].rate))
            bank[i][which_pad].fifth = false
            if math.abs(bank[i][which_pad].rate) == 3 then
              bank[i][which_pad].rate = bank[i][which_pad].rate == 3 and 4 or bank[i][which_pad].rate == -3 and -4
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