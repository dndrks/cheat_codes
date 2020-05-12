local encoder_actions = {}

local ea = encoder_actions
ea.sc = {}

function encoder_actions.init(n,d)
  if n == 1 then
    if menu == 2 then
      local id = page.loops_sel + 1
      if id ~= 4 then
        if key1_hold or grid.alt == 1 then
          ea.change_pad(id,d)
        else
          local which_pad = nil
          if bank[id].focus_hold == false then
            which_pad = bank[id].id
          else
            which_pad = bank[id].focus_pad
          end
          ea.move_play_window(bank[id][which_pad],d/loop_enc_resolution)
        end
        if bank[id].focus_hold == false then
          ea.sc.move_play_window(id)
        end
      elseif id == 4 then
        if key1_hold or grid.alt == 1 then
          ea.change_buffer(rec,d)
        else
          ea.move_rec_window(rec,d)
        end
          ea.sc.move_rec_window(rec)
      end
    elseif menu == 6 then
      page.delay_sel = util.clamp(page.delay_sel+d,0,4)
    elseif menu == 7 then
      page.time_sel = util.clamp(page.time_sel+d,1,3)
    elseif menu == 8 then
      if page.track_page_section[page.track_page] == 1 then
        page.track_page = util.clamp(page.track_page+d,1,4)
      elseif page.track_page_section[page.track_page] == 2 then
        if page.track_page < 4 then
          local reasonable_max = nil
          for i = 1,tracker[page.track_page].max_memory do
            if tracker[page.track_page][i].pad ~= nil then
              reasonable_max = i
            end
          end
          if reasonable_max ~= nil then
            page.track_sel[page.track_page] = util.clamp(page.track_sel[page.track_page]+d,1,reasonable_max+1)
          end
        end
      end
    end
  end
  if n == 2 then
    if menu == 1 then
      page.main_sel = util.clamp(page.main_sel+d,1,8)
    elseif menu == 2 then
      local id = page.loops_sel + 1
      if id ~=4 then
        if key1_hold and grid.alt == 0 then
          ea.change_pad_clip(id,d)
        elseif key1_hold == false and grid.alt == 0 then
          local which_pad = nil
          if bank[id].focus_hold == false then
            which_pad = bank[id].id
          else
            which_pad = bank[id].focus_pad
          end
          ea.move_start(bank[id][which_pad],d/loop_enc_resolution)
          if bank[id].focus_hold == false then
            ea.sc.move_start(id)
          end
        end
      elseif id == 4 then
        if key1_hold or grid.alt == 1 then
          local preadjust = rec.state
          rec.state = util.clamp(rec.state+d,0,1)
          if preadjust ~= rec.state then
            softcut.recpre_slew_time(1,0.5)
            softcut.level_slew_time(1,0.5)
            softcut.fade_time(1,0.01)
            softcut.rec_level(1,rec.state)
            if rec.state == 1 then
              softcut.pre_level(1,params:get("live_rec_feedback"))
            else
              softcut.pre_level(1,1)
            end
          end
        else
          local lbr = {1,2,4}
          --if d >= 0 and rec.start_point + ((d/rec_loop_enc_resolution)/params:get("live_buff_rate")) < (rec.end_point - ((d/rec_loop_enc_resolution)/params:get("live_buff_rate"))) then
          if d >= 0 and rec.start_point + ((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]) < rec.end_point then
            rec.start_point = util.clamp(rec.start_point+((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]),(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
          elseif d < 0 then
            rec.start_point = util.clamp(rec.start_point+((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]),(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
          end
          softcut.loop_start(1, rec.start_point)
        end
      end
    elseif menu == 6 then
      local line = page.delay_sel
      if line == 0 then
        params:delta("delay L: rate",d)
      elseif line == 1 then
        params:delta("delay L: feedback",d)
      elseif line ==  2 then
        params:delta("delay L: filter cut",d/10)
      elseif line == 3 then
        params:delta("delay L: filter q",d/2)
      elseif line == 4 then
        params:delta("delay L: global level",d)
      end
    elseif menu == 7 then
      local time_page = page.time_page_sel
      local page_line = page.time_sel
      if page_line >= 1 and page_line < 4 and bank[page_line].crow_execute ~= 1 then
        time_page[page_line] = util.clamp(time_page[page_line]+d,1,7)
        if time_page[page_line] > 4 then
          page.time_scroll[page_line] = 2
        else
          page.time_scroll[page_line] = 1
        end
      else
        time_page[page_line] = util.clamp(time_page[page_line]+d,1,7)
        if time_page[page_line] < 4 then
          page.time_scroll[page_line] = 1
        elseif time_page[page_line] == 4 and bank[page_line].crow_execute == 1 then
          if page.time_scroll[page_line] == 1 then
            time_page[page_line] = 5
            page.time_scroll[page_line] = 2
          else
            time_page[page_line] = 3
            page.time_scroll[page_line] = 1
          end
        elseif time_page[page_line] > 4 and bank[page_line].crow_execute == 1 then
          page.time_scroll[page_line] = 2
        end
      end
    elseif menu == 8 then
      if page.track_page_section[page.track_page] == 1 then
        --TODO
      else
        if page.track_page > 4 then
          if tracker[page.track_page][page.track_sel[page.track_page]].pad == nil then
            tracker[page.track_page][page.track_sel[page.track_page]].pad = 0
            tracker[page.track_page][page.track_sel[page.track_page]].time = 0.25
            if page.track_sel[page.track_page] > tracker[page.track_page].end_point then
              tracker[page.track_page].end_point = page.track_sel[page.track_page]
            end
          end
          tracker[page.track_page][page.track_sel[page.track_page]].pad = util.clamp(tracker[page.track_page][page.track_sel[page.track_page]].pad+d,1,16)
        else
          tracker[1].snake = util.clamp(tracker[1].snake+d,1,8)
        end
      end
    end
  end
  if n == 3 then
    if menu == 2 then
      local id = page.loops_sel + 1
      if id ~= 4 then
        if key1_hold or grid.alt == 1 then
          local focused_pad = nil
          if grid_pat[id].play == 0 and grid_pat[id].tightened_start == 0 then
            focused_pad = bank[id].id
          else
            focused_pad = bank[id].focus_pad
          end
          local current_offset = (math.log(bank[id][focused_pad].offset)/math.log(0.5))*-12
          current_offset = util.clamp(current_offset+d,-36,24)
          if current_offset > -1 and current_offset < 1 then
            current_offset = 0
          end
          bank[id][focused_pad].offset = math.pow(0.5, -current_offset / 12)
          if grid_pat[id].play == 0 and grid_pat[id].tightened_start == 0 then
            cheat(id,bank[id].id)
          end
          if focused_pad == 16 then
            for i = 1,15 do
              bank[id][i].offset = bank[id][16].offset
            end
          end
          if grid.alt == 1 then
            for i = 1,16 do
              bank[id][i].offset = bank[id][focused_pad].offset
            end
          end
        else
          local which_pad = nil
          if bank[id].focus_hold == false then
            which_pad = bank[id].id
          else
            which_pad = bank[id].focus_pad
          end
          if d <= 0 and bank[id][which_pad].start_point < bank[id][which_pad].end_point + d/loop_enc_resolution then
            bank[id][which_pad].end_point = util.clamp(bank[id][which_pad].end_point+d/loop_enc_resolution,(1+(8*(bank[id][which_pad].clip-1))),(9+(8*(bank[id][which_pad].clip-1))))
          elseif d > 0 then
            bank[id][which_pad].end_point = util.clamp(bank[id][which_pad].end_point+d/loop_enc_resolution,(1+(8*(bank[id][which_pad].clip-1))),(9+(8*(bank[id][which_pad].clip-1))))
          end
          if bank[id].focus_hold == false then
            softcut.loop_end(id+1, bank[id][bank[id].id].end_point)
          end
        end
      elseif id == 4 then
        if key1_hold or grid.alt == 1 then
          params:delta("live_buff_rate",d)
        else
          local lbr = {1,2,4}
          if d <= 0 and rec.start_point < rec.end_point + ((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]) then
            rec.end_point = util.clamp(rec.end_point+((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]),(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
          elseif d > 0 and rec.end_point+((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]) < 9+(8*(rec.clip-1)) then
            rec.end_point = util.clamp(rec.end_point+((d/rec_loop_enc_resolution)/lbr[params:get("live_buff_rate")]),(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
          end
          softcut.loop_end(1, rec.end_point-0.01)
        end
      end
    elseif menu == 6 then
      local line = page.delay_sel
      if line == 0 then
        params:delta("delay R: rate",d)
      elseif line == 1 then
        params:delta("delay R: feedback",d)
      elseif line ==  2 then
        params:delta("delay R: filter cut",d/10)
      elseif line == 3 then
        params:delta("delay R: filter q",d/2)
      elseif line == 4 then
        params:delta("delay R: global level",d)
      end
    elseif menu == 7 then
      local time_page = page.time_page_sel
      local page_line = page.time_sel
      local pattern = grid_pat[page_line]
      if page_line <= 4 then
        if time_page[page_line] == 3 then
          bank[page_line].crow_execute = util.clamp(bank[page_line].crow_execute+d,0,1)
        elseif time_page[page_line] == 1 then
          if pattern.rec ~= 1 then
            pattern.playmode = util.clamp(pattern.playmode+d,1,4)
            set_pattern_mode(page_line)
          end
        elseif time_page[page_line] == 4 and bank[page_line].crow_execute ~= 1 then
          crow.count_execute[page_line] = util.clamp(crow.count_execute[page_line]+d,1,16)
        elseif time_page[page_line] == 5 then
          pattern.random_pitch_range = util.clamp(pattern.random_pitch_range+d,1,4)
        elseif time_page[page_line] == 6 then
          if pattern.rec ~= 1 and pattern.count > 0 then
            pattern.start_point = util.clamp(pattern.start_point+d,1,pattern.end_point)
            if quantized_grid_pat[page_line].current_step < pattern.start_point then
              quantized_grid_pat[page_line].current_step = pattern.start_point
              quantized_grid_pat[page_line].sub_step = 1
            end
          end
        elseif time_page[page_line] == 7 then
          if pattern.rec ~= 1 and pattern.count > 0 then
            pattern.end_point = util.clamp(pattern.end_point+d,pattern.start_point,pattern.count)
            if quantized_grid_pat[page_line].current_step > pattern.end_point then
              quantized_grid_pat[page_line].current_step = pattern.start_point
              quantized_grid_pat[page_line].sub_step = 1
            end
          end
        end
      end
    elseif menu == 8 then
      if tracker[page.track_page][page.track_sel[page.track_page]].pad ~= nil then
        deci_to_int =
        { ["0.1667"] = 1 --1/16T
        , ["0.25"] = 2 -- 1/16
        , ["0.3333"] = 3 -- 1/8T
        , ["0.5"] = 4 -- 1/8
        , ["0.6667"] = 5 -- 1/4T
        , ["1.0"] = 6 -- 1/4
        , ["1.3333"] = 7 -- 1/2T
        , ["2.0"] = 8 -- 1/2
        , ["2.6667"] = 9  -- 1T
        , ["4.0"] = 10 -- 1
        }
        local rounded = util.round(tracker[page.track_page][page.track_sel[page.track_page]].time,0.0001)
        local working = deci_to_int[tostring(rounded)]
        working = util.clamp(working+d,1,10)
        local int_to_deci = {1/6,0.25,1/3,0.5,2/3,1,4/3,2,8/3,4}
        tracker[page.track_page][page.track_sel[page.track_page]].time = int_to_deci[working]
      end
    end
  end
  if menu == 3 then
    local focused_pad = nil
    if bank[n].focus_hold == true then
      focused_pad = bank[n].focus_pad
    else
      focused_pad = bank[n].id
    end
    if page.levels_sel == 0 then
      if key1_hold or grid.alt == 1 then
        for i = 1,16 do
          bank[n][i].level = util.clamp(bank[n][i].level+d/10,0,2)
        end
      else
        bank[n][focused_pad].level = util.clamp(bank[n][focused_pad].level+d/10,0,2)
      end
      if bank[n][bank[n].id].enveloped == false then
        if bank[n].focus_hold == false then
          softcut.level_slew_time(n+1,1.0)
          softcut.level(n+1,bank[n][bank[n].id].level)
          softcut.level_cut_cut(n+1,5,util.linlin(-1,1,0,1,bank[n][bank[n].id].pan)*(bank[n][bank[n].id].left_delay_level*bank[n][bank[n].id].level))
          softcut.level_cut_cut(n+1,6,util.linlin(-1,1,1,0,bank[n][bank[n].id].pan)*(bank[n][bank[n].id].right_delay_level*bank[n][bank[n].id].level))
        end
      end
    elseif page.levels_sel == 1 then
      if key1_hold or grid.alt == 1 then
        for j = 1,16 do
          local pre_enveloped = bank[n][j].enveloped
          if bank[n][j].enveloped then
            if d < 0 then
              bank[n][j].enveloped = false
              if pre_enveloped ~= bank[n][j].enveloped then
                cheat(n, bank[n].id)
              end
            end
          else
            if d > 0 then
              bank[n][j].enveloped = true
              if pre_enveloped ~= bank[n][j].enveloped then
                cheat(n, bank[n].id)
              end
            end
          end
        end
      else
        local pre_enveloped = bank[n][focused_pad].enveloped
        if bank[n][focused_pad].enveloped then
          if d < 0 then
            bank[n][focused_pad].enveloped = false
            if pre_enveloped ~= bank[n][bank[n].id].enveloped then
              if bank[n].focus_hold == false then
                cheat(n, bank[n].id)
              end
            end
          end
        else
          if d > 0 then
            bank[n][focused_pad].enveloped = true
            if pre_enveloped ~= bank[n][focused_pad].enveloped then
              if bank[n].focus_hold == false then
                cheat(n, bank[n].id)
              end
            end
          end
        end
      end
    elseif page.levels_sel == 2 then
      if key1_hold or grid.alt == 1 then
        for j = 1,16 do
          if bank[n][j].enveloped then
            bank[n][j].envelope_time = util.explin(0.1,60,0.1,60,bank[n][j].envelope_time)
            bank[n][j].envelope_time = util.clamp(bank[n][j].envelope_time+d/10,0.1,60)
            bank[n][j].envelope_time = util.linexp(0.1,60,0.1,60,bank[n][j].envelope_time)
          end
        end
      else
        if bank[n][focused_pad].enveloped then
          bank[n][focused_pad].envelope_time = util.explin(0.1,60,0.1,60,bank[n][focused_pad].envelope_time)
          bank[n][focused_pad].envelope_time = util.clamp(bank[n][focused_pad].envelope_time+d/10,0.1,60)
          bank[n][focused_pad].envelope_time = util.linexp(0.1,60,0.1,60,bank[n][focused_pad].envelope_time)
        end
      end
    end
  end
  if menu == 4 then
    local focused_pad = nil
    if key1_hold or grid.alt == 1 then
      for i = 1,16 do
        bank[n][i].pan = util.clamp(bank[n][i].pan+d/10,-1,1)
      end
    else
      if bank[n].focus_hold == true then
        focused_pad = bank[n].focus_pad
      else
        focused_pad = bank[n].id
      end
      bank[n][focused_pad].pan = util.clamp(bank[n][focused_pad].pan+d/10,-1,1)
    end
    softcut.pan(n+1, bank[n][bank[n].id].pan)
  elseif menu == 5 then
    local filt_page = page.filtering_sel + 1
    if filt_page == 1 then
      if bank[n][bank[n].id].filter_type == 4 then
        if key1_hold or grid.alt == 1 then
          if slew_counter[n] ~= nil then
            slew_counter[n].prev_tilt = bank[n][bank[n].id].tilt
          end
          bank[n][bank[n].id].tilt = util.clamp(bank[n][bank[n].id].tilt+(d/100),-1,1)
          if d < 0 then
            if util.round(bank[n][bank[n].id].tilt*100) < 0 and util.round(bank[n][bank[n].id].tilt*100) > -9 then
              bank[n][bank[n].id].tilt = -0.10
            elseif util.round(bank[n][bank[n].id].tilt*100) > 0 and util.round(bank[n][bank[n].id].tilt*100) < 32 then
              bank[n][bank[n].id].tilt = 0.0
            end
          elseif d > 0 and util.round(bank[n][bank[n].id].tilt*100) > 0 and util.round(bank[n][bank[n].id].tilt*100) < 32 then
            bank[n][bank[n].id].tilt = 0.32
          end
          slew_filter(n,slew_counter[n].prev_tilt,bank[n][bank[n].id].tilt,bank[n][bank[n].id].q,bank[n][bank[n].id].q,15)
        else
          if slew_counter[n] ~= nil then
            slew_counter[n].prev_tilt = bank[n][bank[n].id].tilt
          end
          for j = 1,16 do
            bank[n][j].tilt = util.clamp(bank[n][j].tilt+(d/100),-1,1)
            if d < 0 then
              if util.round(bank[n][j].tilt*100) < 0 and util.round(bank[n][j].tilt*100) > -9 then
                bank[n][j].tilt = -0.10
              elseif util.round(bank[n][j].tilt*100) > 0 and util.round(bank[n][j].tilt*100) < 32 then
                bank[n][j].tilt = 0.0
              end
            elseif d > 0 and util.round(bank[n][j].tilt*100) > 0 and util.round(bank[n][j].tilt*100) < 32 then
              bank[n][j].tilt = 0.32
            end
          end
          slew_filter(n,slew_counter[n].prev_tilt,bank[n][bank[n].id].tilt,bank[n][bank[n].id].q,bank[n][bank[n].id].q,15)
        end
      end
    elseif filt_page == 2 then
      if key1_hold or grid.alt == 1 then
        bank[n][bank[n].id].tilt_ease_time = util.clamp(bank[n][bank[n].id].tilt_ease_time+(d/1), 5, 15000)
      else
        for j = 1,16 do
          bank[n][j].tilt_ease_time = util.clamp(bank[n][j].tilt_ease_time+(d/1), 5, 15000)
        end
      end
    elseif filt_page == 3 then
      if key1_hold or grid.alt == 1 then
        bank[n][bank[n].id].tilt_ease_type = util.clamp(bank[n][bank[n].id].tilt_ease_type+d, 1, 2)
      else
        for j = 1,16 do
          bank[n][j].tilt_ease_type = util.clamp(bank[n][j].tilt_ease_type+d, 1, 2)
        end
      end
    end
  end
  redraw()
end

function ea.move_play_window(target,delta)
  local current_difference = (target.end_point - target.start_point)
  local current_clip = 8*(target.clip-1)
  if target.start_point + current_difference <= 9+current_clip then
    target.start_point = util.clamp(target.start_point + delta, 1+current_clip, 9+current_clip)
    target.end_point = target.start_point + current_difference
  else
    target.end_point = (9+current_clip)
    target.start_point = target.end_point - current_difference
  end
end

function ea.move_rec_window(target,delta)
  local current_difference = (target.end_point - target.start_point)
  local current_clip = 8*(target.clip-1)
  if delta >=0 then
    if target.end_point + current_difference < (9+(8*current_clip)) then
      target.start_point = util.clamp(target.start_point + current_difference * (delta>0 and 1 or -1), (1+(8*current_clip)),(9+(8*current_clip)))
      target.end_point = target.start_point + current_difference
    end
  else
    if target.end_point - current_difference > (1+(8*current_clip)) then
      target.end_point = util.clamp(target.end_point + current_difference * (delta>0 and 1 or -1), (1+(8*current_clip)),(9+(8*current_clip)))
      target.start_point = target.end_point - current_difference
    end
  end
end

function ea.change_pad(target,delta)
  pad = bank[target]
  if grid_pat[target].play == 0 and grid_pat[target].tightened_start == 0 then
    pad.id = util.clamp(pad.id + delta,1,16)
    selected[target].x = (math.ceil(pad.id/4)+(5*(target-1)))
    selected[target].y = 8-((pad.id-1)%4)
    cheat(target,pad.id)
  else
    pad.focus_pad = util.clamp(pad.focus_pad + delta,1,16)
  end
end

function ea.change_buffer(target,delta)
  local pre_adjust = target.clip
  local current_difference = (target.end_point - target.start_point)
  target.clip = util.clamp(target.clip+delta,1,3)
  target.start_point = target.start_point - ((pre_adjust - target.clip)*8)
  target.end_point = target.start_point + current_difference
end

function ea.change_pad_clip(target,delta)
  local focused_pad = nil
  if grid_pat[target].play == 0 and grid_pat[target].tightened_start == 0 then
    focused_pad = bank[target].id
  else
    focused_pad = bank[target].focus_pad
  end
  pad = bank[target][focused_pad]
  local pre_adjust = pad.clip
  local current_difference = (pad.end_point - pad.start_point)
  if pad.mode == 1 and pad.clip + delta > 3 then
    pad.mode = 2
    pad.clip = 1
  elseif pad.mode == 2 and pad.clip + delta < 1 then
    pad.mode = 1
    pad.clip = 3
  else
    pad.clip = util.clamp(pad.clip+delta,1,3)
  end
  pad.start_point = pad.start_point - ((pre_adjust - pad.clip)*8)
  pad.end_point = pad.start_point + current_difference
  if grid_pat[target].play == 0 and grid_pat[target].tightened_start == 0 then
    cheat(target,bank[target].id)
  end
  if focused_pad == 16 then
    for i = 1,15 do
      local pre_adjust = bank[target][i].clip
      bank[target][i].mode = bank[target][16].mode
      bank[target][i].clip = bank[target][16].clip
      local current_difference = (bank[target][i].end_point - bank[target][i].start_point)
      bank[target][i].start_point = bank[target][i].start_point - ((pre_adjust - bank[target][i].clip)*8)
      bank[target][i].end_point = bank[target][i].start_point + current_difference
    end
  end
end

function ea.move_start(target,delta)
  if delta >= 0 and target.start_point < (target.end_point - delta) then
    target.start_point = util.clamp(target.start_point+delta,(1+(8*(target.clip-1))),(8.9+(8*(target.clip-1))))
  elseif d < 0 then
    target.start_point = util.clamp(target.start_point+delta,(1+(8*(target.clip-1))),(8.9+(8*(target.clip-1))))
  end
end

function ea.sc.move_play_window(target)
  pad = bank[target][bank[target].id]
  softcut.loop_start(target+1,pad.start_point)
  softcut.loop_end(target+1,pad.end_point)
end

function ea.sc.move_rec_window(target)
  softcut.loop_start(1,target.start_point)
  softcut.loop_end(1,target.end_point-0.01)
end

function ea.sc.move_start(target)
  pad = bank[target][bank[target].id]
  softcut.loop_start(target+1, pad.start_point)
end

return encoder_actions

--[===[

local encoder_actions = {}
ea = encoder_actions

ea.sc = {}

ea.init(n,d)
  -- TODO
  local pattern_playing = false
  if grid_pat[id].play == 0 and grid_pat[id].tightened_start == 0 then
    pattern_playing = true
  else
    pattern_playing = false
  end

    
end


--]===]