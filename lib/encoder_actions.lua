encoder_actions = {}

function encoder_actions.init(n,d)
  if n == 1 then
    if menu == 2 then
      local id = page.loops_sel + 1
      if id ~= 4 then
        if key1_hold or grid.alt == 1 then
          bank[id].id = util.clamp(bank[id].id + d,1,16)
          selected[id].x = (math.ceil(bank[id].id/4)+(5*(id-1)))
          selected[id].y = 8-((bank[id].id-1)%4)
          cheat(id,bank[id].id)
        else
          local current_difference = (bank[id][bank[id].id].end_point - bank[id][bank[id].id].start_point)
          if bank[id][bank[id].id].start_point + current_difference <= (9+(8*(bank[id][bank[id].id].clip-1))) then
            bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point + d/loop_enc_resolution,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
            bank[id][bank[id].id].end_point = bank[id][bank[id].id].start_point + current_difference
          else
            bank[id][bank[id].id].end_point = (9+(8*(bank[id][bank[id].id].clip-1)))
            bank[id][bank[id].id].start_point = bank[id][bank[id].id].end_point - current_difference
          end
        end
        softcut.loop_start(id+1,bank[id][bank[id].id].start_point)
        softcut.loop_end(id+1,bank[id][bank[id].id].end_point)
      elseif id == 4 then
        if key1_hold or grid.alt == 1 then
          local pre_adjust = rec.clip
          local current_difference = (rec.end_point - rec.start_point)
          rec.clip = util.clamp(rec.clip+d,1,3)
          rec.start_point = rec.start_point - ((pre_adjust - rec.clip)*8)
          rec.end_point = rec.start_point + current_difference
        else
          local current_difference = (rec.end_point - rec.start_point)
          if rec.start_point + current_difference <= (9+(8*(rec.clip-1))) then
            rec.start_point = util.clamp(rec.start_point + d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
            rec.end_point = rec.start_point + current_difference
          else
            rec.end_point = (9+(8*(rec.clip-1)))
            rec.start_point = rec.end_point - current_difference
          end
        end
        softcut.loop_start(1,rec.start_point)
        softcut.loop_end(1,rec.end_point)
      end
    elseif menu == 7 then
      page.time_sel = util.clamp(page.time_sel+d,1,5)
    end
  end
  if n == 2 then
    if menu == 1 then
      page.main_sel = util.clamp(page.main_sel+d,1,7)
    elseif menu == 2 then
      local id = page.loops_sel + 1
      if id ~=4 then
        if key1_hold or grid.alt == 1 then
          local pre_adjust = bank[id][bank[id].id].clip
          local current_difference = (bank[id][bank[id].id].end_point - bank[id][bank[id].id].start_point)
          if bank[id][bank[id].id].mode == 1 and bank[id][bank[id].id].clip + d > 3 then
            bank[id][bank[id].id].mode = 2
            bank[id][bank[id].id].clip = 1
          elseif bank[id][bank[id].id].mode == 2 and bank[id][bank[id].id].clip + d < 1 then
            bank[id][bank[id].id].mode = 1
            bank[id][bank[id].id].clip = 3
          else
            bank[id][bank[id].id].clip = util.clamp(bank[id][bank[id].id].clip+d,1,3)
          end
          bank[id][bank[id].id].start_point = bank[id][bank[id].id].start_point - ((pre_adjust - bank[id][bank[id].id].clip)*8)
          bank[id][bank[id].id].end_point = bank[id][bank[id].id].start_point + current_difference
          print(bank[id][bank[id].id].start_point)
          cheat(id,bank[id].id)
          if bank[id].id == 1 then
            for i = 2,16 do
              bank[id][i].mode = bank[id][1].mode
              bank[id][i].clip = bank[id][1].clip
              bank[id][i].start_point = bank[id][1].start_point
              bank[id][i].end_point = bank[id][1].end_point
            end
          end
        else
          if d >= 0 and bank[id][bank[id].id].start_point < (bank[id][bank[id].id].end_point - d/loop_enc_resolution) then
            bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point+d/loop_enc_resolution,(1+(8*(bank[id][bank[id].id].clip-1))),(8.9+(8*(bank[id][bank[id].id].clip-1))))
          elseif d < 0 then
            bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point+d/loop_enc_resolution,(1+(8*(bank[id][bank[id].id].clip-1))),(8.9+(8*(bank[id][bank[id].id].clip-1))))
          end
          softcut.loop_start(id+1, bank[id][bank[id].id].start_point)
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
          if d >= 0 and rec.start_point < (rec.end_point - d/10) then
            rec.start_point = util.clamp(rec.start_point+d/10,(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
          elseif d < 0 then
            rec.start_point = util.clamp(rec.start_point+d/10,(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
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
      page.time_page_sel[page.time_sel] = util.clamp(page.time_page_sel[page.time_sel]+d,1,3)
    end
  end
  if n == 3 then
    if menu == 2 then
      local id = page.loops_sel + 1
      if id ~= 4 then
        if key1_hold or grid.alt == 1 then
          local current_offset = (math.log(bank[id][bank[id].id].offset)/math.log(0.5))*-12
          current_offset = util.clamp(current_offset+d,-24,24)
          if current_offset > -1 and current_offset < 1 then
            current_offset = 0
          end
          bank[id][bank[id].id].offset = math.pow(0.5, -current_offset / 12)
          cheat(id,bank[id].id)
          if bank[id].id == 1 then
            for i = 2,16 do
              bank[id][i].offset = bank[id][1].offset
            end
          end
        else
          if d <= 0 and bank[id][bank[id].id].start_point < bank[id][bank[id].id].end_point + d/loop_enc_resolution then
            bank[id][bank[id].id].end_point = util.clamp(bank[id][bank[id].id].end_point+d/loop_enc_resolution,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
          elseif d > 0 then
            bank[id][bank[id].id].end_point = util.clamp(bank[id][bank[id].id].end_point+d/loop_enc_resolution,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
          end
          softcut.loop_end(id+1, bank[id][bank[id].id].end_point)
        end
      elseif id == 4 then
        if d <= 0 and rec.start_point < rec.end_point + d/10 then
          rec.end_point = util.clamp(rec.end_point+d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
        elseif d > 0 then
          rec.end_point = util.clamp(rec.end_point+d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
        end
        softcut.loop_end(1, rec.end_point)
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
      if page.time_sel == 1 then
        if page.time_page_sel[page.time_sel] == 1 then
          params:delta("bpm",d)
        elseif page.time_page_sel[page.time_sel] == 2 then
          params:delta("clock",d)
        elseif page.time_page_sel[page.time_sel] == 3 then
          params:delta("crow_clock_out",d)
        end
      elseif page.time_sel < 5 then
        if page.time_page_sel[page.time_sel] == 3 then
          bank[page.time_sel-1].crow_execute = util.clamp(bank[page.time_sel-1].crow_execute+d,0,1)
        elseif page.time_page_sel[page.time_sel] == 2 then
          bank[page.time_sel-1].snap_to_bars = util.clamp(bank[page.time_sel-1].snap_to_bars+d,1,16)
        end
      elseif page.time_sel == 5 then
        if page.time_page_sel[page.time_sel] == 1 then
          params:delta("lock_pat",d)
        elseif page.time_page_sel[page.time_sel] == 2 then
          params:delta("quantize_pads",d)
          if not clk.externalmidi and not clk.externalcrow then
            params:delta("quantize_pats",d)
          end
        elseif page.time_page_sel[page.time_sel] == 3 then
          params:delta("quant_div",d)
        end
      end
    end
  end
  if menu == 3 then
    if page.levels_sel == 0 then
      if key1_hold or grid.alt == 1 then
        for i = 1,16 do
          bank[n][i].level = util.clamp(bank[n][i].level+d/10,0,2)
        end
      else
        bank[n][bank[n].id].level = util.clamp(bank[n][bank[n].id].level+d/10,0,2)
      end
      softcut.level_slew_time(n+1,1.0)
      softcut.level(n+1,bank[n][bank[n].id].level)
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
        local pre_enveloped = bank[n][bank[n].id].enveloped
        if bank[n][bank[n].id].enveloped then
          if d < 0 then
            bank[n][bank[n].id].enveloped = false
            if pre_enveloped ~= bank[n][bank[n].id].enveloped then
              cheat(n, bank[n].id)
            end
          end
        else
          if d > 0 then
            bank[n][bank[n].id].enveloped = true
            if pre_enveloped ~= bank[n][bank[n].id].enveloped then
              cheat(n, bank[n].id)
            end
          end
        end
      end
    elseif page.levels_sel == 2 then
      if key1_hold or grid.alt == 1 then
        for j = 1,16 do
          if bank[n][j].enveloped then
            bank[n][j].envelope_time = util.clamp(bank[n][j].envelope_time+d/10,0.1,60)
          end
        end
      else
        if bank[n][bank[n].id].enveloped then
          bank[n][bank[n].id].envelope_time = util.clamp(bank[n][bank[n].id].envelope_time+d/10,0.1,60)
        end
      end
    end
  end
  if menu == 4 then
    if key1_hold or grid.alt == 1 then
      for i = 1,16 do
        bank[n][i].pan = util.clamp(bank[n][i].pan+d/10,-1,1)
      end
    else
      bank[n][bank[n].id].pan = util.clamp(bank[n][bank[n].id].pan+d/10,-1,1)
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

return encoder_actions