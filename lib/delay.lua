local delays = {}

function delays.init(target)
  clocked_delays = {2,(7/4),(5/3),(3/2),(4/3),(5/4),(1),(4/5),(3/4),(2/3),(3/5),(4/7),(1/2)}
  delay = {}
  for i = 1,2 do
    delay[i] = {}
    delay[i].id = 7
    delay[i].arc_rate_tracker = 7
    delay[i].arc_rate = 7
    delay[i].rate = 1
    delay[i].start_point = 41 + (30*(i-1))
    delay[i].end_point = delay[i].start_point + 0.5
    delay[i].clocked_length = clocked_delays[7]
    delay[i].free_end_point = delay[i].start_point + 1
    delay[i].divisor = 1
    delay[i].mode = "clocked"
    delay[i].feedback_mute = false
    delay[i].level_mute = false
    delay[i].send_mute = false
    delay[i].held = 0
    delay[i].saver_active = false
    delay[i].selected_bundle = 0
  end

  delay_bundle = { {},{} }
  for i = 1,2 do
    for j = 1,16 do
      delay_bundle[i][j] = {}
      delay_bundle[i][j].saved = false
      delay_bundle[i][j].load_slot = 0
      delay_bundle[i][j].save_slot = nil
    end
  end

  delay_grid = {}
  delay_grid.bank = 1

end

function delays.build_bundle(target,slot)
  -- delay[target].saver_active = true -- declare this external to the function
  clock.sleep(1)
  if delay[target].saver_active then
    local b = delay_bundle[target][slot]
    local delay_name = target == 1 and "delay L: " or "delay R: "
    b.mode = params:get(delay_name.."mode")
    b.clocked_length = params:get(delay_name.."div/mult")
    b.free_end_point = params:get(delay_name.."free length")
    b.fade_time = params:get(delay_name.."fade time")
    b.rate = params:get(delay_name.."rate")
    b.feedback = params:get(delay_name.."feedback")
    b.filter_cut = params:get(delay_name.."filter cut")
    b.filter_q = params:get(delay_name.."filter q")
    b.filter_lp = params:get(delay_name.."filter lp")
    b.filter_hp = params:get(delay_name.."filter hp")
    b.filter_bp = params:get(delay_name.."filter bp")
    b.filter_dry = params:get(delay_name.."filter dry")
    b.global_level = params:get(delay_name.."global level")
    b.saved = true
  end
  delay[target].saver_active = false
  delay[target].selected_bundle = slot
end

function delays.restore_bundle(target,slot)
  local b = delay_bundle[target][slot]
  local delay_name = target == 1 and "delay L: " or "delay R: "
  if b.mode ~= nil then
    params:set(delay_name.."mode", b.mode)
    params:set(delay_name.."div/mult", b.clocked_length)
    params:set(delay_name.."free length", b.free_end_point)
    params:set(delay_name.."fade time", b.fade_time)
    params:set(delay_name.."rate", b.rate)
    params:set(delay_name.."feedback", b.feedback)
    params:set(delay_name.."filter cut", b.filter_cut)
    params:set(delay_name.."filter q", b.filter_q)
    params:set(delay_name.."filter lp", b.filter_lp)
    params:set(delay_name.."filter hp", b.filter_hp)
    params:set(delay_name.."filter bp", b.filter_bp)
    params:set(delay_name.."filter dry", b.filter_dry)
    params:set(delay_name.."global level", b.global_level)
  else
    print(delay_name.."no data saved in slot "..slot)
  end
end

function delays.savestate(target,slot,collection)
  local del_name = target == 1 and "L" or "R"
  local dirname = _path.data.."cheat_codes/delays/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  
  local dirname = _path.data.."cheat_codes/delays/collection-"..collection.."/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end

  tab.save(delay_bundle[target],_path.data .. "cheat_codes/delays/collection-"..collection.."/"..del_name..".data")
end

function delays.loadstate(collection)
  local del_name = {"L","R"}
  for i = 1,2 do
    if tab.load(_path.data .. "cheat_codes/delays/collection-"..collection.."/"..del_name[i]..".data") ~= nil then
      delay_bundle[i] = tab.load(_path.data .. "cheat_codes/delays/collection-"..collection.."/"..del_name[i]..".data")
    end
  end
end

function delays.quick_action(target,param)
  if param == "level mute" then
    delay[target].level_mute = not delay[target].level_mute
    if delay[target].level_mute then
      if params:get(target == 1 and "delay L: global level" or "delay R: global level") == 0 then
        softcut.level(target+4,1)
      else
        softcut.level(target+4,0)
      end
    else
      softcut.level(target+4,params:get(target == 1 and "delay L: global level" or "delay R: global level"))
    end
  elseif param == "feedback mute" then
    delay[target].feedback_mute = not delay[target].feedback_mute
    if delay[target].feedback_mute then
      if params:get(target == 1 and "delay L: feedback" or "delay R: feedback") == 0 then
        softcut.pre_level(target+4,1)
      else
        softcut.pre_level(target+4,0)
      end
    else
      softcut.pre_level(target+4,params:get(target == 1 and "delay L: feedback" or "delay R: feedback")/100)
    end
  elseif param == "send mute" then
    delay[target].send_mute = not delay[target].send_mute
    if delay[target].send_mute then
      if target == 1 then
      end
      
    else
      
    end
  end
end

function delays.set_value(target,index,param)
  if param == "level" then
    local delay_name = {"delay L: global level", "delay R: global level"}
    local levels = {1,0.75,0.5,0.25,0}
    params:set(delay_name[target],levels[index])
  elseif param == "feedback" then
    local delay_name = {"delay L: feedback", "delay R: feedback"}
    local feedback_levels = {100,75,50,25,0}
    params:set(delay_name[target],feedback_levels[index])
  elseif param == "send" or param == "send all" then
    local send_levels = {1,0.75,0.5,0.25,0}
    local b = bank[delay_grid.bank][bank[delay_grid.bank].id]
    if target ==  1 then
      if param == "send" then
        b.left_delay_level = send_levels[index]
      else
        for i = 1,16 do
          bank[delay_grid.bank][i].left_delay_level = send_levels[index]
        end
      end
      softcut.level_cut_cut(delay_grid.bank+1,5,util.linlin(-1,1,0,1,b.pan)*(b.left_delay_level*b.level))
    else
      if param == "send" then
        b.right_delay_level = send_levels[index]
      else
        for i = 1,16 do
          bank[delay_grid.bank][i].right_delay_level = send_levels[index]
        end
      end
      softcut.level_cut_cut(delay_grid.bank+1,6,util.linlin(-1,1,1,0,b.pan)*(b.right_delay_level*b.level))
    end
  end
end

function delays.change_duration(target,source,param)
  if param == "sync" then
    local mode = {"delay L: mode","delay R: mode"}
    local div_mult = {"delay L: div/mult","delay R: div/mult"}
    local free_length = {"delay L: free length","delay R: free length"}
    params:set(mode[target], params:get(mode[source]))
    params:set(div_mult[target], params:get(div_mult[source]))
    params:set(free_length[target], params:get(free_length[source]))
  elseif param == "double" or param == "halve" then
    if delay[target].mode == "free" then
      local free_length = {"delay L: free length", "delay R: free length"}
      params:set(free_length[target], params:get(free_length[target])*(param == "double" and 2 or 0.5))
    end
  end
end

return delays