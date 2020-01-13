encoder_actions = {}

function encoder_actions.init(n,d)
  if n == 1 then
    if menu == 2 then
      local id = page.loops_sel + 1
      --if key1_hold or grid.alt == 1 then
      if id ~= 4 then
        if key1_hold then
          bank[id].id = util.clamp(bank[id].id + d,1,16)
          selected[id].x = (math.ceil(bank[id].id/4)+(5*(id-1)))
          selected[id].y = 8-((bank[id].id-1)%4)
          cheat(id,bank[id].id)
        else
          local current_difference = (bank[id][bank[id].id].end_point - bank[id][bank[id].id].start_point)
          if bank[id][bank[id].id].start_point + current_difference <= (9+(8*(bank[id][bank[id].id].clip-1))) then
            bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point + d/10,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
            bank[id][bank[id].id].end_point = bank[id][bank[id].id].start_point + current_difference
          else
            bank[id][bank[id].id].end_point = (9+(8*(bank[id][bank[id].id].clip-1)))
            bank[id][bank[id].id].start_point = bank[id][bank[id].id].end_point - current_difference
          end
        end
        softcut.loop_start(id+1,bank[id][bank[id].id].start_point)
        softcut.loop_end(id+1,bank[id][bank[id].id].end_point)
      elseif id == 4 then
        local current_difference = (rec.end_point - rec.start_point)
        if rec.start_point + current_difference <= (9+(8*(rec.clip-1))) then
          rec.start_point = util.clamp(rec.start_point + d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
          rec.end_point = rec.start_point + current_difference
        else
          rec.end_point = (9+(8*(rec.clip-1)))
          rec.start_point = rec.end_point - current_difference
        end
        softcut.loop_start(1,rec.start_point)
        softcut.loop_end(1,rec.end_point)
      end
    elseif menu == 5 then
      local id = page.filtering_sel + 1
      if key1_hold or grid.alt == 1 then
        for j = 1,16 do
          bank[id][j].filter_type = util.clamp(bank[id][j].filter_type+d,1,3)
        end
      else
        bank[id][bank[id].id].filter_type = util.clamp(bank[id][bank[id].id].filter_type+d,1,3)
      end
      if bank[id][bank[id].id].filter_type == 1 then
        params:set("filter "..math.floor(tonumber(id)).." lp",1)
        params:set("filter "..math.floor(tonumber(id)).." hp",0)
        params:set("filter "..math.floor(tonumber(id)).." bp",0)
        params:set("filter "..math.floor(tonumber(id)).." dry",0)
      elseif bank[id][bank[id].id].filter_type == 2 then
        params:set("filter "..math.floor(tonumber(id)).." lp",0)
        params:set("filter "..math.floor(tonumber(id)).." hp",1)
        params:set("filter "..math.floor(tonumber(id)).." bp",0)
        params:set("filter "..math.floor(tonumber(id)).." dry",0)
      elseif bank[id][bank[id].id].filter_type == 3 then
        params:set("filter "..math.floor(tonumber(id)).." lp",0)
        params:set("filter "..math.floor(tonumber(id)).." hp",0)
        params:set("filter "..math.floor(tonumber(id)).." bp",1)
        params:set("filter "..math.floor(tonumber(id)).." dry",0)
      elseif bank[id][bank[id].id].filter_type == 4 then
        params:set("filter "..math.floor(tonumber(id)).." lp",0)
        params:set("filter "..math.floor(tonumber(id)).." hp",0)
        params:set("filter "..math.floor(tonumber(id)).." bp",0)
        params:set("filter "..math.floor(tonumber(id)).." dry",1)
      end
    end
  end
  if n == 2 then
    if menu == 1 then
      page.main_sel = util.clamp(page.main_sel+d,1,6)
    elseif menu == 2 then
      local id = page.loops_sel + 1
      if id ~=4 then
        if d >= 0 and bank[id][bank[id].id].start_point < (bank[id][bank[id].id].end_point - d/10) then
          bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point+d/10,(1+(8*(bank[id][bank[id].id].clip-1))),(8.9+(8*(bank[id][bank[id].id].clip-1))))
        elseif d < 0 then
          bank[id][bank[id].id].start_point = util.clamp(bank[id][bank[id].id].start_point+d/10,(1+(8*(bank[id][bank[id].id].clip-1))),(8.9+(8*(bank[id][bank[id].id].clip-1))))
        end
        softcut.loop_start(id+1, bank[id][bank[id].id].start_point)
      elseif id == 4 then
        if d >= 0 and rec.start_point < (rec.end_point - d/10) then
          rec.start_point = util.clamp(rec.start_point+d/10,(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
        elseif d < 0 then
          rec.start_point = util.clamp(rec.start_point+d/10,(1+(8*(rec.clip-1))),(8.9+(8*(rec.clip-1))))
        end
        softcut.loop_start(1, rec.start_point)
      end
    elseif menu == 5 then
      local id = page.filtering_sel + 1
      if bank[id][bank[id].id].filter_type ~= 4 then
        if key1_hold or grid.alt == 1 then
          for j = 1,16 do
            bank[id][j].fc = util.explin(10,12000,10,12000,bank[id][j].fc)
            bank[id][j].fc = util.clamp(bank[id][j].fc+(d*100), 10, 12000)
            bank[id][j].fc = util.linexp(10,12000,10,12000,bank[id][j].fc)
            --bank[id][j].fc = util.clamp(bank[id][j].fc+(d*100), 10, 12000)
          end
        else
          bank[id][bank[id].id].fc = util.explin(10,12000,10,12000,bank[id][bank[id].id].fc)
          bank[id][bank[id].id].fc = util.clamp(bank[id][bank[id].id].fc+(d*100), 10, 12000)
          bank[id][bank[id].id].fc = util.linexp(10,12000,10,12000,bank[id][bank[id].id].fc)
        end
        params:set("filter "..id.." cutoff", bank[id][bank[id].id].fc)
      elseif bank[id][bank[id].id].filter_type == 4 then
        if d < 0 and bank[id][bank[id].id].cf_lp < 1 and bank[id][bank[id].id].cf_hp == 0 then
          bank[id][bank[id].id].cf_lp = util.clamp(bank[id][bank[id].id].cf_lp-(d/100),0,1)
          bank[id][bank[id].id].cf_dry = util.clamp(bank[id][bank[id].id].cf_dry+(d/100),0,1)
          bank[id][bank[id].id].cf_exp_dry = (util.linexp(0,1,1,101,bank[id][bank[id].id].cf_dry)-1)/100
          bank[id][bank[id].id].cf_fc = util.linexp(0,1,12000,10,bank[id][bank[id].id].cf_lp)
          params:set("filter "..id.." cutoff",bank[id][bank[id].id].cf_fc)
          params:set("filter "..id.." lp", math.abs(bank[id][bank[id].id].cf_exp_dry-1))
          if bank[id][bank[id].id].cf_exp_dry < 0.05 then
            params:set("filter "..id.." dry", 0)
          else
            params:set("filter "..id.." dry", bank[id][bank[id].id].cf_exp_dry)
          end
        elseif d > 0 and bank[id][bank[id].id].cf_lp <= 1.0 and bank[id][bank[id].id].cf_hp == 0 and bank[id][bank[id].id].cf_dry < 1 then
          bank[id][bank[id].id].cf_lp = util.clamp(bank[id][bank[id].id].cf_lp-(d/100),0,1)
          bank[id][bank[id].id].cf_dry = util.clamp(bank[id][bank[id].id].cf_dry+(d/100),0,1)
          bank[id][bank[id].id].cf_exp_dry = (util.linexp(0,1,1,101,bank[id][bank[id].id].cf_dry)-1)/100
          bank[id][bank[id].id].cf_fc = util.linexp(0,1,12000,10,bank[id][bank[id].id].cf_lp)
          params:set("filter "..id.." cutoff",bank[id][bank[id].id].cf_fc)
          params:set("filter "..id.." lp", math.abs(bank[id][bank[id].id].cf_exp_dry-1))
          if bank[id][bank[id].id].cf_exp_dry < 0.05 then
            params:set("filter "..id.." dry", 0)
          else
            params:set("filter "..id.." dry", bank[id][bank[id].id].cf_exp_dry)
          end
        elseif d > 0 and bank[id][bank[id].id].cf_lp <= 0.001 then
          bank[id][bank[id].id].cf_hp = util.clamp(bank[id][bank[id].id].cf_hp+(d/100),0,1)
          bank[id][bank[id].id].cf_fc = util.linexp(0,1,10,12000,bank[id][bank[id].id].cf_hp)
          bank[id][bank[id].id].cf_dry = util.clamp(bank[id][bank[id].id].cf_dry-(d/100),0,1)
          bank[id][bank[id].id].cf_exp_dry = (util.linexp(0,1,1,101,bank[id][bank[id].id].cf_dry)-1)/100
          params:set("filter "..id.." cutoff",bank[id][bank[id].id].cf_fc)
          params:set("filter "..id.." hp", math.abs(bank[id][bank[id].id].cf_exp_dry-1))
          params:set("filter "..id.." dry", bank[id][bank[id].id].cf_exp_dry)
        elseif d < 0 and bank[id][bank[id].id].cf_hp <= 1.0 and bank[id][bank[id].id].cf_lp <= 0.001 then
          bank[id][bank[id].id].cf_hp = util.clamp(bank[id][bank[id].id].cf_hp+(d/100),0,1)
          bank[id][bank[id].id].cf_fc = util.linexp(0,1,10,12000,bank[id][bank[id].id].cf_hp)
          bank[id][bank[id].id].cf_dry = util.clamp(bank[id][bank[id].id].cf_dry-(d/100),0,1)
          bank[id][bank[id].id].cf_exp_dry = (util.linexp(0,1,1,101,bank[id][bank[id].id].cf_dry)-1)/100
          params:set("filter "..id.." cutoff",bank[id][bank[id].id].cf_fc)
          params:set("filter "..id.." hp", math.abs(bank[id][bank[id].id].cf_exp_dry-1))
          params:set("filter "..id.." dry", bank[id][bank[id].id].cf_exp_dry)
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
    end
  end
  if n == 3 then
    if menu == 2 then
      local id = page.loops_sel + 1
      if id ~= 4 then
        if d <= 0 and bank[id][bank[id].id].start_point < bank[id][bank[id].id].end_point + d/10 then
          bank[id][bank[id].id].end_point = util.clamp(bank[id][bank[id].id].end_point+d/10,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
        elseif d > 0 then
          bank[id][bank[id].id].end_point = util.clamp(bank[id][bank[id].id].end_point+d/10,(1+(8*(bank[id][bank[id].id].clip-1))),(9+(8*(bank[id][bank[id].id].clip-1))))
        end
        softcut.loop_end(id+1, bank[id][bank[id].id].end_point)
      elseif id == 4 then
        if d <= 0 and rec.start_point < rec.end_point + d/10 then
          rec.end_point = util.clamp(rec.end_point+d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
        elseif d > 0 then
          rec.end_point = util.clamp(rec.end_point+d/10,(1+(8*(rec.clip-1))),(9+(8*(rec.clip-1))))
        end
        softcut.loop_end(1, rec.end_point)
      end
    elseif menu == 5 then
      local id = page.filtering_sel + 1
      if key1_hold or grid.alt == 1 then
        for j = 1,16 do
          bank[id][j].q = util.clamp(bank[id][j].q+(d/100), 0, 8)
        end
      else
        bank[id][bank[id].id].q = util.clamp(bank[id][bank[id].id].q+(d/100), 0, 8)
      end
      params:set("filter "..id.." q", bank[id][bank[id].id].q)
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
      if k1_hold or grid.alt then
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
      if k1_hold or grid.alt then
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
  end
  redraw()
end

return encoder_actions