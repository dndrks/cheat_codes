arc_actions = {}

function arc_actions.init(n,d)
  --if n == 4 then n = 1 end
  local this_bank = bank[arc_control[n]]
  if n < 4 then
    if this_bank.focus_hold == false then
      which_pad = this_bank.id
    else
      which_pad = this_bank.focus_pad
    end
    local this_pad = this_bank[which_pad]
    if arc_param[n] == 1 then
      if grid.alt == 0 then
        local current_difference = (this_pad.end_point - this_pad.start_point)
        if this_pad.start_point + current_difference <= (9+(8*(this_pad.clip-1))) then
          this_pad.start_point = util.clamp(this_pad.start_point + d/80,(1+(8*(this_pad.clip-1))),(9+(8*(this_pad.clip-1))))
          this_pad.end_point = this_pad.start_point + current_difference
        else
          this_pad.end_point = (9+(8*(this_pad.clip-1)))
          this_pad.start_point = this_pad.end_point - current_difference
        end
      else
        for j = 1,16 do
          local current_difference = (this_bank[j].end_point - this_bank[j].start_point)
          if this_bank[j].start_point + current_difference <= (9+(8*(this_bank[j].clip-1))) then
            this_bank[j].start_point = util.clamp(this_bank[j].start_point + d/80,(1+(8*(this_bank[j].clip-1))),(9+(8*(this_bank[j].clip-1))))
            this_bank[j].end_point = this_bank[j].start_point + current_difference
          else
            this_bank[j].end_point = (9+(8*(this_bank[j].clip-1)))
            this_bank[j].start_point = this_bank[j].end_point - current_difference
          end
        end
      end
      if this_bank.focus_hold == false or this_bank.focus_pad == this_bank.id then
        softcut.loop_start(arc_control[n]+1,this_bank[this_bank.id].start_point)
        softcut.loop_end(arc_control[n]+1,this_bank[this_bank.id].end_point)
      end
    elseif arc_param[n] == 2 then
      if grid.alt == 0 then
        if this_pad.start_point < (this_pad.end_point - d/80) then
          this_pad.start_point = util.clamp(this_pad.start_point + d/80,(1+(8*(this_pad.clip-1))),(9+(8*(this_pad.clip-1))))
        end
      else
        for j = 1,16 do
          this_bank[j].start_point = util.clamp(this_bank[j].start_point + d/80,(1+(8*(this_bank[j].clip-1))),(9+(8*(this_bank[j].clip-1))))
        end
      end
      if this_bank.focus_hold == false or this_bank.focus_pad == this_bank.id then
        softcut.loop_start(arc_control[n]+1,this_bank[this_bank.id].start_point)
      end
    elseif arc_param[n] == 3 then
      if grid.alt == 0 then
        this_pad.end_point = util.clamp(this_pad.end_point + d/80,(1+(8*(this_pad.clip-1))),(9+(8*(this_pad.clip-1))))
      else
        for j = 1,16 do
          this_bank[j].end_point = util.clamp(this_bank[j].end_point + d/80,(1+(8*(this_bank[j].clip-1))),(9+(8*(this_bank[j].clip-1))))
        end
      end
      if this_bank.focus_hold == false or this_bank.focus_pad == this_bank.id then
        softcut.loop_end(arc_control[n]+1,this_bank[this_bank.id].end_point)
      end
    elseif arc_param[n] == 4 then
      local a_c = arc_control[n]
      if key1_hold or grid.alt == 1 then
        if slew_counter[a_c] ~= nil then
          slew_counter[a_c].prev_tilt = this_pad.tilt
        end
        this_pad.tilt = util.explin(1,3,-1,1,this_pad.tilt+2)
        this_pad.tilt = util.clamp(this_pad.tilt+(d/1000),-1,1)
        this_pad.tilt = util.linexp(-1,1,1,3,this_pad.tilt)-2
        if d < 0 then
          if util.round(this_pad.tilt*100) < 0 and util.round(this_pad.tilt*100) > -9 then
            this_pad.tilt = -0.10
          elseif util.round(this_pad.tilt*100) > 0 and util.round(this_pad.tilt*100) < 3 then
            this_pad.tilt = 0.0
          end
        end
        if this_bank.focus_hold == false or this_bank.focus_pad == this_bank.id then
          slew_filter(a_c,slew_counter[a_c].prev_tilt,this_bank[this_bank.id].tilt,this_bank[this_bank.id].q,this_bank[this_bank.id].q,15)
        end
      else
        if slew_counter[a_c] ~= nil then
          slew_counter[a_c].prev_tilt = this_bank[this_bank.id].tilt
        end
        for j = 1,16 do
          this_bank[j].tilt = util.explin(1,3,-1,1,this_bank[j].tilt+2)
          this_bank[j].tilt = util.clamp(this_bank[j].tilt+(d/1000),-1,1)
          this_bank[j].tilt = util.linexp(-1,1,1,3,this_bank[j].tilt)-2
          if d < 0 then
            if util.round(this_bank[j].tilt*100) < -1 and util.round(this_bank[j].tilt*100) > -9 then
              this_bank[j].tilt = -0.10
            elseif util.round(this_bank[j].tilt*100) > 0 and util.round(this_bank[j].tilt*100) < 3 then
              this_bank[j].tilt = 0.0
            end
          end
        end
        slew_filter(a_c,slew_counter[a_c].prev_tilt,this_bank[this_bank.id].tilt,this_bank[this_bank.id].q,this_bank[this_bank.id].q,15)
      end
    end
  end
  
  if n == 4 then
    if grid.alt == 0 then
      delay[1].arc_rate_tracker = util.clamp(delay[1].arc_rate_tracker + d/10,1,13)
      delay[1].arc_rate = math.floor(delay[1].arc_rate_tracker)
      params:set("delay L: rate",math.floor(delay[1].arc_rate_tracker))
    else
      delay[2].arc_rate_tracker = util.clamp(delay[2].arc_rate_tracker + d/10,1,13)
      delay[2].arc_rate = math.floor(delay[2].arc_rate_tracker)
      params:set("delay R: rate",math.floor(delay[2].arc_rate_tracker))
    end
  end

  if n == 1 or n == 2 or n == 3 then
    arc_p[n] = {}
    arc_p[n].i = n
    arc_p[n].param = arc_param[n]
    local id = arc_control[n]
    if bank[id].focus_hold == false then
      arc_p[n].pad = bank[id].id
    else
      arc_p[n].pad = bank[id].focus_pad
    end
    arc_p[n].start_point = bank[id][arc_p[n].pad].start_point - (8*(bank[id][arc_p[n].pad].clip-1))
    arc_p[n].end_point = bank[id][arc_p[n].pad].end_point - (8*(bank[id][arc_p[n].pad].clip-1))
    arc_p[n].prev_tilt = slew_counter[id].prev_tilt
    arc_p[n].tilt = bank[id][bank[id].id].tilt
    arc_pat[n]:watch(arc_p[n])
  end
  
  if n == 4 then
    arc_p[n] = {}
    arc_p[n].i = n
    if grid.alt == 0 then
      arc_p[n].delay_focus = "L"
      arc_p[n].left_delay_value = params:get("delay L: rate")
    else
      arc_p[n].delay_focus = "R"
      arc_p[n].right_delay_value = params:get("delay R: rate")
    end
  end
  redraw()
end

return arc_actions