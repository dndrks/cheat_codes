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
  end

  delay_bundle = { {},{} }
  for i = 1,16 do
    delay_bundle[1][i] = {}
    delay_bundle[2][i] = {}
  end

  grid_delay = { {},{} }
  for i = 1,2 do
    grid_delay[i].held = 0
    grid_delay[i].assigned_to = 0
  end
end

function delays.build_bundle(target,slot)
  local b = delay_bundle[target][slot]
  local delay_name = target == 1 and "delay L: " or "delay R: "
  b.mode = params:get(delay_name.."mode")
  b.clocked_length = params:get(delay_name.."div/mult")
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
end

function delays.restore_bundle(target,slot)
  local b = delay_bundle[target][slot]
  local delay_name = target == 1 and "delay L: " or "delay R: "
  if b.mode ~= nil then
    params:set(delay_name.."mode", b.mode)
    params:set(delay_name.."div/mult", b.clocked_length)
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

return delays