arc_actions = {}

function arc_actions.init(n,d)
  if arc_param[n] == 1 then
    if grid.alt == 0 then
      local current_difference = (bank[arc_control[n]][bank[arc_control[n]].id].end_point - bank[arc_control[n]][bank[arc_control[n]].id].start_point)
      if bank[arc_control[n]][bank[arc_control[n]].id].start_point + current_difference <= (9+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))) then
        bank[arc_control[n]][bank[arc_control[n]].id].start_point = util.clamp(bank[arc_control[n]][bank[arc_control[n]].id].start_point + d/80,(1+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))),(9+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))))
        bank[arc_control[n]][bank[arc_control[n]].id].end_point = bank[arc_control[n]][bank[arc_control[n]].id].start_point + current_difference
      else
        bank[arc_control[n]][bank[arc_control[n]].id].end_point = (9+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1)))
        bank[arc_control[n]][bank[arc_control[n]].id].start_point = bank[arc_control[n]][bank[arc_control[n]].id].end_point - current_difference
      end
    else
      for j = 1,16 do
        local current_difference = (bank[arc_control[n]][j].end_point - bank[arc_control[n]][j].start_point)
        if bank[arc_control[n]][j].start_point + current_difference <= (9+(8*(bank[arc_control[n]][j].clip-1))) then
          bank[arc_control[n]][j].start_point = util.clamp(bank[arc_control[n]][j].start_point + d/80,(1+(8*(bank[arc_control[n]][j].clip-1))),(9+(8*(bank[arc_control[n]][j].clip-1))))
          bank[arc_control[n]][j].end_point = bank[arc_control[n]][j].start_point + current_difference
        else
          bank[arc_control[n]][j].end_point = (9+(8*(bank[arc_control[n]][j].clip-1)))
          bank[arc_control[n]][j].start_point = bank[arc_control[n]][j].end_point - current_difference
        end
      end
    end
    softcut.loop_start(arc_control[n]+1,bank[arc_control[n]][bank[arc_control[n]].id].start_point)
    softcut.loop_end(arc_control[n]+1,bank[arc_control[n]][bank[arc_control[n]].id].end_point)
  elseif arc_param[n] == 2 then
    if grid.alt == 0 then
      bank[arc_control[n]][bank[arc_control[n]].id].start_point = util.clamp(bank[arc_control[n]][bank[arc_control[n]].id].start_point + d/80,(1+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))),(9+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))))
    else
      for j = 1,16 do
        bank[arc_control[n]][j].start_point = util.clamp(bank[arc_control[n]][j].start_point + d/80,(1+(8*(bank[arc_control[n]][j].clip-1))),(9+(8*(bank[arc_control[n]][j].clip-1))))
      end
    end
    softcut.loop_start(arc_control[n]+1,bank[arc_control[n]][bank[arc_control[n]].id].start_point)
  elseif arc_param[n] == 3 then
    if grid.alt == 0 then
      bank[arc_control[n]][bank[arc_control[n]].id].end_point = util.clamp(bank[arc_control[n]][bank[arc_control[n]].id].end_point + d/80,(1+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))),(9+(8*(bank[arc_control[n]][bank[arc_control[n]].id].clip-1))))
    else
      for j = 1,16 do
        bank[arc_control[n]][j].end_point = util.clamp(bank[arc_control[n]][j].end_point + d/80,(1+(8*(bank[arc_control[n]][j].clip-1))),(9+(8*(bank[arc_control[n]][j].clip-1))))
      end
    end
    softcut.loop_end(arc_control[n]+1,bank[arc_control[n]][bank[arc_control[n]].id].end_point)
  elseif arc_param[n] == 4 then
    if grid.alt == 0 then
      bank[arc_control[n]][bank[arc_control[n]].id].fc = util.clamp(bank[arc_control[n]][bank[arc_control[n]].id].fc+(d*10), 10, 12000)
    else
      for j = 1,16 do
        bank[arc_control[n]][j].fc = util.clamp(bank[arc_control[n]][j].fc+(d*10), 10, 12000)
      end
    end
    params:set("filter "..arc_control[n].." cutoff", bank[arc_control[n]][bank[arc_control[n]].id].fc)
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
    arc_p[n].start_point = bank[id][bank[id].id].start_point - (8*(bank[id][bank[id].id].clip-1))
    arc_p[n].end_point = bank[id][bank[id].id].end_point - (8*(bank[id][bank[id].id].clip-1))
    arc_p[n].fc = bank[id][bank[id].id].fc
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
    arc_pat[n]:watch(arc_p[n])
  end
  redraw()
end

return arc_actions