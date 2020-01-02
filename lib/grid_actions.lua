grid_actions = {}

function grid_actions.init(x,y,z)
  for i = 1,3 do
    if z == 1 and x > 0 + (5*(i-1)) and x <= 4 + (5*(i-1)) and y >=5 then
      if grid.alt == 0 then
        selected[i].x = x
        selected[i].y = y
        selected[i].id = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
        bank[i].id = selected[i].id
        which_bank = i
        if menu == 7 then
          help_menu = "banks"
        end
        clipboard = {}
        if quantize == 0 then
          cheat(i, bank[i].id)
          grid_p[i] = {}
          grid_p[i].action = "pads"
          grid_p[i].i = i
          grid_p[i].id = selected[i].id
          grid_p[i].x = selected[i].x
          grid_p[i].y = selected[i].y
          grid_p[i].rate = bank[i][bank[i].id].rate
          grid_p[i].start_point = bank[i][bank[i].id].start_point
          grid_p[i].end_point = bank[i][bank[i].id].end_point
          grid_p[i].rate_adjusted = false
          grid_p[i].loop = bank[i][bank[i].id].loop
          grid_p[i].pause = bank[i][bank[i].id].pause
          grid_p[i].mode = bank[i][bank[i].id].mode
          grid_p[i].clip = bank[i][bank[i].id].clip
          grid_pat[i]:watch(grid_p[i])
        else
          table.insert(quantize_events[i],selected[i].id)
        end
      else
        if #clipboard == 0 then
          selected[i].x = x
          selected[i].y = y
          selected[i].id = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
          bank[i].id = selected[i].id
          clipboard[i] = {}
          clipboard_copy(
            bank[i][bank[i].id].start_point,
            bank[i][bank[i].id].end_point,
            bank[i][bank[i].id].rate,
            bank[i][bank[i].id].level,
            bank[i][bank[i].id].pan,
            bank[i][bank[i].id].clip,
            bank[i][bank[i].id].mode,
            bank[i][bank[i].id].loop,
            bank[i][bank[i].id].filter_type,
            bank[i][bank[i].id].fc,
            bank[i][bank[i].id].q,
            bank[i][bank[i].id].fifth,
            bank[i][bank[i].id].enveloped,
            bank[i][bank[i].id].envelope_time
            )
        else
          selected[i].x = x
          selected[i].y = y
          selected[i].id = (math.abs(y-9)+((x-1)*4))-(20*(i-1))
          bank[i].id = selected[i].id
          clipboard_paste(i)
          clipboard = {}
        end
      end
      redraw()
    elseif z == 0 and x > 0 + (5*(i-1)) and x <= 4 + (5*(i-1)) and y >=5 then
      if bank[i][bank[i].id].play_mode == "momentary" then
        softcut.rate(i+1,0)
      end
    end
  end
  
  for k = 4,2,-1 do
    for i = 1,3 do
      if z == 1 and x == (k+1)+(5*(i-1)) and y <=k then
        local t1 = util.time()
        fingers[k].dt = t1-fingers[k].t
        fingers[k].t = t1
        if fingers[k].dt > 0.1 then
          fingers[k][i] = {}
        end
        table.insert(fingers[k][i],math.abs(y-(k+1)))
        table.sort(fingers[k][i])
        fingers[k][i].con = table.concat(fingers[k][i])
        for j = 1,#fingers[k][i] do
          local e = {}
          e.state = 1
          e.id = (k+1)+(5*(i-1))+math.abs(fingers[k][i][j]-(k+1))
          e.x = (k+1)+(5*(i-1))
          e.y = math.abs(fingers[k][i][j]-(k+1))
          grid_entry(e)
        end
      elseif z == 0 and x == (k+1)+(5*(i-1)) and y<=k then
        if k == 4 then
          counter_four[i].key_up:stop()
          counter_four[i].key_up:start()
        elseif k == 3 then
          counter_three[i].key_up:stop()
          counter_three[i].key_up:start()
        elseif k == 2 then
          counter_two[i].key_up:stop()
          counter_two[i].key_up:start()
        elseif k == 1 then
          zilchmo(1,i)
        end
      end
    end
  end
  
  for k = 1,1 do
    for i = 1,3 do
      if z == 0 and x == (k+1)+(5*(i-1)) and y<=k then
        if grid_pat_quantize == 0 then
          if grid.alt == 1 then
            grid_pat[i]:rec_stop()
            grid_pat[i]:stop()
            grid_pat[i]:clear()
          elseif grid_pat[i].rec == 1 then
            grid_pat[i]:rec_stop()
            grid_pat[i]:start()
          elseif grid_pat[i].count == 0 then
            grid_pat[i]:rec_start()
          elseif grid_pat[i].play == 1 then
            grid_pat[i]:stop()
          else
            grid_pat[i]:start()
          end
        else
          if grid.alt == 1 then
            grid_pat[i]:rec_stop()
            grid_pat[i]:stop()
            grid_pat[i]:clear()
          else
            table.insert(grid_pat_quantize_events[i],i)
          end
        end
        if menu == 7 then
          help_menu = "grid patterns"
          which_bank = i
        end
      end
    end
  end
  
  for i = 4,1,-1 do
    if x == 16 and y == i and z == 0 then
      local current = math.abs(y-5)
      if grid.alt == 1 then
        arc_pat[current]:rec_stop()
        arc_pat[current]:stop()
        arc_pat[current]:clear()
      elseif arc_pat[current].rec == 1 then
        arc_pat[current]:rec_stop()
        arc_pat[current]:start()
      elseif arc_pat[current].count == 0 then
        arc_pat[current]:rec_start()
      elseif arc_pat[current].play == 1 then
        arc_pat[current]:stop()
      else
        arc_pat[current]:start()
      end
      if menu == 7 then
        help_menu = "arc patterns"
        which_bank = current
      end
    end
  end
  
  for i = 1,3 do
    if x == (3)+(5*(i-1)) and y == 4 and z == 1 then
      which_bank = i
      if bank[i][bank[i].id].loop == true then
        if grid.alt == 0 then
          bank[i][bank[i].id].loop = false
        else
          for j = 1,16 do
            bank[i][j].loop = false
          end
        end
        softcut.loop(i+1,0)
      else
        if grid.alt == 0 then
          bank[i][bank[i].id].loop = true
        else
          for j = 1,16 do
            bank[i][j].loop = true
          end
        end
        softcut.loop(i+1,1)
      end
      if menu == 7 then
        help_menu = "loop"
      end
    end
    redraw()
  end
  
  if x == 16 and y == 8 then
    grid.alt = z
    if menu == 7 then
      if grid.alt == 1 then
        help_menu = "alt"
      else
        help_menu = "welcome"
      end
    end
    redraw()
    grid_redraw()
  end
  
  if y == 4 or y == 3 or y == 2 then
    if x == 1 or x == 6 or x == 11 then
      local current = math.sqrt(math.abs(x-2))
      if grid.alt == 0 then
        clip_jump(current, bank[current].id, y, z)
      else
        for j = 1,16 do
          clip_jump(current, j, y, z)
        end
      end
      if z == 0 then
        redraw()
        cheat(current,bank[current].id)
      end
    end
  end
  
  for i = 4,3,-1 do
    for j = 2,12,5 do
      if x == j and y == i and z == 1 then
        if grid.alt == 0 then
          local current = math.sqrt(math.abs(x-3))
          bank[current][bank[current].id].mode = math.abs(i-5)
        else
          for k = 1,16 do
            local current = math.sqrt(math.abs(x-3))
            bank[current][k].mode = math.abs(i-5)
          end
        end
        local current = math.sqrt(math.abs(x-3))
        if bank[current][bank[current].id].mode == 1 then
          bank[current][bank[current].id].sample_end = 8
        else
          bank[current][bank[current].id].sample_end = clip[bank[current][bank[current].id].clip].sample_length
        end
        local current = math.sqrt(math.abs(x-3))
        cheat(current,bank[current].id)
        if menu == 7 then
          which_bank = current
          help_menu = "mode"
        end
      end
    end
  end
  
  for i = 7,5,-1 do
    if x == 16 and z == 1 and y == i then
      --softcut.position(1,1+(8*(7-y)))
      --softcut.fade_time(1,0.1)
      --softcut.recpre_slew_time(1,0.1)
      softcut.level_slew_time(1,0.5)
      softcut.fade_time(1,0)
      softcut.loop_start(1,rec.start_point)
      softcut.loop_end(1,rec.end_point)
      rec.clip = 8-y
      if grid.alt == 1 then
        freeze()
      end
      if menu == 7 then
        help_menu = "buffer switch"
      end
    end
  end
  
  for i = 8,5,-1 do
    if z == 1 then
      if x == 5 or x == 10 or x == 15 then
        if y == i then
          if grid.alt == 0 then
            arc_param[x/5] = 9-y
            if menu == 7 then
              which_bank = x/5
              help_menu = "arc params"
            end
            redraw()
          end
        end
      end
    end
  end
  
  --- new page focus
  for k = 4,1,-1 do
    for i = 1,3 do
      if z == 1 and x == k+(5*(i-1)) and y == k then
        menu = 6-y
        if menu == 2 then
          page.loops_sel = math.floor((x/4)-1)
        elseif menu == 5 then
          page.filtering_sel = math.floor((x/4))
        end
        redraw()
      end
    end
  end
end

return grid_actions