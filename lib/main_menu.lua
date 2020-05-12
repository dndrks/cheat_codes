local main_menu = {}

function main_menu.init()
  if menu == 1 then
    screen.move(0,10)
    screen.text("cheat codes")
    screen.move(10,30)
    for i = 1,8 do
      screen.level(page.main_sel == i and 15 or 3)
      if i < 4 then
        screen.move(10,20+(10*i))
      elseif i < 8 then
        screen.move(60,10*(i-1))
      --[[elseif i == 7 then
        screen.move(110,30)
        --]]
      elseif i == 8 then
        screen.move(118,64)
      end
      local selected = {"[ loops ]", "[ levels ]", "[ panning ]", "[ filters ]", "[ delay ]", "[ timing ]", "[ tkr ]", "[?]"}
      local unselected = {"loops", "levels", "panning", "filters", "delay", "timing", "tkr", " ? "}
      if page.main_sel == i then
        screen.text(selected[i])
      else
        screen.text(unselected[i])
      end
    end
  elseif menu == 2 then
    screen.move(0,10)
    screen.level(3)
    screen.text("loops")
    if key1_hold then
      local id = page.loops_sel+1
      local focused_pad = nil
      if grid.alt == 1 then
        screen.move(0,20)
        screen.level(6)
        screen.text("(grid-ALT sets offset for all)")
      end
      for i = 1,3 do
        --if grid_pat[i].play == 0 and grid_pat[i].tightened_start == 0 and grid_pat[i].external_start == 0 then
        if grid_pat[i].play == 0 and grid_pat[i].tightened_start == 0 then
          focused_pad = bank[i].id
        else
          focused_pad = bank[i].focus_pad
        end
        if page.loops_sel == i-1 then
          if page.loops_sel < 3 and focused_pad == 16 and grid.alt == 0 then
            screen.move(0,20)
            screen.level(6)
            screen.text("(pad 16 overwrites bank!)")
          end
          --if grid_pat[i].play == 1 or grid_pat[i].tightened_start == 1 or grid_pat[i].external_start == 1 then
          if grid_pat[i].play == 1 or grid_pat[i].tightened_start == 1 then
            screen.move(0,10)
            screen.level(3)
            screen.text("loops: bank "..i.." is pad-locked")
          end
        end
        screen.move(0,20+(i*10))
        screen.level(page.loops_sel == i-1 and 15 or 3)
        if grid.alt == 0 then
          local loops_to_screen_options = {"a", "b", "c"}
          screen.text(loops_to_screen_options[i]..""..focused_pad)
        else
          local loops_to_screen_options = {"(a)","(b)","(c)"}
          screen.text(loops_to_screen_options[i])
        end
        screen.move(20,20+(i*10))
        screen.text((bank[i][focused_pad].mode == 1 and "Live" or "Clip")..":")
        screen.move(40,20+(i*10))
        screen.text(bank[i][focused_pad].clip)
        screen.move(55,20+(i*10))
        screen.text("offset: "..string.format("%.0f",((math.log(bank[i][focused_pad].offset)/math.log(0.5))*-12)).." st")
      end
      screen.level(page.loops_sel == 3 and 15 or 3)
      screen.move(0,60)
      screen.text("L"..rec.clip)
      screen.move(20,60)
      screen.text(rec.state == 1 and "recording" or "not recording")
      screen.move(88,60)
      local rate_options = {"8 s","16 s","32 s"}
      screen.text(rate_options[params:get"live_buff_rate"])
      screen.move(111,60)
      screen.level(3)
      screen.text(string.format("%0.f",util.linlin(rec.start_point-(8*(rec.clip-1)),rec.end_point-(8*(rec.clip-1)),0,100,(poll_position_new[1] - (8*(rec.clip-1))))).."%")
    else
      local which_pad = nil
      screen.line_width(1)
      for i = 1,3 do
        if bank[i].focus_hold == false then
          which_pad = bank[i].id
        else
          which_pad = bank[i].focus_pad
        end
        screen.move(0,10+(i*15))
        screen.level(page.loops_sel == i-1 and 15 or 3)
        local loops_to_screen_options = {"a", "b", "c"}
        screen.text(loops_to_screen_options[i]..""..which_pad)
        screen.move(15,10+(i*15))
        screen.line(120,10+(i*15))
        screen.close()
        screen.stroke()
      end
      for i = 1,3 do
        if bank[i].focus_hold == false then
          which_pad = bank[i].id
        else
          which_pad = bank[i].focus_pad
        end
        screen.level(page.loops_sel == i-1 and 15 or 3)
        local start_to_screen = util.linlin(1,9,15,120,(bank[i][which_pad].start_point - (8*(bank[i][which_pad].clip-1))))
        screen.move(start_to_screen,24+(15*(i-1)))
        screen.text("|")
        local end_to_screen = util.linlin(1,9,15,120,bank[i][which_pad].end_point - (8*(bank[i][which_pad].clip-1)))
        screen.move(end_to_screen,30+(15*(i-1)))
        screen.text("|")
        if bank[i].focus_hold == false or bank[i].id == bank[i].focus_pad then
          local current_to_screen = util.linlin(1,9,15,120,(poll_position_new[i+1] - (8*(bank[i][bank[i].id].clip-1))))
          screen.move(current_to_screen,27+(15*(i-1)))
          screen.text("|")
        end
      end
      screen.level(page.loops_sel == 3 and 15 or 3)
      local recording_playhead = util.linlin(1,9,15,120,(poll_position_new[1] - (8*(rec.clip-1))))
      if rec.state == 1 then
        screen.move(recording_playhead,64)
        screen.text(".")
      elseif rec.state == 0 then
        screen.move(recording_playhead,67)
        screen.text_center("||")
      end
      local recording_start = util.linlin(1,9,15,120,(rec.start_point - (8*(rec.clip-1))))
      screen.move(recording_start,66)
      screen.text("|")
      local recording_end = util.linlin(1,9,15,120,rec.end_point - (8*(rec.clip-1)))
      screen.move(recording_end,66)
      screen.text("|")
      screen.move(123,64)
      screen.text(rec.clip)
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 3 then
    screen.move(0,10)
    screen.level(3)
    screen.text("levels")
    screen.line_width(1)
    local level_options = {"levels","envelope enable","decay"}
    local focused_pad = nil
    for i = 1,3 do
      if bank[i].focus_hold == true then
        focused_pad = bank[i].focus_pad
      else
        focused_pad = bank[i].id
      end
      screen.level(3)
      screen.move(10,79-(i*20))
      local level_markers = {"0 -", "1 -", "2 -"}
      screen.text(level_markers[i])
      screen.move(10+(i*20),64)
      screen.level(level_options[page.levels_sel+1] == "levels" and 15 or 3)
      local level_to_screen_options = {"a", "b", "c"}
      if key1_hold or grid.alt == 1 then
        screen.text("("..level_to_screen_options[i]..")")
      else
        screen.text(level_to_screen_options[i]..""..focused_pad)
      end
      screen.move(35+(20*(i-1)),57)
      local level_to_screen = util.linlin(0,2,0,40,bank[i][focused_pad].level)
      screen.line(35+(20*(i-1)),57-level_to_screen)
      screen.close()
      screen.stroke()
      screen.level(level_options[page.levels_sel+1] == "envelope enable" and 15 or 3)
      screen.move(90,10)
      screen.text("env?")
      screen.move(90+((i-1)*15),20)
      if bank[i][focused_pad].enveloped then
        screen.text("|\\")
      else
        screen.text("-")
      end
      screen.level(level_options[page.levels_sel+1] == "decay" and 15 or 3)
      screen.move(90,30)
      screen.text("decay")
      screen.move(90,30+((i)*10))
      local envelope_to_screen_options = {"a", "b", "c"}
      if key1_hold or grid.alt == 1 then
        screen.text("("..envelope_to_screen_options[i]..")")
      else
        screen.text(envelope_to_screen_options[i]..""..focused_pad)
      end
      screen.move(110,30+((i)*10))
      if bank[i][focused_pad].enveloped then
        screen.text(string.format("%.1f", bank[i][focused_pad].envelope_time))
      else
        screen.text("---")
      end
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 4 then
    screen.move(0,10)
    screen.level(3)
    screen.text("panning")
    local focused_pad = nil
    for i = 1,3 do
      if bank[i].focus_hold == true then
        focused_pad = bank[i].focus_pad
      else
        focused_pad = bank[i].id
      end
      screen.level(3)
      screen.move(10+((i-1)*53),25)
      local pan_options = {"L", "C", "R"}
      screen.text(pan_options[i])
      local pan_to_screen = util.linlin(-1,1,10,112,bank[i][focused_pad].pan)
      screen.move(pan_to_screen,35+(10*(i-1)))
      local pan_to_screen_options = {"a", "b", "c"}
      screen.level(15)
      if key1_hold or grid.alt == 1 then
        screen.text("("..pan_to_screen_options[i]..")")
      else
        screen.text(pan_to_screen_options[i]..""..focused_pad)
      end
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 5 then
    screen.move(0,10)
    screen.level(3)
    screen.text("filters")
    
    for i = 1,3 do
      screen.move(17+((i-1)*45),25)
      screen.level(15)
      local filters_to_screen_options = {"a", "b", "c"}
      if key1_hold or grid.alt == 1 then
        screen.text_center(filters_to_screen_options[i]..""..bank[i].id)
      else
        screen.text_center("("..filters_to_screen_options[i]..")")
      end
      screen.move(17+((i-1)*45),35)
      
      screen.level(page.filtering_sel+1 == 1 and 15 or 3)
      if slew_counter[i].slewedVal ~= nil then
        if slew_counter[i].slewedVal >= -0.04 and slew_counter[i].slewedVal <=0.04 then
        screen.text_center(".....|.....")
        elseif slew_counter[i].slewedVal < -0.04 then
          if slew_counter[i].slewedVal > -0.3 then
            screen.text_center("....||.....")
          elseif slew_counter[i].slewedVal > -0.45 then
            screen.text_center("...|||.....")
          elseif slew_counter[i].slewedVal > -0.65 then
            screen.text_center("..||||.....")
          elseif slew_counter[i].slewedVal > -0.8 then
            screen.text_center(".|||||.....")
          elseif slew_counter[i].slewedVal >= -1.01 then
            screen.text_center("||||||.....")
          end
        elseif slew_counter[i].slewedVal > 0 then
          if slew_counter[i].slewedVal < 0.5 then
            screen.text_center(".....||....")
          elseif slew_counter[i].slewedVal < 0.65 then
            screen.text_center(".....|||...")
          elseif slew_counter[i].slewedVal < 0.8 then
            screen.text_center(".....||||..")
          elseif slew_counter[i].slewedVal < 0.85 then
            screen.text_center(".....|||||.")
          elseif slew_counter[i].slewedVal <= 1.01 then
            screen.text_center(".....||||||")
          end
        end
      end
      screen.move(17+((i-1)*45),45)
      screen.level(page.filtering_sel+1 == 2 and 15 or 3)
      local ease_time_to_screen = bank[i][bank[i].id].tilt_ease_time
      screen.text_center(string.format("%.2f",ease_time_to_screen/100).."s")
      screen.move(17+((i-1)*45),55)
      screen.level(page.filtering_sel+1 == 3 and 15 or 3)
      local ease_type_to_screen = bank[i][bank[i].id].tilt_ease_type
      local ease_types = {"cont","jumpy"}
      screen.text_center(ease_types[ease_type_to_screen])
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 6 then
    screen.move(0,10)
    screen.level(3)
    screen.text("delay")
    local options = {"rate","feed","cutoff","q","level"}
    for i = 1,5 do
      screen.level(page.delay_sel == i-1 and 15 or 3)
      screen.move(65,12 + (10*i))
      screen.text_center(options[i])
    end
    screen.level(page.delay_sel == 0 and 15 or 3)
    screen.move(25,22)
    screen.text_center(params:string("delay L: rate"))
    screen.move(105,22)
    screen.text_center(params:string("delay R: rate"))
    screen.level(page.delay_sel == 1 and 15 or 3)
    screen.move(25,32)
    screen.text_center(string.format("%.0f", params:get("delay L: feedback")))
    screen.move(105,32)
    screen.text_center(string.format("%.0f", params:get("delay R: feedback")))
    screen.level(page.delay_sel == 2 and 15 or 3)
    screen.move(25,42)
    screen.text_center(string.format("%.0f", params:get("delay L: filter cut")))
    screen.move(105,42)
    screen.text_center(string.format("%.0f", params:get("delay R: filter cut")))
    screen.level(page.delay_sel == 3 and 15 or 3)
    screen.move(25,52)
    screen.text_center(string.format("%.2f", params:get("delay L: filter q")))
    screen.move(105,52)
    screen.text_center(string.format("%.2f", params:get("delay R: filter q")))
    screen.level(page.delay_sel == 4 and 15 or 3)
    screen.move(25,62)
    screen.text_center(string.format("%.2f", params:get("delay L: global level")))
    screen.move(105,62)
    screen.text_center(string.format("%.2f", params:get("delay R: global level")))
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 7 then
    screen.move(0,10)
    screen.level(3)
    screen.text("timing")
    screen.level(3)
    screen.move(110,10)
    local show_me_beats = clock.get_beats() % 4
    local show_me_frac = math.fmod(clock.get_beats(),1)
    if show_me_frac <= 0.25 then
      show_me_frac = 1
    elseif show_me_frac <= 0.5 then
      show_me_frac = 2
    elseif show_me_frac <= 0.75 then
      show_me_frac = 3
    else
      show_me_frac = 4
    end
    screen.text((math.modf(show_me_beats)+1).."."..show_me_frac)
    screen.level(10)
    screen.move(10,30)
    screen.line(123,30)
    screen.stroke()
    local playing = {}
    local display_step = {}
    for i = 1,3 do
      local time_page = page.time_page_sel
      local page_line = page.time_sel
      local pattern = grid_pat[page_line]
      screen.level(page_line == i and 15 or 3)
      if grid_pat[i].play == 1 or grid_pat[i].tightened_start == 1 then
        playing[i] = 1
      else
        playing[i] = 0
      end
      if grid_pat[i].quantize == 1 then
        display_step[i] = quantized_grid_pat[i].current_step
      else
        display_step[i] = grid_pat[i].step
      end
      local playing_options =
      { [i] = { "P"..i  , "P"..i.."  > "..display_step[i],  "P"..i.."  x "..display_step[i]} }
      screen.move(10+(40*(i-1)),25)
      screen.text(playing_options[i][grid_pat[i].count == 0 and 1 or playing[i] == 1 and 2 or playing[i] == 0 and 3])
      local p_options = {"rec mode", "shuffle pat","crow output"," ", "rand pat [K3]", "pat start", "pat end"}
      local p_options_external_clock = {"rec mode (ext)","shuffle pat","crow output"}
      local p_options_rand = {"low rates", "mid rates", "hi rates", "full range"}
      if page.time_scroll[page_line] == 1 then
        for j = 1,3 do
          screen.level(time_page[page_line] == j and 15 or 3)
          screen.move(10,40+(10*(j-1)))
          screen.text(p_options[j])
          local mode_options = {"loose","distro","quant","quant+trim"}
          local fine_options = {mode_options[pattern.playmode], pattern.count > 0 and pattern.rec == 0 and "[K3]" or "(no pat!)", bank[page_line].crow_execute == 1 and "pads" or "clk"}
          screen.move(80,40+(10*(j-1)))
          screen.text(fine_options[j])
          if bank[page_line].crow_execute ~= 1 then
            screen.move(97,60)
            screen.level(time_page[page_line] == 4 and 15 or 3)
            screen.text("(/"..crow.count_execute[page_line]..")")
          end
        end
      else
        for j = 5,7 do
          screen.level(time_page[page_line] == j and 15 or 3)
          screen.move(10,40+(10*(j-5)))
          screen.text(p_options[j])
          screen.move(80,40+(10*(j-5)))
          local fine_options = {p_options_rand[pattern.random_pitch_range], pattern.count > 0 and pattern.rec == 0 and pattern.start_point or "(no pat!)", pattern.count > 0 and pattern.rec == 0 and pattern.end_point or "(no pat!)"}
          screen.text(fine_options[j-4])
        end
      end
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  elseif menu == 8 then
    screen.move(0,10)
    screen.level(3)
    screen.text("tracker")
    screen.level(page.track_page_section[page.track_page] == 1 and 15 or 3)
    screen.move(40,10)
    local header = {"1","2","3","fill"}
    for i = 1,4 do
      screen.level(page.track_page_section[page.track_page] == 1 and (page.track_page == i and 15) or 3)
      screen.move(35+(i*15),10)
      screen.text(header[i])
    end
    screen.level(page.track_page_section[page.track_page] == 1 and (page.track_page == page.track_page and 15) or 3)
    screen.move(35+(page.track_page*15),13)
    screen.text(page.track_page < 4 and "_" or "__")
    screen.level(3)
    --[[
    for i = 0,1 do
      screen.move(20+(i*60),20)
      screen.text("p")
      screen.move(35+(i*60),20)
      screen.text("d")
    end
    --]]
    local deci_to_frac =
    { ["0.1667"] = "1/16t"
    , ["0.25"] = "1/16"
    , ["0.3333"] = "1/8t"
    , ["0.5"] = "1/8"
    , ["0.6667"] = "1/4t"
    , ["1.0"] = "1/4"
    , ["1.3333"] = "1/2t"
    , ["2.0"] = "1/2"
    , ["2.6667"] = "1t"
    , ["4.0"] = "1"
    }

    function tracker_to_screen(line)
      screen.level(3)
      local current = math.modf(line/4)
      local vert_position = 30+(10*(line-(4*current)))
      local left_side = current % 2 == 0
      screen.move(left_side and 0 or 60,tracker[page.track_page].step == line+1 and vert_position or 0)
      screen.text(">")
      if page.track_page_section[page.track_page] == 1 then
        screen.level(3)
      else  
        screen.level(page.track_sel[page.track_page] - 1 == line and 15 or 3)
      end
      screen.move(left_side and 5 or 65,vert_position)
      screen.text(line+1)
      screen.move(left_side and 20 or 80,vert_position)
      screen.text(tracker[page.track_page][line+1].pad==nil and "--" or tracker[page.track_page][line+1].pad)
      screen.move(left_side and 35 or 95,vert_position)
      screen.text(tracker[page.track_page][line+1].time==nil and "--" or deci_to_frac[tostring(util.round(tracker[page.track_page][line+1].time, 0.0001))])
    end


    local snakes = 
    { [1] = { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 }
    , [2] = { 1,2,3,4,8,7,6,5,9,10,11,12,16,15,14,13 }
    , [3] = { 1,5,9,13,2,6,10,14,3,7,11,15,4,8,12,16 }
    , [4] = { 1,5,9,13,14,10,6,2,3,7,11,15,16,12,8,4 }
    , [5] = { 1,2,3,4,8,12,16,15,14,13,9,5,6,7,11,10 }
    , [6] = { 13,14,15,16,12,8,4,3,2,1,5,9,10,11,7,6 }
    , [7] = { 1,2,5,9,6,3,4,7,10,13,14,11,8,12,15,16 }
    , [8] = { 1,6,11,16,15,10,5,2,7,12,8,3,9,14,13,4 }
    }

    function fill_to_screen()
      screen.level(page.track_page_section[page.track_page] == 2 and 15 or 3)
      screen.move(0,27)
      screen.text("snake: "..tracker[1].snake)
    end

    function snake_to_screen()
      screen.level(3)
      local source_options = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"}
      local fill_options = {}
      for i = 1,8 do
        fill_options[i] = {}
      end
      for i = 1,16 do
        fill_options[1][snakes[tracker[1].snake][i]] = source_options[i]
      end
      for i = 1,16 do
        local current_line = math.modf((i-1)/4)
        local horiz_position = 60+((i-(4*current_line))*10)
        local vert_position = 27+(10*((1*current_line)))
        screen.move(horiz_position,vert_position)
        screen.text(fill_options[1][i].." ")
      end
    end

    if page.track_page < 4 then
      local screen_lim = tonumber(string.format("%.0f", 9 + (((math.modf((page.track_sel[page.track_page]-1)/8))*8))))
      if page.track_sel[page.track_page] < screen_lim then
        for i = screen_lim - 9, screen_lim - 2 do
          tracker_to_screen(i)
        end
      end
    else
      fill_to_screen()
      snake_to_screen()
    end

  elseif menu == 9 then
    screen.move(0,10)
    screen.level(3)
    screen.text("help")
    if help_menu == "welcome" then
      help_menus.welcome()
    elseif help_menu == "banks" then
      help_menus.banks()
    elseif help_menu == "zilchmo_4" then
      help_menus.zilchmo4()
    elseif help_menu == "zilchmo_3" then
      help_menus.zilchmo3()
    elseif help_menu == "zilchmo_2" then
      help_menus.zilchmo2()
    elseif help_menu == "grid patterns" then
      help_menus.grid_pattern()
    elseif help_menu == "alt" then
      help_menus.alt()
    elseif help_menu == "loop" then
      help_menus.loop()
    elseif help_menu == "mode" then
      help_menus.mode()
    elseif help_menu == "buffer jump" then
      help_menus.buffer_jump()
    elseif help_menu == "buffer switch" then
      help_menus.buffer_switch()
    elseif help_menu == "arc params" then
      help_menus.arc_params()
    elseif help_menu == "arc patterns" then
      help_menus.arc_pattern()
    elseif help_menu == "meta page" then
      help_menus.meta_page()
    elseif help_menu == "meta: slots" then
      help_menus.meta_slots()
    elseif help_menu == "meta: clock" then
      help_menus.meta_clock()
    elseif help_menu == "meta: step" then
      help_menus.meta_step()
    elseif help_menu == "meta: duration" then
      help_menus.meta_duration()
    elseif help_menu == "meta: alt" then
      help_menus.meta_alt()
    elseif help_menu == "meta: toggle" then
      help_menus.meta_toggle()
    elseif help_menu == "meta: loop mod" then
      help_menus.meta_loop_mod()
    end
    screen.level(3)
    screen.move(0,64)
    screen.text("...")
  
  end
end

return main_menu