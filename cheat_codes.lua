-- cheat codes
--          a sample playground
--
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
-- need help?
-- please see [?] menu
-- for in-app instruction manual
-- -------------------------------

local pattern_time = include 'lib/cc_pattern_time'
fileselect = require 'fileselect'
help_menus = include 'lib/help_menus'
main_menu = include 'lib/main_menu'
encoder_actions = include 'lib/encoder_actions'
arc_actions = include 'lib/arc_actions'
rightangleslice = include 'lib/zilchmos'
start_up = include 'lib/start_up'
grid_actions = include 'lib/grid_actions'
easingFunctions = include 'lib/easing'
math.randomseed(os.time())

tau = math.pi * 2
arc_param = {}
arc_switcher = {}
for i = 1,3 do
  arc_param[i] = 1
  arc_switcher[i] = 0
end
arc_control = {}
for i = 1,3 do
  arc_control[i] = i
end

arc_offset = 0 --IMPORTANT TO REVISIT

clip = {}
for i = 1,3 do
  clip[i] = {}
  clip[i].length = 90
  clip[i].sample_length = nil
  clip[i].start_point = nil
  clip[i].end_point = nil
  clip[i].mode = 1
end

help_menu = "welcome"

function f1()
  softcut.post_filter_lp(2,0)
  softcut.post_filter_hp(2,1)
  softcut.post_filter_fc(2,10)
  params:set("filter 1 cutoff",10)
end

function f2()
  softcut.post_filter_hp(2,0)
  softcut.post_filter_lp(2,1)
  softcut.post_filter_fc(2,12000)
  params:set("filter 1 cutoff",12000)
end

pattern_saver = {}
for i = 1,3 do
  pattern_saver[i] = metro.init()
  pattern_saver[i].time = 1
  pattern_saver[i].count = 1
  pattern_saver[i].event = function() test_save(i) end
  pattern_saver[i].source = i
  pattern_saver[i].save_slot = nil
  pattern_saver[i].load_slot = 0
  pattern_saver[i].saved = {}
  for j = 1,8 do
    pattern_saver[i].saved[j] = 0
  end
end

env_counter = {}
for i = 1,3 do
  env_counter[i] = metro.init()
  env_counter[i].time = 0.01
  env_counter[i].butt = 1
  env_counter[i].event = function() envelope(i) end
end

slew_counter = {}

for i = 1,3 do
  slew_counter[i] = metro.init()
  slew_counter[i].time = 0.01
  slew_counter[i].count = 100
  slew_counter[i].current = 0.00
  slew_counter[i].event = function() easing_slew(i) end
  slew_counter[i].ease = easingFunctions.inSine
  slew_counter[i].beginVal = 0
  slew_counter[i].endVal = 1
  slew_counter[i].change =  slew_counter[i].endVal - slew_counter[i].beginVal
  slew_counter[i].beginQ = 0
  slew_counter[i].endQ = 0
  slew_counter[i].changeQ = slew_counter[i].endQ - slew_counter[i].beginQ
  slew_counter[i].duration = (slew_counter[i].count/100)-0.01
  slew_counter[i].slewedVal = 0
  slew_counter[i].prev_tilt = 0
  slew_counter[i].next_tilt = 0
  slew_counter[i].prev_q = 0
  slew_counter[i].next_q = 0
end

quantize = 1
quantize_events = {}
for i = 1,3 do
  quantize_events[i] = {}
end

grid_pat_quantize = 1
grid_pat_quantize_events = {}
for i = 1,3 do
  grid_pat_quantize_events[i] = {}
end

--[[
grid_pat_quantizer = {}
for i = 1,3 do
  grid_pat_quantizer[i] = {}
  grid_pat_quantizer[i] = metro.init()
  grid_pat_quantizer[i].time = 0.25
  grid_pat_quantizer[i].count = -1
  --grid_pat_quantizer[i].event = function() grid_pat_q_clock(i) end
  grid_pat_quantizer[i].event = function() end
  grid_pat_quantizer[i]:start()
end
--]]

function cheat_clock_synced(i)
  if #quantize_events[i] > 0 then
    for k,e in pairs(quantize_events[i]) do
      cheat(i,e)
      grid_p[i] = {}
      grid_p[i].action = "pads"
      grid_p[i].i = i
      grid_p[i].id = selected[i].id
      grid_p[i].x = selected[i].x
      grid_p[i].y = selected[i].y
      grid_p[i].rate = bank[i][bank[i].id].rate
      grid_p[i].pause = bank[i][bank[i].id].pause
      grid_p[i].start_point = bank[i][bank[i].id].start_point
      grid_p[i].end_point = bank[i][bank[i].id].end_point
      grid_p[i].rate_adjusted = false
      grid_p[i].loop = bank[i][bank[i].id].loop
      grid_p[i].mode = bank[i][bank[i].id].mode
      grid_p[i].clip = bank[i][bank[i].id].clip
      grid_pat[i]:watch(grid_p[i])
    end
    quantize_events[i] = {}
  end
end

function set_pattern_mode(bank)
  grid_pat[bank].step = grid_pat[bank].start_point
  quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
  quantized_grid_pat[bank].sub_step = 1
  if grid_pat[bank].playmode == 1 then
    grid_pat[bank].quantize = 0
    grid_pat[bank].auto_snap = 0
    if grid_pat[bank].tightened_start == 1 then
      grid_pat[bank].tightened_start = 0
      grid_pat[bank]:start()
    end
  elseif grid_pat[bank].playmode == 2 then
    grid_pat[bank].quantize = 0
    grid_pat[bank].auto_snap = 1
    if grid_pat[bank].tightened_start == 1 then
      grid_pat[bank].tightened_start = 0
      grid_pat[bank]:start()
    end
  elseif grid_pat[bank].playmode == 3 then
    grid_pat[bank].quantize = 1
    grid_pat[bank].auto_snap = 0
    if grid_pat[bank].play == 1 then
      grid_pat[bank]:stop()
      grid_pat[bank].tightened_start = 1
    end
  elseif grid_pat[bank].playmode == 4 then
    grid_pat[bank].quantize = 1
    grid_pat[bank].auto_snap = 1
    if grid_pat[bank].play == 1 then
      grid_pat[bank]:stop()
      grid_pat[bank].tightened_start = 1
    end
  end
end

function how_many_bars(bank)
  local total_pattern_time = 0
  for i = 1,#grid_pat[bank].event do
    total_pattern_time = total_pattern_time + grid_pat[bank].time[i]
  end
  local time_per_bar = (60/bpm)*4
  local this_many_bars = math.floor((total_pattern_time/time_per_bar)+0.5)
  -- need at least ONE bar, so...
  if this_many_bars == 0 then this_many_bars = 1 end
  return this_many_bars
end

function better_grid_pat_q_clock(i)
  if grid_pat[i].rec == 1 then
    grid_pat[i]:rec_stop()
    midi_clock_linearize(i)
    grid_pat[i].loop = 1
    if grid_pat[i].count > 0 then
      grid_pat[i].tightened_start = 1
      if grid_pat[i].auto_snap == 1 then
        print("auto-snap")
        snap_to_bars(i,how_many_bars(i))
      end
    end
  elseif grid_pat[i].count == 0 then
    grid_pat[i]:rec_start()
  elseif grid_pat[i].play == 1 then
    grid_pat[i]:stop()
  elseif grid_pat[i].tightened_start == 1 then
    grid_pat[i].tightened_start = 0
    grid_pat[i].step = grid_pat[i].start_point
    quantized_grid_pat[i].current_step = grid_pat[i].start_point
    quantized_grid_pat[i].sub_step = 1
  else
    grid_pat[i].tightened_start = 1
  end
end

function snap_to_bars(bank,bar_count)
  if grid_pat[bank].rec == 0 and grid_pat[bank].count > 0 then 
    local total_time = 0
    for i = 1,#grid_pat[bank].event do
      total_time = total_time + grid_pat[bank].time[i]
    end
    print("before total: "..total_time)
    if old_pat_time == nil then
      old_pat_time = table.clone(grid_pat[bank].time)
    end
    local bar_time = (((60/bpm)*4)*bar_count)/total_time
    for k = 1,grid_pat[bank].count do
      grid_pat[bank].time[k] = grid_pat[bank].time[k] * bar_time
    end
    total_time = 0
    for i = 1,#grid_pat[bank].event do
      total_time = total_time + grid_pat[bank].time[i]
    end
    print("after total: "..total_time)
    snap_to_bars_midi(bank,bar_count)
  end
end

function random_grid_pat(which,mode)

  local pattern = grid_pat[which]
  
  if mode == 1 then
    for i = #pattern.time,2,-1 do
      local j = math.random(i)
      pattern.time[i], pattern.time[j] = pattern.time[j], pattern.time[i]
    end
  elseif mode == 2 then
    for i = #pattern.event,2,-1 do
      local j = math.random(i)
      local original, shuffled = pattern.event[i], pattern.event[j]
      original.id, shuffled.id = shuffled.id, original.id
      original.rate, shuffled.rate = shuffled.rate, original.rate
      original.loop, shuffled.loop = shuffled.loop, original.loop
      original.mode, shuffled.mode = shuffled.mode, original.mode
      original.pause, shuffled.pause = shuffled.pause, original.pause
      original.start_point, shuffled.start_point = shuffled.start_point, original.start_point
      original.clip, shuffled.clip = shuffled.clip, original.clip
      original.end_point = original.end_point
      original.rate_adjusted, shuffled.rate_adjusted = shuffled.rate_adjusted, original.rate_adjusted
      original.y, shuffled.y = shuffled.y, original.y
      original.x, shuffled.x = shuffled.x, original.x
      original.action, shuffled.action = shuffled.action, original.action
      original.i, shuffled.i = shuffled.i, original.i
      original.previous_rate, shuffled.previous_rate = shuffled.previous_rate, original.previous_rate
      original.row, shuffled.row = shuffled.row, original.row
      original.con, shuffled.con = shuffled.con, original.con
      original.bank, shuffled.bank = shuffled.bank, original.bank
    end
  elseif mode == 3 then
    if pattern.playmode == 3 or pattern.playmode == 4 then
      clock.sync(1/4)
    end
    local count = math.random(2,24)
    if pattern.count > 0 or pattern.rec == 1 then
      pattern:rec_stop()
      pattern:stop()
      pattern.tightened_start = 0
      pattern:clear()
      pattern_saver[which].load_slot = 0
    end
    for i = 1,count do
      pattern.event[i] = {}
      local constructed = pattern.event[i]
      constructed.id = math.random(1,16)
      local new_rates = 
      { [1] = math.pow(2,math.random(-3,-1))*((math.random(1,2)*2)-3)
      , [2] = math.pow(2,math.random(-1,1))*((math.random(1,2)*2)-3)
      , [3] = math.pow(2,math.random(1,2))*((math.random(1,2)*2)-3)
      , [4] = math.pow(2,math.random(-2,2))*((math.random(1,2)*2)-3)
      }
      constructed.rate = new_rates[pattern.random_pitch_range]
      local assigning_pad = bank[which][constructed.id]
      assigning_pad.rate = constructed.rate
      local new_levels = 
      { [0.125] = 1.75
      , [0.25]  = 1.5
      , [0.5]   = 1.25
      , [1.0]   = 1.0
      , [2.0]   = 0.75
      , [4.0]   = 0.5
      }
      assigning_pad.level = new_levels[math.abs(constructed.rate)]
      constructed.loop = assigning_pad.loop
      constructed.mode = assigning_pad.mode
      constructed.pause = assigning_pad.pause
      constructed.start_point = (math.random(10,75)/10)+(8*(assigning_pad.clip-1))
      constructed.clip = assigning_pad.clip
      constructed.end_point = constructed.start_point + (math.random(1,15)/10)
      constructed.rate_adjusted = false
      assigning_pad.fifth = false
      constructed.x = (5*(which-1)+1)+(math.ceil(constructed.id/4)-1)
      if (constructed.id % 4) ~= 0 then
        constructed.y = 9-(constructed.id % 4)
      else
        constructed.y = 5
      end
      constructed.action = "pads"
      constructed.i = which
      pattern.time[i] = (60/bpm) / math.pow(2,math.random(-2,2))
    end
    pattern.count = count
    pattern.start_point = 1
    pattern.end_point = count
  end
  midi_clock_linearize(which)
  if pattern.quantize == 0 then
    if pattern.auto_snap == 1 then
      print("auto-snap")
      snap_to_bars(which,how_many_bars(which))
    end
    pattern:start()
    pattern.loop = 1
  else
    pattern.loop = 1
    if pattern.count > 0 then
      pattern.tightened_start = 1
      if pattern.auto_snap == 1 then
        print("auto-snap")
        snap_to_bars(which,how_many_bars(which))
      end
    end
  end
end

function print_my_g_p_q(bank)
  for i = #quantized_grid_pat[bank].event,1,-1 do
    print(i)
    tab.print(quantized_grid_pat[bank].event[i])
  end
end

function snap_to_bars_midi(bank,bar_count)
  local entry_count = 0
  local target_entry_count = bar_count*16
  for i = 1,#quantized_grid_pat[bank].event do
    entry_count = entry_count + #quantized_grid_pat[bank].event[i]
  end
  print("before trimming midi event count: "..entry_count)
  if entry_count < target_entry_count then
    for i = 1,target_entry_count-entry_count do
      table.insert(quantized_grid_pat[bank].event[#quantized_grid_pat[bank].event],"nothing")
    end
  elseif entry_count > target_entry_count then
    --print("subtracting...")
    local last_event = #quantized_grid_pat[bank].event
    local last_group = #quantized_grid_pat[bank].event
    --print("last event: "..last_event)
    local distance_count = entry_count - target_entry_count
    print("removing "..distance_count.." event")
    local current_count = 0
    
    while current_count < distance_count do
      if last_group > 0 then
        if #quantized_grid_pat[bank].event[last_group] > 1 and quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]] == "nothing" then
          local check_table = #quantized_grid_pat[bank].event
          --print("removing: "..quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]].." from group "..last_group..", entry "..#quantized_grid_pat[bank].event[last_group])
          table.remove(quantized_grid_pat[bank].event[last_group])
          current_count = current_count + 1
          if current_count == distance_count then print("done now!") break end
          --print("current count :" .. current_count)
        elseif #quantized_grid_pat[bank].event[last_group] == 1 and quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]] == "something" then
          --print("skipping: "..quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]].." from group "..last_group..", entry "..#quantized_grid_pat[bank].event[last_group])
          last_group = last_group - 1
        elseif #quantized_grid_pat[bank].event[last_group] == 1 and quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]] == "nothing" then
          --print("there's only nothing in group "..last_group..", but removing it")
          table.remove(quantized_grid_pat[bank].event[last_group])
          --print_my_g_p_q(1)
          current_count = current_count + 1
          if current_count == distance_count then print("done now!") break end
          --print("current count :" .. current_count)
          last_group = last_group - 1
        elseif quantized_grid_pat[bank].event[last_group][#quantized_grid_pat[bank].event[last_group]] == nil then
          --print("A NIL IN"..last_group)
          table.remove(quantized_grid_pat[bank].event,last_group)
          last_group = last_group - 1
          --break
        end
      elseif last_group == 0 then
        --print("still got some left!!!: "..current_count.." / "..distance_count)
        table.remove(quantized_grid_pat[bank].event)
        current_count = current_count + 1
      end
    end
    quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
    quantized_grid_pat[bank].sub_step = 1
  end
  
  local entry_count = 0
  for i = 1,#quantized_grid_pat[bank].event do
    entry_count = entry_count + #quantized_grid_pat[bank].event[i]
  end
  print("after trimming midi event count: "..entry_count)
  if entry_count ~= target_entry_count then
    --doubletap? is this ok??
    snap_to_bars_midi(bank,bar_count)
  end
end

function save_external_timing(bank,slot)
  
  local dirname = _path.data.."cheat_codes/external-timing/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  
  local file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..selected_coll.."_"..slot.."_external-timing.data", "w+")
  io.output(file)
  io.write("external clock timing for stored pad pattern: collection "..selected_coll.." + slot "..slot.."\n")
  local total_entry_count = 0
  local number_of_events = #quantized_grid_pat[bank].event
  for i = 1,number_of_events do
    total_entry_count = total_entry_count + #quantized_grid_pat[bank].event[i]
  end
  io.write(total_entry_count.."\n")
  io.write(number_of_events.."\n")
  for i = 1,number_of_events do
    io.write("event: "..i.."\n")
    io.write("total entries: "..#quantized_grid_pat[bank].event[i].."\n")
    for j = 1,#quantized_grid_pat[bank].event[i] do
      io.write(quantized_grid_pat[bank].event[i][j].."\n")
    end
  end
  io.close(file)
  print("saved external timing for pattern "..bank.." to slot "..slot)
end

function load_external_timing(bank,slot)
  local file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..selected_coll.."_"..slot.."_external-timing.data", "r")
  if file then
    io.input(file)
    if io.read() == "external clock timing for stored pad pattern: collection "..selected_coll.." + slot "..slot then
      quantized_grid_pat[bank].event = {}
      local total_entry_count = tonumber(io.read())
      local number_of_events = tonumber(io.read())
      for i = 1,number_of_events do
        local event_id = tonumber(string.match(io.read(), '%d+'))
        local entry_count = tonumber(string.match(io.read(), '%d+'))
        quantized_grid_pat[bank].event[i] = {}
        for j = 1,entry_count do
          quantized_grid_pat[bank].event[i][j] = io.read()
        end
      end
    end
    io.close(file)
  else
    print("creating external timing file...")
    midi_clock_linearize(bank)
    save_external_timing(bank,slot)
  end
end

function copy_entire_pattern(bank)
  original_pattern = {}
  original_pattern[bank] = {}
  original_pattern[bank].time = table.clone(grid_pat[bank].time)
  original_pattern[bank].event = {}
  for i = 1,#grid_pat[bank].event do
    original_pattern[bank].event[i] = {}
    for k,v in pairs(grid_pat[bank].event[i]) do
      original_pattern[bank].event[i][k] = v
    end
  end
  original_pattern[bank].metro = {}
  original_pattern[bank].metro.props = {}
  original_pattern[bank].metro.props.time = grid_pat[bank].metro.props.time
  original_pattern[bank].prev_time = grid_pat[bank].prev_time
  original_pattern[bank].count = grid_pat[bank].count
  original_pattern[bank].start_point = grid_pat[bank].start_point
  original_pattern[bank].end_point = grid_pat[bank].end_point
  if grid_pat[bank].playmode ~= nil then
    original_pattern[bank].playmode = grid_pat[bank].playmode
  else
    original_pattern[bank].playmode = 1
  end
end

function update_pattern_bpm(bank)
  grid_pat[bank].time_factor = 1*(synced_to_bpm/bpm)
end

function table.clone(org)
  return {table.unpack(org)}
end

function midi_clock_linearize(bank)
  quantized_grid_pat[bank].event = {}
  for i = 1,grid_pat[bank].count do
    quantized_grid_pat[bank].clicks[i] = math.floor((grid_pat[bank].time[i] / ((60/bpm)/4))+0.5)
    quantized_grid_pat[bank].event[i] = {} -- critical
    if grid_pat[bank].time[i] == 0 or quantized_grid_pat[bank].clicks[i] == 0 then
      quantized_grid_pat[bank].event[i][1] = "nothing"
    else
      for j = 1,quantized_grid_pat[bank].clicks[i] do
        if j == 1 then
          quantized_grid_pat[bank].event[i][1] = "something"
        else
          quantized_grid_pat[bank].event[i][j] = "nothing"
        end
      end
    end
  end
  quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
  quantized_grid_pat[bank].sub_step = 1
end

key1_hold = false

grid.alt = 0
grid.alt_pp = 0
grid.loop_mod = 0

local function crow_flush()
  crow.reset()
  crow.clear()
end

local function crow_init()
  for i = 1,4 do
    crow.output[i].action = "{to(5,0),to(0,0.05)}"
    print("output["..i.."] initialized")
  end
  crow.input[2].mode("change",2,0.1,"rising")
  crow.input[2].change = buff_freeze
end

local lit = {}

function init()
  
  grid_p = {}
  arc_p = {}
  
  rec = {}
  rec.state = 1
  rec.clip = 1
  rec.start_point = 1
  rec.end_point = 9
  rec.loop = 1
  rec.clear = 0
  
  params:add_separator("cheat codes params")
  
  params:add_group("collections",4)
  
  params:add_number("collection", "collection", 1,100,1)
  params:add{type = "trigger", id = "load", name = "load", action = loadstate}
  params:add_option("collect_live","collect Live buffers?",{"no","yes"})
  params:add{type = "trigger", id = "save", name = "save", action = savestate}
  
  menu = 1
  
  for i = 1,4 do
    crow.output[i].action = "{to(5,0),to(0,0.05)}"
  end
  crow.count = {}
  crow.count_execute = {}
  for i = 1,3 do
    crow.count[i] = 1
    crow.count_execute[i] = 1
  end

  screen.line_width(1)

  local etap = 0
  local edelta = 1
  local prebpm = 110
  
  clock_counting = 0
  
  grid_pat = {}
  for i = 1,3 do
    grid_pat[i] = pattern_time.new()
    grid_pat[i].process = grid_pattern_execute
    grid_pat[i].tightened_start = 0
    grid_pat[i].auto_snap = 0
    grid_pat[i].quantize = 0
    grid_pat[i].playmode = 1
    grid_pat[i].random_pitch_range = 4
  end
  
  quantized_grid_pat = {}
  for i = 1,3 do
    quantized_grid_pat[i] = {}
    quantized_grid_pat[i].clicks = {}
    quantized_grid_pat[i].event = {}
    quantized_grid_pat[i].sub_step = 1
    quantized_grid_pat[i].current_step = grid_pat[i].start_point
  end
  
  step_seq = {}
  for i = 1,3 do
    step_seq[i] = {}
    step_seq[i].active = 1
    step_seq[i].current_step = 1
    step_seq[i].current_pat = nil
    step_seq[i].rate = 1
    step_seq[i].start_point = 1
    step_seq[i].end_point = 16
    step_seq[i].length = (step_seq[i].end_point - step_seq[i].start_point) + 1
    step_seq[i].meta_step = 1
    step_seq[i].meta_duration = 1
    step_seq[i].meta_meta_step = 1
    step_seq[i].held = 0
    for j = 1,16 do
      step_seq[i][j] = {}
      step_seq[i][j].meta_meta_duration = 4
      step_seq[i][j].assigned = 0 --necessary?
      step_seq[i][j].assigned_to = 0
      step_seq[i][j].loop_pattern = 1
    end
    step_seq[i].meta_meta_duration = 4
    step_seq[i].loop_held = 0
  end
  
  function internal_clocking_tightened(bank)
    local current = quantized_grid_pat[bank].current_step
    local sub_step = quantized_grid_pat[bank].sub_step
    if current == 0 then
      current = grid_pat[bank].start_point
    end
    if grid_pat[bank].tightened_start == 1 and grid_pat[bank].count > 0 then
      if quantized_grid_pat[bank].event[current][sub_step] == "something" then
        --print(current, sub_step, "+++")
        if grid_pat[bank].step == 0 then
          grid_pat[bank].step = grid_pat[bank].start_point
        end
        if quantized_grid_pat[bank].current_step == 0 then
          quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
        end
        grid_pattern_execute(grid_pat[bank].event[quantized_grid_pat[bank].current_step])
      elseif quantized_grid_pat[bank].event[current][sub_step] == "nothing" then
        -- nothing!
        if grid_pat[bank].step == 0 then
          grid_pat[bank].step = grid_pat[bank].start_point
        end
        if quantized_grid_pat[bank].current_step == 0 then
          print("if you see this message, tell dan!")
          quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
        end
      elseif quantized_grid_pat[bank].event[current][sub_step] == nil and #quantized_grid_pat[bank].event == grid_pat[bank].end_point then
        print(current.." is nil!")
        table.remove(quantized_grid_pat[bank].event,current)
        grid_pat[bank].end_point = grid_pat[bank].end_point - 1
        quantized_grid_pat[bank].current_step = quantized_grid_pat[bank].current_step + 1
        quantized_grid_pat[bank].sub_step = 1
      end
      --increase sub_step now
      --if quantized_grid_pat[bank].current_step > #quantized_grid_pat[bank].event or quantized_grid_pat[bank].current_step > #grid_pat[bank].event then
      if quantized_grid_pat[bank].current_step > grid_pat[bank].end_point then
        quantized_grid_pat[bank].current_step = grid_pat[bank].start_point
      end
      if quantized_grid_pat[bank].sub_step == #quantized_grid_pat[bank].event[quantized_grid_pat[bank].current_step] then
        quantized_grid_pat[bank].sub_step = 0
        --if we're at the end of the events in this step, move to the next step
        if grid_pat[bank].step == grid_pat[bank].end_point then
          grid_pat[bank].step = 0
          --quantized_grid_pat[bank].current_step = 0
        end
        --if quantized_grid_pat[bank].current_step == #quantized_grid_pat[bank].event then
        if quantized_grid_pat[bank].current_step == grid_pat[bank].end_point then
          quantized_grid_pat[bank].current_step = grid_pat[bank].start_point - 1
        end
        grid_pat[bank].step = grid_pat[bank].step + 1
        quantized_grid_pat[bank].current_step = quantized_grid_pat[bank].current_step +1
        --quantized_grid_pat[bank].current_step = quantized_grid_pat[bank].current_step + 1
      end
      quantized_grid_pat[bank].sub_step = quantized_grid_pat[bank].sub_step + 1
    end
  end

  params:add_number("bpm", "bpm", 1, 480,80)
  params:hide(51)
  
  params:add_group("hidden [timing]",6)
  params:hide(52)
  params:add_option("quantize_pads", "(see [timing] menu)", { "no", "yes" })
  params:set_action("quantize_pads", function(x) quantize = x-1 end)
  params:add_option("quantize_pats", "(see [timing] menu)", { "no", "yes" })
  params:set_action("quantize_pats", function(x)
    grid_pat_quantize = x-1
    for i = 1,3 do
      grid_pat[i].quantize = x-1
    end
  end)
  params:add_number("quant_div", "(see [timing] menu)", 1, 5, 4)
  params:set_action("quant_div",function() update_tempo() end)
  params:add_number("quant_div_pats", "(see [timing] menu)", 1, 5, 4)
  params:set_action("quant_div_pats",function() update_tempo() end)
  params:add_option("lock_pat", "(see [timing] menu)", {"no", "yes"} )
  params:add{type = "trigger", id = "sync_pat", name = "(see [timing] menu)"}

  params:default()
  
  grid_page = 0
  
  page = {}
  page.main_sel = 1
  page.loops_sel = 0
  page.levels_sel = 0
  page.panning_sel = 1
  page.filtering_sel = 0
  page.arc_sel = 0
  page.delay_sel = 0
  page.time_sel = 1
  page.time_page = {}
  page.time_page_sel = {}
  page.time_scroll = {}
  for i = 1,5 do
    page.time_page[i] = 1
    page.time_page_sel[i] = 1
    page.time_scroll[i] = 1
  end
  
  delay_rates = {2,(7/4),(5/3),(3/2),(4/3),(5/4),(1),(4/5),(3/4),(2/3),(3/5),(4/7),(1/2)}
  delay = {}
  for i = 1,2 do
    delay[i] = {}
    delay[i].id = 7
    delay[i].arc_rate_tracker = 7
    delay[i].arc_rate = 7
    delay[i].rate = delay_rates[7]
    delay[i].start_point = 41 + (30*(i-1))
    delay[i].end_point = delay[i].start_point + 0.5
    delay[i].divisor = 1
  end
  
  index = 0
  
  edit = "all"
  
  start_up.init()
    
  params:add_group("crow utils",2)
  
  params:add{type = "trigger", id = "init_crow", name = "initialize crow", action = crow_init}
  params:add{type = "trigger", id = "clear_crow", name = "(reset/clear crow)", action = crow_flush}

  bank = {}
  reset_all_banks(bank)
  
  params:bang()
  
  selected_coll = 0
  
  --GRID
  selected = {}
  fingers = {}
  counter_four = {}
  counter_three = {}
  counter_two = {}
  for i = 1,3 do
    selected[i] = {}
    selected[i].x = 1 + (5*(i-1))
    selected[i].y = 8
    selected[i].id = 1
    for k = 1,4 do
      fingers[k] = {}
      fingers[k].dt = 1
      fingers[k].t1 = 0
      fingers[k].t = 0
      fingers[k][i] = {}
      fingers[k][i].con = {}
    end
  end

  function record_the_zilchmo(prev,sel,row)
    grid_p[sel] = {}
    grid_p[sel].i = sel
    grid_p[sel].action = "zilchmo"
    grid_p[sel].con = fingers[row][sel].con
    grid_p[sel].row = row
    grid_p[sel].bank = sel
    grid_p[sel].id = selected[sel].id
    grid_p[sel].x = selected[sel].x
    grid_p[sel].y = selected[sel].y
    grid_p[sel].previous_rate = prev
    grid_p[sel].rate = prev
    grid_p[sel].start_point = bank[sel][bank[sel].id].start_point
    grid_p[sel].end_point = bank[sel][bank[sel].id].end_point
    grid_pat[sel]:watch(grid_p[sel])
  end

  counter_four.key_up = metro.init()
  counter_four.key_up.time = 0.05
  counter_four.key_up.count = 1
  counter_four.key_up.event = function()
    local previous_rate = bank[selected_zilchmo_bank][bank[selected_zilchmo_bank].id].rate
    zilchmo(4,selected_zilchmo_bank)
    record_the_zilchmo(previous_rate,selected_zilchmo_bank,4)
  end
  counter_four.key_up:stop()
  counter_three = {}
  counter_three.key_up = metro.init()
  counter_three.key_up.time = 0.05
  counter_three.key_up.count = 1
  counter_three.key_up.event = function()
    zilchmo(3,selected_zilchmo_bank)
  end
  counter_three.key_up:stop()
  counter_two = {}
  counter_two.key_up = metro.init()
  counter_two.key_up.time = 0.05
  counter_two.key_up.count = 1
  counter_two.key_up.event = function()
    zilchmo(2,selected_zilchmo_bank)
  end
  counter_two.key_up:stop()
  
  quantized_grid_pat = {}
  for i = 1,3 do
    quantized_grid_pat[i] = {}
    quantized_grid_pat[i].clicks = {}
    quantized_grid_pat[i].event = {}
    quantized_grid_pat[i].sub_step = 1
    quantized_grid_pat[i].current_step = 1
  end
  
  arc_pat = {}
  for i = 1,3 do
    arc_pat[i] = pattern_time.new()
    if i ~=4 then
      arc_pat[i].process = arc_pattern_execute
    else
      arc_pat[i].process = arc_delay_pattern_execute
    end
  end
  
  if g then grid_redraw() end
  --/GRID
  for i=1,3 do
    cheat(i,bank[i].id)
  end
  
  hardware_redraw = metro.init(function() grid_redraw() arc_redraw() end, 0.02, -1)
  hardware_redraw:start()
  
  softcut.poll_start_phase()
  
  filter_types = {"lp", "hp", "bp", "lp/hp"}
  
  rec_state_watcher = metro.init()
  rec_state_watcher.time = 0.25
  rec_state_watcher.event = function()
    if rec.loop == 0 then
      if rec.state == 1 then
        if rec.end_point < poll_position_new[1] +0.015 then
          rec.state = 0
          rec_state_watcher:stop()
        end
      end
    end
  end
  rec_state_watcher.count = -1
  rec_state_watcher:start()
  
  already_saved()
  
  params:add_group("OSC setup",3)
  params:add_text("osc_IP", "OSC IP", "192.168.")
  params:set_action("osc_IP", function() dest = {tostring(params:get("osc_IP")), tonumber(params:get("osc_port"))} end)
  params:add_text("osc_port", "OSC port", "9000")
  params:set_action("osc_port", function() dest = {tostring(params:get("osc_IP")), tonumber(params:get("osc_port"))} end)
  params:add{type = "trigger", id = "refresh_osc", name = "refresh OSC [K3]", action = function()
    params:set("osc_IP","none")
    params:set("osc_port","none")
    osc_communication = false
  end}

  crow_init()
  
  task_id = clock.run(globally_clocked)
  pad_press_quant = clock.run(pad_clock)
  
  if params:string("clock_source") == "internal" then
    clock.internal.start(bpm)
  end

end

function pad_clock()
  while true do
    clock.sync(1)
    for i = 1,3 do
      cheat_clock_synced(i)
    end
  end
end

function globally_clocked()
  while true do
    clock.sync(1/4)
    if menu == 7 then
      redraw()
    end
    grid_redraw()
    update_tempo()
    step_sequence()
    for i = 1,3 do
      if grid_pat[i].led == nil then grid_pat[i].led = 0 end
      if grid_pat[i].rec == 1 then
        local blink = math.fmod(clock.get_beats(),1)
        if blink <= 0.25 then
          blink = 1
        elseif blink <= 0.5 then
          blink = 2
        elseif blink <= 0.75 then
          blink = 3
        else
          blink = 4
        end
        if blink == 1 then
          grid_pat[i].led = 1
        else
          grid_pat[i].led = 0
        end
      end
    end
    for i = 1,3 do
      if grid_pat[i].tightened_start == 1 then
        internal_clocking_tightened(i)
      end
    end
  end
end

local osc_send = {}

function osc_send.pad_sel( state , bank , pad )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
  osc.send(dest, "/pad_sel_"..bank.."_"..pad, {state})
  end
end

function osc_send.rate_adjustment( state , bank , pad )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/rate_"..bank.."_"..pad, {state})
  end
end

function osc_send.rate_led( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/rate_"..bank, {state})
  end
end

function osc_send.rate_rev_led( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/rate_rev_"..bank,{state})
  end
end

function osc_send.loop_single_pad( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/pad_loop_single_"..bank, {state})
  end
end

function osc_send.start_point_display( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/pad_start_display_"..bank, {state})
  end
end

function osc_send.end_point_display( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/pad_end_display_"..bank, {state})
  end
end

function osc_send.start_pattern( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/start_pat_"..bank, {state})
  end
end

function osc_send.pad_start( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/pad_start_"..bank, {state})
  end
end

function osc_send.pad_end( state , bank )
  if grid_pat[bank].play == 0 and grid_pat[bank].tightened_start == 0 then
    osc.send(dest, "/pad_end_"..bank, {state})
  end
end

function osc_send.buffer_led( state , bank )
  osc.send(dest, "/buffer_LED_"..bank, {state})
end

function osc_send.buffer_state( state )
  osc.send(dest, "/buffer_state", {state})
end

osc_in = function(path, args, from)
  if osc_communication ~= true then
    params:set("osc_IP",from[1])
    params:set("osc_port",from[2])
    osc_communication = true
  end
  for i = 1,3 do
    if path == "/pad_sel_"..i then
      if args[1] ~= 0 then
        bank[i].id = util.round(args[1])
        cheat(i,bank[i].id)
        redraw()
        osc_redraw(i)
      end
    elseif path == "/rate_"..i then
      for j = 7,12 do
        osc_send.rate_adjustment( 0 , i , j )
      end
      if params:get("rate "..i) > 6 then
        params:set("rate "..i, util.round(args[1]))
        osc_send.rate_adjustment( 1 , i , params:get("rate "..i) )
      else
        params:set("rate "..i, math.abs(util.round(args[1])-13))
        osc_send.rate_adjustment( 1 , i , math.abs(params:get("rate "..i)-13) )
      end
      osc_send.rate_led( params:get("rate "..i) , i )
    elseif path == "/rate_rev_"..i then
      params:set("rate "..i, math.abs(params:get("rate "..i)-13))
    elseif path == "/pad_loop_single_"..i then
      if args[1] == 1 then
        bank[i][bank[i].id].loop = true
        softcut.loop(i+1,1)
      elseif args[1] == 0 then
        bank[i][bank[i].id].loop = false
        softcut.loop(i+1,0)
      end
    elseif path == "/pad_loop_all_"..i then
      if args[1] == 1 then
        for j = 1,16 do
          bank[i][j].loop = true
        end
      elseif args[1] == 0 then
        for j = 1,16 do
          bank[i][j].loop = false
        end
      end
      softcut.loop(i+1,bank[i][bank[i].id].loop == true and 1 or 0)
      local loop_to_osc = nil
      if bank[i][bank[i].id].loop == false then
        loop_to_osc = 0
      else
        loop_to_osc = 1
      end
      osc_send.loop_single_pad( loop_to_osc , i )
    elseif path == "/pad_start_"..i then
      params:set("start point "..i, util.round(args[1]))
      osc_send.start_point_display( tonumber(string.format("%.2f",bank[i][bank[i].id].start_point - (8*(bank[i][bank[i].id].clip-1)))) , i )
    elseif path == "/pad_end_"..i then
      params:set("end point "..i, util.round(args[1]))
      osc_send.end_point_display( tonumber(string.format("%.2f",bank[i][bank[i].id].end_point - (8*(bank[i][bank[i].id].clip-1)))) , i )
    elseif path == "/pad_window_"..i then
      local current_difference = (bank[i][bank[i].id].end_point - bank[i][bank[i].id].start_point)
      if bank[i][bank[i].id].start_point + current_difference <= (9+(8*(bank[i][bank[i].id].clip-1))) then
        bank[i][bank[i].id].start_point = util.clamp(bank[i][bank[i].id].start_point + args[1]/25,(1+(8*(bank[i][bank[i].id].clip-1))),(9+(8*(bank[i][bank[i].id].clip-1))))
        bank[i][bank[i].id].end_point = bank[i][bank[i].id].start_point + current_difference
      else
        bank[i][bank[i].id].end_point = (9+(8*(bank[i][bank[i].id].clip-1)))
        bank[i][bank[i].id].start_point = bank[i][bank[i].id].end_point - current_difference
      end
      softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
      softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      osc_send.pad_start( (bank[i][bank[i].id].start_point*100)-((8*(bank[i][bank[i].id].clip-1))) , i )
      osc_send.start_point_display( tonumber(string.format("%.2f",(bank[i][bank[i].id].start_point) - (8*(bank[i][bank[i].id].clip-1)))) , i )
      osc_send.pad_end( (bank[i][bank[i].id].end_point*100)-((8*(bank[i][bank[i].id].clip-1))*100) , i )
      osc_send.end_point_display( tonumber(string.format("%.2f",bank[i][bank[i].id].end_point - (8*(bank[i][bank[i].id].clip-1)))) , i )
    elseif path == "/rand_pat_"..i then
      random_grid_pat(i,3)
    elseif path == "/stop_pat_"..i then
      if grid_pat[i].play == 1 then
        grid_pat[i]:stop()
      elseif grid_pat[i].tightened_start == 1 then
        grid_pat[i].tightened_start = 0
        grid_pat[i].step = grid_pat[i].start_point
        quantized_grid_pat[i].current_step = grid_pat[i].start_point
        quantized_grid_pat[i].sub_step = 1
      end
    elseif path == "/start_pat_"..i then
      if grid_pat[i].quantize == 0 then
        if grid_pat[i].play == 0 then
          grid_pat[i]:start()
          osc_send.start_pattern( 1 , i )
        else
          grid_pat[i]:stop()
          osc_send.start_pattern( 0 , i )
        end
      else
        better_grid_pat_q_clock(i)
      end
    elseif path == "/pad_loop_slice_"..i then
      local bpm_to_sixteenth = (60/bpm)/4
      bank[i][bank[i].id].end_point = bank[i][bank[i].id].start_point + bpm_to_sixteenth
      softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      osc_redraw(i)
    elseif path == "/pad_loop_double_"..i then
      local which_pad = bank[i].id
      local double = (bank[i][which_pad].end_point - bank[i][which_pad].start_point)*2
      local maximum_val = 9+(8*(bank[i][which_pad].clip-1))
      local minimum_val = 1+(8*(bank[i][which_pad].clip-1))
      if bank[i][which_pad].start_point - double >= minimum_val then
        bank[i][which_pad].start_point = bank[i][which_pad].end_point - double
      elseif bank[i][which_pad].start_point - double < minimum_val then
        if bank[i][which_pad].end_point + double < maximum_val then
          bank[i][which_pad].end_point = bank[i][which_pad].end_point + double
        end
      end
      softcut.loop_start(i+1,bank[i][which_pad].start_point)
      softcut.loop_end(i+1,bank[i][which_pad].end_point)
      osc_redraw(i)
    elseif path == "/pad_loop_halve_"..i then
      local which_pad = bank[i].id
      local halve = ((bank[i][which_pad].end_point - bank[i][which_pad].start_point)/2)/2
      bank[i][which_pad].start_point = bank[i][which_pad].start_point + halve
      bank[i][which_pad].end_point = bank[i][which_pad].end_point - halve
      softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
      softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      osc_redraw(i)
    elseif path == "/pad_loop_rand_"..i then
      bank[i][bank[i].id].start_point = (math.random(10,75)/10)+(8*(bank[i][bank[i].id].clip-1))
      bank[i][bank[i].id].end_point = bank[i][bank[i].id].start_point + (math.random(1,15)/10)
      softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
      softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      osc_redraw(i)
    elseif path == "/rec_clip_"..i then
      softcut.level_slew_time(1,0.5)
      softcut.fade_time(1,0.01)
      local old_clip = rec.clip
        
      for go = 1,2 do
        local old_min = (1+(8*(rec.clip-1)))
        local old_max = (9+(8*(rec.clip-1)))
        local old_range = old_min - old_max
        rec.clip = i
        local new_min = (1+(8*(rec.clip-1)))
        local new_max = (9+(8*(rec.clip-1)))
        local new_range = new_max - new_min
        local current_difference = (rec.end_point - rec.start_point)
        rec.start_point = (((rec.start_point - old_min) * new_range) / old_range) + new_min
        rec.end_point = rec.start_point + current_difference
      end
      
      for j = 1,3 do
        if j ~= i then
          osc_send.buffer_led( 0 , j )
        end
      end
      
      osc_send.buffer_led( 1 , i )
        
      if rec.loop == 0 and grid.alt == 0 then
        softcut.position(1,rec.start_point)
        if rec.state == 0 then
          rec.state = 1
          softcut.rec_level(1,1)
          rec_state_watcher:start()
          end
      if rec.clear == 1 then rec.clear = 0 end
      end
        
      softcut.loop_start(1,rec.start_point)
      softcut.loop_end(1,rec.end_point-0.01)
      if rec.loop == 1 then
        if old_clip ~= rec.clip then rec.state = 0 end
        buff_freeze()
        if rec.clear == 1 then
          rec.clear = 0
        end
      end
      
      local rec_state_to_osc = nil
      if rec.state == 0 then
        rec_state_to_osc = "not recording"
      else
        rec_state_to_osc = "recording"
      end
      osc_send.buffer_state( rec_state_to_osc )

    end
  end
end



function osc_redraw(i)
  if grid_pat[i].play == 0 then
    local loop_to_osc = nil
    if bank[i][bank[i].id].loop == false then
      loop_to_osc = 0
    else
      loop_to_osc = 1
    end
    osc_send.loop_single_pad( loop_to_osc , i )
    osc_send.rate_led( params:get("rate "..i) , i)
    for j = 7,12 do
      osc_send.rate_adjustment( 0 , i , j )
    end
    if params:get("rate "..i) > 6 then
      osc_send.rate_adjustment( 1 , i , params:get("rate "..i) )
      osc_send.rate_rev_led( 0 , i )
    else
      osc_send.rate_adjustment( 1 , i , math.abs(params:get("rate "..i)-13) )
      osc_send.rate_rev_led( 1 , i )
    end
    osc_send.pad_start( (bank[i][bank[i].id].start_point*100)-((8*(bank[i][bank[i].id].clip-1))) , i )
    osc_send.start_point_display( tonumber(string.format("%.2f",(bank[i][bank[i].id].start_point) - (8*(bank[i][bank[i].id].clip-1)))) , i )
    osc_send.pad_end( (bank[i][bank[i].id].end_point*100)-((8*(bank[i][bank[i].id].clip-1))*100) , i )
    osc_send.end_point_display( tonumber(string.format("%.2f",bank[i][bank[i].id].end_point - (8*(bank[i][bank[i].id].clip-1)))) , i )
    for j = 1,16 do
      osc_send.pad_sel( 0 , i , j )
    end
    osc_send.pad_sel( 1 , i , bank[i].id )
    local rec_state_to_osc = nil
    if rec.state == 0 then
      rec_state_to_osc = "not recording"
    else
      rec_state_to_osc = "recording"
    end
    osc_send.buffer_state( rec_state_to_osc )
    for j = 1,3 do
      if rec.clip ~= j then
        osc_send.buffer_led( 0 , j )
      else
        osc_send.buffer_led( 1 , rec.clip )
      end
    end
  end
end

poll_position_new = {}

phase = function(n, x)
  poll_position_new[n] = x
  if menu == 2 then
    redraw()
  end
end

local tap = 0
local deltatap = 1

function update_tempo()

  params:set("bpm", util.round(clock.get_tempo()))
  bpm = params:get("bpm") -- FIXME this is where the global bpm is defined
  local t = params:get("bpm")
  local d = params:get("quant_div")
  local d_pat = params:get("quant_div_pats")
  local interval = (60/t) / d
  local interval_pats = (60/t) / d_pat
  for i = 1,3 do
    --quantizer[i].time = interval
    --grid_pat_quantizer[i].time = interval_pats
  end
end

function rec_count()
  rec_time = rec_time + 0.01
end

function step_sequence()
  for i = 1,3 do
    if step_seq[i].active == 1 then
      step_seq[i].meta_step = step_seq[i].meta_step + 1
      if step_seq[i].meta_step > step_seq[i].meta_duration then step_seq[i].meta_step = 1 end
      if step_seq[i].meta_step == 1 then
        step_seq[i].meta_meta_step = step_seq[i].meta_meta_step + 1
        if step_seq[i].meta_meta_step > step_seq[i][step_seq[i].current_step].meta_meta_duration then step_seq[i].meta_meta_step = 1 end
        if step_seq[i].meta_meta_step == 1 then
          step_seq[i].current_step = step_seq[i].current_step + 1
          if step_seq[i].current_step > step_seq[i].end_point then step_seq[i].current_step = step_seq[i].start_point end
          current = step_seq[i].current_step
          if grid_pat[i].rec == 0 and step_seq[i][current].assigned_to ~= 0 then
            pattern_saver[i].load_slot = step_seq[i][current].assigned_to
            test_load(step_seq[i][current].assigned_to+((i-1)*8),i)
            grid_pat[i].loop = step_seq[i][current].loop_pattern
          end
        end
      end
    end
  end
end

function reset_all_banks( banks )
  cross_filter = {} -- TODO put into the banks
  for i = 1,3 do
    banks[i] = {}
    local b = banks[i] -- alias
    b.id = 1 -- currently playing pad_id
    b.ext_clock = 1
    b.focus_hold = false
    b.focus_pad = 1
    b.random_mode = 3
    b.crow_execute = 1
    b.snap_to_bars = 1
    b.quantize_press = 0
    b.quantize_press_div = 1
    for k = 1,16 do
-- TODO suggest nesting tables for delay,filter,tilt etc
      b[k] = {}
      local pad = b[k] --alias
      pad.bank_id           = i -- capture which bank we're in
      pad.pad_id            = k -- capture which pad of 16
      pad.clip              = 1 -- TODO make this a table with length for start/end calculation
      pad.mode              = 1
        -- TODO these are both identical to zilchmos.start_end_default()
      pad.start_point       = 1+((8/16) * (pad.pad_id-1))
      pad.end_point         = 1+((8/16) *  pad.pad_id)
      pad.sample_end        = 8
      pad.rate              = 1.0
      pad.left_delay_time   = 0.5 -- [delay] controls these
      pad.right_delay_time  = 0.5 -- [delay] controls these
      pad.pause             = false
      pad.play_mode         = "latch"
      pad.level             = 1.0
      pad.left_delay_level  = 1
      pad.right_delay_level = 1
      pad.loop              = true
      pad.fifth             = false
      pad.pan               = 0.0
      -- FIXME these are both just 0.5. why compute them? could instead call that fn?
      pad.left_delay_pan    = util.linlin(-1,1,0,1,pad.pan) * pad.left_delay_level
      pad.right_delay_pan   = util.linlin(-1,1,1,0,pad.pan) * pad.right_delay_level
      pad.fc                = 12000
      pad.q                 = 2.0
      pad.lp                = 1.0
      pad.hp                = 0.0
      pad.bp                = 0.0
      pad.fd                = 0.0
      pad.br                = 0.0
      pad.tilt              = 0
      pad.tilt_ease_type    = 1
      pad.tilt_ease_time    = 50
      pad.cf_fc             = 12000
      pad.cf_lp             = 0
      pad.cf_hp             = 0
      pad.cf_dry            = 1
      pad.cf_exp_dry        = 1
      pad.filter_type       = 4
      pad.enveloped         = false
      pad.envelope_time     = 3.0
      pad.clock_resolution  = 4
      pad.offset            = 1.0
      pad.crow_pad_execute  = 1
    end
    cross_filter[i]         = {}
    cross_filter[i].fc      = 12000
    cross_filter[i].lp      = 0
    cross_filter[i].hp      = 0
    cross_filter[i].dry     = 1
    cross_filter[i].exp_dry = 1
    cheat(i,bank[i].id)
  end
end

function cheat(b,i)
  env_counter[b]:stop()
  local pad = bank[b][i]
  if pad.enveloped then
    env_counter[b].butt = pad.level
    softcut.level(b+1,pad.level)
    softcut.level_cut_cut(b+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
    softcut.level_cut_cut(b+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
    env_counter[b].time = (pad.envelope_time/(pad.level/0.05))
    env_counter[b]:start()
  else
    softcut.level_slew_time(b+1,0.1)
    softcut.level(b+1,pad.level)
    softcut.level_cut_cut(b+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
    softcut.level_cut_cut(b+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
  end
  if pad.end_point == 9 or pad.end_point == 17 or pad.end_point == 25 then
    pad.end_point = pad.end_point-0.01
  end
  softcut.loop_start(b+1,pad.start_point)
  softcut.loop_end(b+1,pad.end_point)
  softcut.buffer(b+1,pad.mode)
  if pad.pause == false then
    softcut.rate(b+1,pad.rate*pad.offset)
  else
    softcut.rate(b+1,0)
  end
  if pad.loop == false then
    softcut.loop(b+1,0)
  else
    softcut.loop(b+1,1)
  end
  softcut.fade_time(b+1,0.01)
  if pad.rate > 0 then
      softcut.position(b+1,pad.start_point+0.05)
  elseif pad.rate < 0 then
      softcut.position(b+1,pad.end_point-0.05)
  end
  if slew_counter[b] ~= nil then
    slew_counter[b].next_tilt = pad.tilt
    slew_counter[b].next_q = pad.q
    if pad.tilt_ease_type == 1 then
      if slew_counter[b].slewedVal ~= nil and math.floor(slew_counter[b].slewedVal*10000) ~= math.floor(slew_counter[b].next_tilt*10000) then
        if math.floor(slew_counter[b].prev_tilt*10000) ~= math.floor(slew_counter[b].slewedVal*10000) then
          slew_counter[b].interrupted = 1
          slew_filter(util.round(b),slew_counter[b].slewedVal,slew_counter[b].next_tilt,slew_counter[b].prev_q,slew_counter[b].next_q,pad.tilt_ease_time)
        else
          slew_counter[b].interrupted = 0
          slew_filter(util.round(b),slew_counter[b].prev_tilt,slew_counter[b].next_tilt,slew_counter[b].prev_q,slew_counter[b].next_q,pad.tilt_ease_time)
        end
      end
    elseif pad.tilt_ease_type == 2 then
      slew_filter(util.round(b),slew_counter[b].prev_tilt,slew_counter[b].next_tilt,slew_counter[b].prev_q,slew_counter[b].next_q,pad.tilt_ease_time)
    end
  end
  softcut.pan(b+1,pad.pan)
  update_delays()
  if slew_counter[b] ~= nil then
    slew_counter[b].prev_tilt = pad.tilt
    slew_counter[b].prev_q = pad.q
  end
  previous_pad = bank[b].id
  if bank[b].crow_execute == 1 then
    if pad.crow_pad_execute == 1 then
      crow.output[b]()
    end
  end
  --dangerous??
  local rate_array = {-4.0,-2.0,-1.0,-0.5,-0.25,-0.125,0.125,0.25,0.5,1.0,2.0,4.0}
  local s = {}
  for k,v in pairs(rate_array) do
    s[v]=k
  end
  if pad.fifth == false then
    params:set("rate "..tonumber(string.format("%.0f",b)),s[pad.rate])
  end
  params:set("level "..tonumber(string.format("%.0f",b)),pad.level)
  params:set("current pad "..tonumber(string.format("%.0f",b)),i,"true")
  params:set("start point "..tonumber(string.format("%.0f",b)),pad.start_point*100,"true")
  params:set("end point "..tonumber(string.format("%.0f",b)),pad.end_point*100,"true")
  if osc_communication == true then
    osc_redraw(b)
  end
end

function envelope(i)
  softcut.level_slew_time(i+1,0.01)
  env_counter[i].butt = env_counter[i].butt - 0.05
  if env_counter[i].butt > 0 then
    softcut.level(i+1,env_counter[i].butt)
    softcut.level_cut_cut(i+1,5,env_counter[i].butt*bank[i][bank[i].id].left_delay_level)
    softcut.level_cut_cut(i+1,6,env_counter[i].butt*bank[i][bank[i].id].right_delay_level)
  else
    env_counter[i]:stop()
    softcut.level(i+1,0)
    env_counter[i].butt = bank[i][bank[i].id].level
    softcut.level_cut_cut(i+1,5,0)
    softcut.level_cut_cut(i+1,6,0)
    softcut.level_slew_time(i+1,1.0)
  end
end

function slew_filter(i,prevVal,nextVal,prevQ,nextQ,count)
  slew_counter[i]:stop()
  slew_counter[i].current = 0
  slew_counter[i].count = count
  slew_counter[i].duration = (slew_counter[i].count/100)-0.01
  slew_counter[i].beginVal = prevVal
  slew_counter[i].endVal = nextVal
  slew_counter[i].change = slew_counter[i].endVal - slew_counter[i].beginVal
  slew_counter[i].beginQ = prevQ
  slew_counter[i].endQ = nextQ
  slew_counter[i].changeQ = slew_counter[i].endQ - slew_counter[i].beginQ
  slew_counter[i]:start()
end

function easing_slew(i)
  slew_counter[i].slewedVal = slew_counter[i].ease(slew_counter[i].current,slew_counter[i].beginVal,slew_counter[i].change,slew_counter[i].duration)
  slew_counter[i].slewedQ = slew_counter[i].ease(slew_counter[i].current,slew_counter[i].beginQ,slew_counter[i].changeQ,slew_counter[i].duration)
  slew_counter[i].current = slew_counter[i].current + 0.01
  if grid.alt == 1 then
    try_tilt_process(i,bank[i].id,slew_counter[i].slewedVal,slew_counter[i].slewedQ)
  else
    for j = 1,16 do
      try_tilt_process(i,j,slew_counter[i].slewedVal,slew_counter[i].slewedQ)
    end
  end
  if menu == 5 then
    redraw()
  end
end

function try_tilt_process(b,i,t,rq)
  if util.round(t*100) < 0 then
    local trill = math.abs(t)
    bank[b][i].cf_lp = math.abs(t)
    bank[b][i].cf_dry = 1+t
    if util.round(t*100) >= -24 then
      bank[b][i].cf_exp_dry = (util.linexp(0,1,1,101,bank[b][i].cf_dry)-1)/100
    elseif util.round(t*100) <= -24 and util.round(t*100) >= -50 then
      bank[b][i].cf_exp_dry = (util.linexp(0.4,1,1,101,bank[b][i].cf_dry)-1)/100
    elseif util.round(t*100) < -50 then
      bank[b][i].cf_exp_dry = 0
    end
    bank[b][i].cf_fc = util.linexp(0,1,16000,10,bank[b][i].cf_lp)
    params:set("filter "..b.." cutoff",bank[b][i].cf_fc)
    params:set("filter "..b.." lp", math.abs(bank[b][i].cf_exp_dry-1))
    params:set("filter "..b.." dry", bank[b][i].cf_exp_dry)
    if params:get("filter "..b.." hp") ~= 0 then
      params:set("filter "..b.." hp", 0)
    end
    if bank[b][i].cf_hp ~= 0 then
      bank[b][i].cf_hp = 0
    end
  elseif util.round(t*100) > 0 then
    bank[b][i].cf_hp = math.abs(t)
    bank[b][i].cf_fc = util.linexp(0,1,10,12000,bank[b][i].cf_hp)
    bank[b][i].cf_dry = 1-t
    bank[b][i].cf_exp_dry = (util.linexp(0,1,1,101,bank[b][i].cf_dry)-1)/100
    params:set("filter "..b.." cutoff",bank[b][i].cf_fc)
    params:set("filter "..b.." hp", math.abs(bank[b][i].cf_exp_dry-1))
    params:set("filter "..b.." dry", bank[b][i].cf_exp_dry)
    if params:get("filter "..b.." lp") ~= 0 then
      params:set("filter "..b.." lp", 0)
    end
    if bank[b][i].cf_lp ~= 0 then
      bank[b][i].cf_lp = 0
    end
  elseif util.round(t*100) == 0 then
    bank[b][i].cf_fc = 12000
    bank[b][i].cf_lp = 0
    bank[b][i].cf_hp = 0
    bank[b][i].cf_dry = 1
    bank[b][i].cf_exp_dry = 1
    params:set("filter "..b.." cutoff",12000)
    params:set("filter "..b.." lp", 0)
    params:set("filter "..b.." hp", 0)
    params:set("filter "..b.." dry", 1)
  end
  softcut.post_filter_rq(b+1,rq)
end

function buff_freeze()
  softcut.recpre_slew_time(1,0.5)
  softcut.level_slew_time(1,0.5)
  softcut.fade_time(1,0.01)
  rec.state = (rec.state + 1)%2
  softcut.rec_level(1,rec.state)
  if rec.state == 1 then
    softcut.pre_level(1,params:get("live_rec_feedback"))
  else
    softcut.pre_level(1,1)
  end
end

function buff_flush()
  softcut.buffer_clear_region_channel(1,rec.start_point, rec.end_point-rec.start_point)
  rec.state = 0
  rec.clear = 1
  softcut.rec_level(1,0)
end

function update_delays()
  for i = 1,2 do
    local delay_rate_to_time = (60/bpm) * delay[i].rate
    local delay_time = delay_rate_to_time + (41 + (30*(i-1)))
    delay[i].end_point = delay_time
    softcut.loop_end(i+4,delay[i].end_point)
  end
end

function load_sample(file,sample)
  if file ~= "-" then
    local ch, len = audio.file_info(file)
    if len/48000 <=90 then
      if len/48000 > 8 then
        clip[sample].sample_length = 8
      else
        clip[sample].sample_length = len/48000
      end
    else
      clip[sample].sample_length = 8
    end
    softcut.buffer_read_mono(file, 0, 1+(8 * (sample-1)), 8.05, 1, 2)
  end
end

function save_sample(i)
  local dirname = _path.dust.."audio/cc_saved_samples/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  local name = "cc_"..os.date("%y%m%d_%X-buff")..i..".wav"
  local save_pos = i - 1
  softcut.buffer_write_mono(_path.dust.."/audio/cc_saved_samples/"..name,1+(8*save_pos),8,1)
end

function collect_samples(i) -- this works!!!
  local dirname = _path.dust.."audio/cc_collection-samples/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  local dirname = _path.dust.."audio/cc_collection-samples/"..params:get("collection").."/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  local name = "cc_"..params:get("collection").."-"..i..".wav"
  local save_pos = i - 1
  softcut.buffer_write_mono(_path.dust.."audio/cc_collection-samples/"..params:get("collection").."/"..name,1+(8*save_pos),8,1)
end

function reload_collected_samples(file,sample)
  if rec.state == 1 then
    buff_freeze()
  end
  if file ~= "-" then
    softcut.buffer_read_mono(file, 0, 1+(8 * (sample-1)), 8, 1, 1)
  end
end

function key(n,z)
  if n == 3 and z == 1 then
    if menu == 1 then
      for i = 1,7 do
        if page.main_sel == i then
          menu = i+1
        end
      end
    elseif menu == 2 then
      local loop_nav = (page.loops_sel + 1)%4
      page.loops_sel = loop_nav
    elseif menu == 3 then
      local level_nav = (page.levels_sel + 1)%3
      page.levels_sel = level_nav
    elseif menu == 5 then
      local filter_nav = (page.filtering_sel + 1)%3
      page.filtering_sel = filter_nav
    elseif menu == 7 then
      local time_nav = page.time_sel
      local id = time_nav
      --[[
        if time_nav == 1 and page.time_page_sel[time_nav] == 1 then
        local tap1 = util.time()
        deltatap = tap1 - tap
        tap = tap1
        local tap_tempo = 60/deltatap
        if tap_tempo >=1 then
          params:set("bpm",math.floor(tap_tempo+0.5))
        end
      elseif time_nav == 1 and page.time_page_sel[time_nav] == 3 then
        for i = 1,3 do
          crow.count[i] = crow.count_execute[i]
        end
        --]]
      if time_nav >= 1 and time_nav < 4 then
        if page.time_page_sel[time_nav] == 2 then
          random_grid_pat(id,2)
        elseif page.time_page_sel[time_nav] == 5 then
          if grid_pat[id].playmode == 3 or grid_pat[id].playmode == 4 then
            clock.run(random_grid_pat, id, 3)
          else
            random_grid_pat(id,3)
          end
        end
        if key1_hold then
          if grid_pat[id].count > 0 then
            grid_pat[id]:rec_stop()
            grid_pat[id]:stop()
            grid_pat[id].tightened_start = 0
            grid_pat[id]:clear()
            pattern_saver[id].load_slot = 0
          end
        end
      end
    end
  elseif n == 2 and z == 1 then
    if menu == 8 then
      help_menu = "welcome"
    end
    menu = 1
    if key1_hold == true then key1_hold = false end
  end
  if n == 1 and z == 1 then
    if menu == 2 or menu == 5 then
      if key1_hold == false then
        key1_hold = true
      else
        key1_hold = false
      end
    elseif menu == 7 then
      key1_hold = true
    else
      key1_hold = true
    end
    
  elseif n == 1 and z == 0 then
    if menu ~= 2 and menu ~= 5 then
      key1_hold = false
    end
    if menu == 7 then
      local time_nav = page.time_sel
      local id = time_nav
      if grid_pat[id].count > 0 then
        if grid_pat[id].quantize == 0 then
          if grid_pat[id].play == 1 then
            grid_pat[id]:stop()
          else
            grid_pat[id]:start()
          end
        else
          grid_pat[id].tightened_start = (grid_pat[id].tightened_start + 1)%2
          grid_pat[id].step = grid_pat[id].start_point
          quantized_grid_pat[id].current_step = grid_pat[id].start_point
          quantized_grid_pat[id].sub_step = 1
        end
      end
    end
  end
  redraw()
end

function enc(n,d)
  encoder_actions.init(n,d)
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.font_size(8)
  main_menu.init()
  screen.update()
end

--GRID
g = grid.connect()

g.key = function(x,y,z)
  grid_actions.init(x,y,z)
end

function clip_jump(i,s,y,z)
  for go = 1,2 do
    local old_min = (1+(8*(bank[i][s].clip-1)))
    local old_max = (9+(8*(bank[i][s].clip-1)))
    local old_range = old_min - old_max
    bank[i][s].clip = math.abs(y-5)
    local new_min = (1+(8*(bank[i][s].clip-1)))
    local new_max = (9+(8*(bank[i][s].clip-1)))
    local new_range = new_max - new_min
    local current_difference = (bank[i][s].end_point - bank[i][s].start_point)
    bank[i][s].start_point = (((bank[i][s].start_point - old_min) * new_range) / old_range) + new_min
    bank[i][s].end_point = bank[i][s].start_point + current_difference
    if menu == 8 then
      which_bank = i
      help_menu = "buffer jump"
    end
  end
end

function grid_entry(e)
  if e.state > 0 then
    lit[e.id] = {}
    lit[e.id].x = e.x
    lit[e.id].y = e.y
  else
    if lit[e.id] ~= nil then
      lit[e.id] = nil
    end
  end
  grid_redraw()
end

function grid_redraw()
  g:all(0)
  
  if grid_page == 0 then
    
    for j = 0,2 do
      for k = 1,4 do
        k = k+(5*j)
        for i = 8,5,-1 do
          g:led(k,i,3)
        end
      end
    end
    
    for j = 0,2 do
      for k = (5-j),(15-j),5 do
        for i = (4-j),1,-1 do
          g:led(k,i,3)
        end
      end
    end
    
    for i = 1,3 do
      if grid_pat[i].quantize == 0 then
        if grid_pat[i].rec == 1 then
          g:led(2+(5*(i-1)),1,(9*grid_pat[i].led))
        elseif grid_pat[i].play == 1 then
          g:led(2+(5*(i-1)),1,9)
        elseif grid_pat[i].count > 0 then
          g:led(2+(5*(i-1)),1,5)
        else
          g:led(2+(5*(i-1)),1,3)
        end
      elseif grid_pat[i].quantize == 1 then
        if grid_pat[i].rec == 1 then
          g:led(2+(5*(i-1)),1,(9*grid_pat[i].led))
        elseif grid_pat[i].tightened_start == 1 then
          g:led(2+(5*(i-1)),1,9)
        elseif grid_pat[i].count > 0 then
          g:led(2+(5*(i-1)),1,5)
        else
          g:led(2+(5*(i-1)),1,3)
        end
      end
    end
    
    for i = 1,3 do
      if arc_pat[i].rec == 1 then
        g:led(16,5-i,15)
      elseif arc_pat[i].play == 1 then
        g:led(16,5-i,9)
      elseif arc_pat[i].count > 0 then
        g:led(16,5-i,5)
      else
        g:led(16,5-i,0)
      end
    end
    
    if a.device ~= nil then
      for i = 1,3 do
        for j = 5,15,5 do
          g:led(j,8,arc_param[j/5] == 1 and 5 or 0)
          g:led(j,7,arc_param[j/5] == 2 and 5 or 0)
          g:led(j,6,arc_param[j/5] == 3 and 5 or 0)
          if arc_param[j/5] == 4 then
            for k = 8,6,-1 do
              g:led(j,k,5)
            end
          end
        end
      end
    end
    
    for i = 1,3 do
      if bank[i].focus_hold == false then
        g:led(selected[i].x, selected[i].y, 15)
        if bank[i][bank[i].id].pause == true then
          g:led(3+(5*(i-1)),1,15)
          g:led(3+(5*(i-1)),2,15)
        else
          g:led(3+(5*(i-1)),1,3)
          g:led(3+(5*(i-1)),2,3)
        end
      else
        local focus_x = (math.ceil(bank[i].focus_pad/4)+(5*(i-1)))
        local focus_y = 8-((bank[i].focus_pad-1)%4)
        g:led(selected[i].x, selected[i].y, 5)
        g:led(focus_x, focus_y, 15)
        if bank[i][bank[i].focus_pad].pause == true then
          g:led(3+(5*(i-1)),1,15)
          g:led(3+(5*(i-1)),2,15)
        else
          g:led(3+(5*(i-1)),1,3)
          g:led(3+(5*(i-1)),2,3)
        end
      end
    end
    
    for i = 1,3 do
      if bank[i].focus_hold == true then
        g:led(5*i,5,(10*bank[i][bank[i].focus_pad].crow_pad_execute)+5)
      end
    end
    
    for i,e in pairs(lit) do
      g:led(e.x, e.y,15)
    end
    
    g:led(16,8,(grid.alt*12)+3)
    
    for i = 1,3 do
      if bank[i].focus_hold == false then
        g:led(1 + (5*(i-1)), math.abs(bank[i][bank[i].id].clip-5),8)
        g:led(2 + (5*(i-1)), math.abs(bank[i][bank[i].id].mode-5),6)
        g:led(1+(5*(i-1)),1,0)
        if bank[i][bank[i].id].loop == false then
          g:led(3+(5*(i-1)),4,2)
        elseif bank[i][bank[i].id].loop == true then
          g:led(3+(5*(i-1)),4,4)
        end
      else
        g:led(1 + (5*(i-1)), math.abs(bank[i][bank[i].focus_pad].clip-5),8)
        g:led(2 + (5*(i-1)), math.abs(bank[i][bank[i].focus_pad].mode-5),6)
        g:led(1+(5*(i-1)),1,10)
        if bank[i][bank[i].focus_pad].loop == false then
          g:led(3+(5*(i-1)),4,2)
        elseif bank[i][bank[i].focus_pad].loop == true then
          g:led(3+(5*(i-1)),4,4)
        end
      end
    end
    
    if rec.clear == 0 then
      g:led(16,8-rec.clip,(5*rec.state)+5)
    elseif rec.clear == 1 then
      g:led(16,8-rec.clip,3)
    end
  
  else
    
    -- if we're on page 2...
    
    for i = 1,3 do
      for j = step_seq[i].start_point,step_seq[i].end_point do
        if j < 9 then
          g:led((i*5)-2,9-j,2)
          if grid.loop_mod == 1 then
            g:led((i*5)-2,9-step_seq[i].start_point,4)
            g:led((i*5)-2,9-step_seq[i].end_point,4)
          end
        elseif j >=9 then
          g:led((i*5)-1,17-j,2)
          if grid.loop_mod == 1 then
            g:led((i*5)-1,17-step_seq[i].start_point,4)
            g:led((i*5)-1,17-step_seq[i].end_point,4)
          end
        end
      end
    end
    
    for i = 1,11,5 do
      for j = 1,8 do
        local current = math.floor(i/5)+1
        if step_seq[current].held == 0 then
          g:led(i,j,(5*pattern_saver[current].saved[9-j])+2)
          g:led(i,j,j == 9 - pattern_saver[current].load_slot and 15 or ((5*pattern_saver[current].saved[9-j])+2))
        else
          g:led(i,j,(5*pattern_saver[current].saved[9-j])+2)
          g:led(i,j,j == 9 - step_seq[current][step_seq[current].held].assigned_to and 15 or ((5*pattern_saver[current].saved[9-j])+2))
        end
      end
    end
    
    for i = 1,3 do
      for j = 1,16 do
        if step_seq[i][j].assigned_to ~= 0 then
          if j < 9 then
            g:led((i*5)-2,9-j,4)
          elseif j >= 9 then
            g:led((i*5)-1,17-j,4)
          end
        end
      end
      if step_seq[i].current_step < 9 then
        g:led((i*5)-2,9-step_seq[i].current_step,15)
      elseif step_seq[i].current_step >=9 then
        g:led((i*5)-1,9-(step_seq[i].current_step-8),15)
      end
      if step_seq[i].held < 9 then
        g:led((i*5)-2,9-step_seq[i].held,9)
      elseif step_seq[i].held >= 9 then
        g:led((i*5)-1,9-(step_seq[i].held-8),9)
      end
    end
    
    for i = 1,3 do
      g:led((i*5)-3, 9-step_seq[i].meta_duration,4)
      g:led((i*5)-3, 9-step_seq[i].meta_step,6)
    end
    
    for i = 1,3 do
      if step_seq[i].held == 0 then
        g:led((i*5), 9-step_seq[i][step_seq[i].current_step].meta_meta_duration,4)
        g:led((i*5), 9-step_seq[i].meta_meta_step,6)
      else
        g:led((i*5), 9-step_seq[i].meta_meta_step,2)
        g:led((i*5), 9-step_seq[i][step_seq[i].held].meta_meta_duration,4)
      end
      if step_seq[i].held == 0 then
        g:led(16,8-i,(step_seq[i].active*6)+2)
      else
        g:led(16,8-i,step_seq[i][step_seq[i].held].loop_pattern*4)
      end
    end
    
    g:led(16,8,(grid.alt_pp*12)+3)
    g:led(16,2,(grid.loop_mod*9)+3)
    
    if grid.loop_mod == 1 then
      
    end
    
  end
  g:led(16,1,15*grid_page)
  
  g:refresh()
end
--/GRID

function grid_pattern_execute(entry)
  local i = entry.i
  if entry.action == "pads" then
    if params:get("zilchmo_patterning") == 2 then
      bank[i][entry.id].rate = entry.rate
    end
    selected[i].id = entry.id
    selected[i].x = entry.x
    selected[i].y = entry.y
    bank[i].id = selected[i].id
    if params:get("zilchmo_patterning") == 2 then
      bank[i][bank[i].id].mode = entry.mode
      bank[i][bank[i].id].clip = entry.clip
    end
    if arc_param[i] ~= 4 and #arc_pat[1].event == 0 then
      if params:get("zilchmo_patterning") == 2 then
        bank[i][bank[i].id].start_point = entry.start_point
        bank[i][bank[i].id].end_point = entry.end_point
      end
    end
    cheat(i,bank[i].id)
  elseif string.match(entry.action, "zilchmo") then
    if params:get("zilchmo_patterning") == 2 then
      bank[i][entry.id].rate = entry.rate
      if fingers[entry.row][entry.bank] == nil then
        fingers[entry.row][entry.bank] = {}
      end
      fingers[entry.row][entry.bank].con = entry.con
      zilchmo(entry.row,entry.bank)
      if arc_param[i] ~= 4 and #arc_pat[1].event == 0 then
        bank[i][bank[i].id].start_point = entry.start_point
        bank[i][bank[i].id].end_point = entry.end_point
        softcut.loop_start(i+1,bank[i][bank[i].id].start_point)
        softcut.loop_end(i+1,bank[i][bank[i].id].end_point)
      end
      local length = math.floor(math.log10(entry.con)+1)
      for i = 1,length do
        if grid_page == 0 then
          g:led((entry.row+1)*entry.bank,5-(math.floor(entry.con/(10^(i-1))) % 10),15)
          g:refresh()
        end
      end
    end
  end
  grid_redraw()
  redraw()
end

function arc_pattern_execute(entry)
  local i = entry.i
  local id = arc_control[i]
  local param = entry.param
  if param ~= 4 then
    local which_pad = entry.pad

    if arc_pat[i].step ~= 0 then
      if arc_pat[i].step > 1 then
        if params:get("arc_patterning") == 2 then
          if arc_pat[i].event[arc_pat[i].step].pad ~= arc_pat[i].event[arc_pat[i].step-1].pad then
            bank[id].id = arc_pat[i].event[arc_pat[i].step].pad
            selected[id].x = (math.ceil(bank[id].id/4)+(5*(id-1)))
            selected[id].y = 8-((bank[id].id-1)%4)
            cheat(id,arc_pat[i].event[arc_pat[i].step].pad)
            slew_filter(id,entry.prev_tilt,entry.tilt,bank[id][bank[id].id].q,bank[id][bank[id].id].q,15)
          end
        end
      elseif arc_pat[i].step == 1 then
        if params:get("arc_patterning") == 2 then
          bank[id].id = arc_pat[i].event[arc_pat[i].step].pad
          selected[id].x = (math.ceil(bank[id].id/4)+(5*(id-1)))
          selected[id].y = 8-((bank[id].id-1)%4)
          cheat(id,arc_pat[i].event[arc_pat[i].step].pad)
          slew_filter(id,arc_pat[i].event[arc_pat[i].count].tilt,entry.tilt,bank[id][bank[id].id].q,bank[id][bank[id].id].q,15)
        end
      end 
    elseif arc_pat[i].step == 0 then
      arc_pat[i].step = 1
      if params:get("arc_patterning") == 2 then
        bank[id].id = arc_pat[i].event[arc_pat[i].step].pad
        selected[id].x = (math.ceil(bank[id].id/4)+(5*(id-1)))
        selected[id].y = 8-((bank[id].id-1)%4)
        cheat(id,arc_pat[i].event[arc_pat[i].step].pad)
        slew_filter(id,arc_pat[i].event[arc_pat[i].count].tilt,entry.tilt,bank[id][bank[id].id].q,bank[id][bank[id].id].q,15)
      end
    end
      
    bank[id][which_pad].start_point = (entry.start_point + (8*(bank[id][which_pad].clip-1)) + arc_offset)
    bank[id][which_pad].end_point = (entry.end_point + (8*(bank[id][which_pad].clip-1)) + arc_offset)
    if bank[id].id == which_pad then
      softcut.loop_start(id+1, (entry.start_point + (8*(bank[id][which_pad].clip-1))) + arc_offset)
      softcut.loop_end(id+1, (entry.end_point + (8*(bank[id][which_pad].clip-1))) + arc_offset)
    end
  else
    slew_filter(id,entry.prev_tilt,entry.tilt,bank[id][bank[id].id].q,bank[id][bank[id].id].q,15)
  end
  redraw()
end

function arc_delay_pattern_execute(entry)
  local i = entry.i
  local side = entry.delay_focus
  arc_p[4].delay_focus = side
  if side == "L" then
    arc_p[4].left_delay_value = entry.left_delay_value
    params:set("delay L: rate",entry.left_delay_value)
  else
    arc_p[4].right_delay_value = entry.right_delay_value
    params:set("delay R: rate",entry.right_delay_value)
  end
  redraw()
end

function zilchmo(k,i)
  rightangleslice.init(k,i)
  lit = {}
  grid_redraw()
  redraw()
end

function pad_copy(destination, source)
  for k,v in pairs(source) do
    if k ~= bank_id and k ~= pad_id then
      destination[k] = v
    end
  end
end

a = arc.connect()
arc_d = {}
for i = 1,3 do
  arc_d[i] = {}
end

a.delta = function(n,d)
  arc_d[n] = d
  arc_actions.init(n,arc_d[n])
end

arc_redraw = function()
  a:all(0)
  local which_pad = nil
  for i = 1,3 do
    if bank[arc_control[i]].focus_hold == false then
      which_pad = bank[arc_control[i]].id
    else
      which_pad = bank[arc_control[i]].focus_pad
    end
    if arc_param[i] == 1 then
      local start_to_led = (bank[arc_control[i]][which_pad].start_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      local end_to_led = (bank[arc_control[i]][which_pad].end_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      if start_to_led <= end_to_led then
        a:segment(i, util.linlin(0, 8, tau*(1/4), tau*1.23, start_to_led), util.linlin(0, 8, (tau*(1/4))+0.1, tau*1.249999, end_to_led), 15)
      else
        a:segment(i, util.linlin(0, 8, (tau*(1/4))+0.1, tau*1.23, end_to_led), util.linlin(0, 8, tau*(1/4), tau*1.249999, start_to_led), 15)
      end
    end
    if arc_param[i] == 2 then
      local start_to_led = (bank[arc_control[i]][which_pad].start_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      local end_to_led = (bank[arc_control[i]][which_pad].end_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      local playhead_to_led = util.linlin(1,9,1,64,(poll_position_new[i+1] - (8*(bank[i][which_pad].clip-1))))
      a:led(i,(math.floor(playhead_to_led))+16,5)
      a:led(i,(math.floor(util.linlin(0,8,1,64,start_to_led)))+16,15)
      a:led(i,(math.floor(util.linlin(0,8,1,64,end_to_led)))+17,8)
    end
    if arc_param[i] == 3 then
      local start_to_led = (bank[arc_control[i]][which_pad].start_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      local end_to_led = (bank[arc_control[i]][which_pad].end_point-1)-(8*(bank[arc_control[i]][which_pad].clip-1))
      local playhead_to_led = util.linlin(1,9,1,64,(poll_position_new[i+1] - (8*(bank[i][which_pad].clip-1))))
      a:led(i,(math.floor(playhead_to_led))+16,5)
      a:led(i,(math.floor(util.linlin(0,8,1,64,end_to_led)))+17,15)
      a:led(i,(math.floor(util.linlin(0,8,1,64,start_to_led)))+16,8)
    end
    if arc_param[i] == 4 then
      local tilt_to_led = slew_counter[i].slewedVal
      if bank[i].focus_hold == true then
        which_pad = bank[i].focus_pad
        tilt_to_led = bank[i][bank[i].focus_pad].tilt
      else
        which_pad = bank[i].id
      end
      if tilt_to_led == nil then
        tilt_to_led = bank[i][which_pad].tilt
        a:led(i,47,5)
        a:led(i,48,10)
        a:led(i,49,15)
        a:led(i,50,10)
        a:led(i,51,5)
      elseif tilt_to_led >= -0.04 and tilt_to_led <=0.20 then
        a:led(i,47,5)
        a:led(i,48,10)
        a:led(i,49,15)
        a:led(i,50,10)
        a:led(i,51,5)
      elseif tilt_to_led < -0.04 then
        a:segment(i, tau*(1/4), util.linlin(-1, 1, (tau*(1/4))+0.1, tau*1.249999, tilt_to_led), 15)
      elseif tilt_to_led > 0.20 then
        a:segment(i, util.linlin(-1, 1, (tau*(1/4)), (tau*1.24)+0.4, tilt_to_led-0.1), tau*(1/4)+0.1, 15)
      end
      
    end
  end
  
  for i = 1,13 do
    local arc_left_delay_level = (params:get("delay L: rate") == i and 15 or 5)
    local arc_right_delay_level = (params:get("delay R: rate") == i and 15 or 5)
    local arc_try = params:get("delay L: rate")
    if grid.alt == 0 then
      a:led(4,(41+((i-1)*4)-16),arc_left_delay_level)
    else
      a:led(4,(41+((i-1)*4)-16),arc_right_delay_level)
    end
  end
  
  a:refresh()
end

--file loading

function savestate()
  local file = io.open(_path.data .. "cheat_codes/collections"..tonumber(string.format("%.0f",params:get("collection")))..".data", "w+")
  io.output(file)
  io.write("PERMANENCE".."\n")
  for i = 1,3 do
    for k = 1,16 do 
      io.write(bank[i].id .. "\n")
      io.write(selected[i].x .. "\n")
      io.write(selected[i].y .. "\n")
      io.write(bank[i][k].clip .. "\n")
      io.write(bank[i][k].mode .. "\n")
      io.write(bank[i][k].start_point .. "\n")
      io.write(bank[i][k].end_point .. "\n")
      io.write(bank[i][k].rate .. "\n")
      io.write(tostring(bank[i][k].pause) .. "\n")
      io.write(tostring(bank[i][k].play_mode) .. "\n")
      io.write(bank[i][k].level .. "\n")
      io.write(tostring(bank[i][k].loop) .. "\n")
      io.write(tostring(bank[i][k].fifth) .. "\n")
      io.write(bank[i][k].pan .. "\n")
      io.write(bank[i][k].fc .. "\n")
      io.write(bank[i][k].q .. "\n")
      io.write(bank[i][k].lp .. "\n")
      io.write(bank[i][k].hp .. "\n")
      io.write(bank[i][k].bp .. "\n")
      io.write(bank[i][k].fd .. "\n")
      io.write(bank[i][k].br .. "\n")
      io.write(bank[i][k].filter_type .. "\n")
      io.write(arc_control[i] .. "\n")
      io.write(arc_param[i] .. "\n")
    end
    io.write(params:get("rate slew time ".. i) .. "\n")
    io.write(tostring(params:get("clip "..i.." sample") .. "\n"))
    local sides = {"delay L: ", "delay R: "}
    for k = 1,2 do
      io.write(params:get(sides[k].."rate") .. "\n")
      io.write(params:get(sides[k].."global level") .. "\n")
      io.write(params:get(sides[k].."feedback") .. "\n")
      io.write(params:get(sides[k].."(a) send") .. "\n")
      io.write(params:get(sides[k].."(b) send") .. "\n")
      io.write(params:get(sides[k].."(c) send") .. "\n")
      io.write(params:get(sides[k].."filter cut") .. "\n")
      io.write(params:get(sides[k].."filter q") .. "\n")
      io.write(params:get(sides[k].."filter lp") .. "\n")
      io.write(params:get(sides[k].."filter hp") .. "\n")
      io.write(params:get(sides[k].."filter bp") .. "\n")
      io.write(params:get(sides[k].."filter dry") .. "\n")
    end
  end
  io.write(params:get("offset").."\n")
    -- v1.1 items
  io.write("v1.1".."\n")
  for i = 1,3 do
    for k = 1,16 do
      io.write(tostring(bank[i][k].enveloped) .. "\n")
      io.write(bank[i][k].envelope_time .. "\n")
    end
  end
  io.write(params:get("zilchmo_patterning") .. "\n")
  io.write(params:get("rec_loop") .. "\n")
  io.write(params:get("live_rec_feedback") .. "\n")
  io.write(params:get("quantize_pads") .. "\n")
  io.write(params:get("quantize_pats") .. "\n")
  io.write(params:get("quant_div") .. "\n")
  io.write(params:get("quant_div_pats") .. "\n")
  io.write(params:get("bpm") .. "\n")
  io.write(rec.clip .. "\n")
  io.write(rec.start_point .. "\n")
  io.write(rec.end_point .. "\n")
  io.write("v1.1.1.1.1.1.1.1".."\n")
  for i = 1,3 do
    io.write(step_seq[i].active .. "\n")
    io.write(step_seq[i].meta_duration .. "\n")
    for k = 1,16 do
      io.write(step_seq[i][k].meta_meta_duration .. "\n")
      io.write(step_seq[i][k].assigned_to .. "\n")
      io.write(bank[i][k].tilt .. "\n")
      io.write(bank[i][k].tilt_ease_time .. "\n")
      io.write(bank[i][k].tilt_ease_type .. "\n")
    end
  end
  io.write("the last params".."\n")
  --io.write(params:get("clock_out") .. "\n")
  io.write("0".."\n")
  --io.write(params:get("crow_clock_out") .. "\n")
  io.write("0".."\n")
  --io.write(params:get("midi_device") .. "\n")
  io.write("0".."\n")
  io.write(params:get("loop_enc_resolution") .."\n")
  --io.write(params:get("clock") .. "\n")
  io.write("0".."\n")
  io.write(params:get("lock_pat") .. "\n")
  for i = 1,3 do
    io.write(bank[i].crow_execute .. "\n")
    io.write(bank[i].snap_to_bars .. "\n")
  end
  for i = 1,3 do
    for j = 1,16 do
      io.write(bank[i][j].offset .. "\n")
    end
  end
  io.write("crow execute count".."\n")
  for i = 1,3 do
    io.write(crow.count_execute[i] .. "\n")
  end
  io.write("step seq loop points".."\n")
  for i = 1,3 do
    io.write(step_seq[i].start_point .. "\n")
    io.write(step_seq[i].end_point .. "\n")
  end
  io.write("Live buffer max".."\n")
  io.write(params:get"live_buff_rate" .. "\n")
  io.write("loop Pattern per step".."\n")
  for i = 1,3 do
    for k = 1,16 do
      io.write(step_seq[i][k].loop_pattern.."\n")
    end
  end
  io.write("collect live?".."\n")
  io.write(params:get("collect_live").."\n")
  if params:get("collect_live") == 2 then
    io.write("sample refs".."\n")
    for i = 1,3 do
      io.write("/home/we/dust/audio/cc_collection-samples/"..params:get("collection").."/".."cc_"..params:get("collection").."-"..i..".wav".."\n")
      collect_samples(i)
    end
  end
  io.write("last Pattern playmode".."\n")
  for i = 1,3 do
    io.write(grid_pat[i].playmode.."\n")
  end
  io.write("1.2.1: arc patterning".."\n")
  io.write(params:get("arc_patterning").."\n")
  io.write("1.2.2: crow_pad_execute".."\n")
  for i = 1,3 do
    for k = 1,16 do
      io.write(bank[i][k].crow_pad_execute.."\n")
    end
  end
  io.write("1.3: Pattern random pitch range".."\n")
  for i = 1,3 do
    io.write(grid_pat[i].random_pitch_range.."\n")
  end
  io.close(file)
  if selected_coll ~= params:get("collection") then
    meta_copy_coll(selected_coll,params:get("collection"))
  end
  meta_shadow(params:get("collection"))
  --maybe not this? want to clean up
  selected_coll = params:get("collection")
  for i = 1,3 do
    if arc_pat[i].count > 0 then
      save_arc_pattern(i)
    end
  end
end

function loadstate()
  selected_coll = params:get("collection")
  local file = io.open(_path.data .. "cheat_codes/collections"..selected_coll..".data", "r")
  if file then
    io.input(file)
    if io.read() == "PERMANENCE" then
      for i = 1,3 do
        for k = 1,16 do
          bank[i].id = tonumber(io.read())
          selected[i].x = tonumber(io.read())
          selected[i].y = tonumber(io.read())
          bank[i][k].clip = tonumber(io.read())
          bank[i][k].mode = tonumber(io.read())
          bank[i][k].start_point = tonumber(io.read())
          bank[i][k].end_point = tonumber(io.read())
          bank[i][k].rate = tonumber(io.read())
          local pause_to_boolean = io.read()
          if pause_to_boolean == "true" then
            bank[i][k].pause = true
          else
            bank[i][k].pause = false
          end
          bank[i][k].play_mode = io.read()
          bank[i][k].level = tonumber(io.read())
          local loop_to_boolean = io.read()
          if loop_to_boolean == "true" then
            bank[i][k].loop = true
          else
            bank[i][k].loop = false
          end
          local fifth_to_boolean = io.read()
          if fifth_to_boolean == "true" then
            bank[i][k].fifth = true
          else
            bank[i][k].fifth = false
          end
          bank[i][k].pan = tonumber(io.read())
          bank[i][k].fc = tonumber(io.read())
          bank[i][k].q = tonumber(io.read())
          bank[i][k].lp = tonumber(io.read())
          bank[i][k].hp = tonumber(io.read())
          bank[i][k].bp = tonumber(io.read())
          bank[i][k].fd = tonumber(io.read())
          bank[i][k].br = tonumber(io.read())
          tonumber(io.read())
          bank[i][k].filter_type = 4
          arc_control[i] = tonumber(io.read())
          arc_param[i] = tonumber(io.read())
        end
      params:set("rate slew time ".. i,tonumber(io.read()))
      local string_to_sample = io.read()
      params:set("clip "..i.." sample", string_to_sample)
      local sides = {"delay L: ", "delay R: "}
      for k = 1,2 do
        params:set(sides[k].."rate",tonumber(io.read()))
        params:set(sides[k].."global level",tonumber(io.read()))
        params:set(sides[k].."feedback",tonumber(io.read()))
        params:set(sides[k].."(a) send",tonumber(io.read()))
        params:set(sides[k].."(b) send",tonumber(io.read()))
        params:set(sides[k].."(c) send",tonumber(io.read()))
        params:set(sides[k].."filter cut",tonumber(io.read()))
        params:set(sides[k].."filter q",tonumber(io.read()))
        params:set(sides[k].."filter lp",tonumber(io.read()))
        params:set(sides[k].."filter hp",tonumber(io.read()))
        params:set(sides[k].."filter bp",tonumber(io.read()))
        params:set(sides[k].."filter dry",tonumber(io.read()))
      end
    end
    params:set("offset",tonumber(io.read()))
    else
      print("invalid data file")
    end
    if io.read() == "v1.1" then
      for i = 1,3 do
        for k = 1,16 do
          local enveloped_to_boolean = io.read()
          if enveloped_to_boolean == "true" then
            bank[i][k].enveloped = true
          else
            bank[i][k].enveloped = false
          end
          bank[i][k].envelope_time = tonumber(io.read())
        end
      end
      params:set("zilchmo_patterning",tonumber(io.read()))
      params:set("rec_loop",tonumber(io.read()))
      params:set("live_rec_feedback",tonumber(io.read()))
      tonumber(io.read()) -- kill off quantize_pads
      params:set("quantize_pads",1)
      tonumber(io.read()) -- kill off quantize_pats
      params:set("quantize_pats",1)
      tonumber(io.read()) -- kill off quant_div
      params:set("quant_div",4)
      params:set("quant_div_pats",tonumber(io.read()))
      local bpm_to_clock = tonumber(io.read())
      params:set("bpm",bpm_to_clock)
      params:set("clock_tempo",bpm_to_clock)
      rec.clip = tonumber(io.read())
      rec.start_point = tonumber(io.read())
      rec.end_point = tonumber(io.read())
      softcut.loop_start(1,rec.start_point)
      softcut.loop_end(1,rec.end_point-0.01)
      softcut.position(1,rec.start_point)
    end
    if io.read() == "v1.1.1.1.1.1.1.1" then
      for i = 1,3 do
        step_seq[i].active = tonumber(io.read())
        step_seq[i].meta_duration = tonumber(io.read())
        for k = 1,16 do
          step_seq[i][k].meta_meta_duration = tonumber(io.read())
          step_seq[i][k].assigned_to = tonumber(io.read())
          bank[i][k].tilt = tonumber(io.read())
          bank[i][k].tilt_ease_time = tonumber(io.read())
          bank[i][k].tilt_ease_type = tonumber(io.read())
        end
      end
    end
    if io.read() == "the last params" then
      --params:set("clock_out",tonumber(io.read()))
      local disregard = tonumber(io.read())
      --params:set("crow_clock_out",tonumber(io.read()))
      local disregard = tonumber(io.read())
      --params:set("midi_device",tonumber(io.read()))
      local disregard = tonumber(io.read())
      params:set("loop_enc_resolution",tonumber(io.read()))
      --params:set("clock",tonumber(io.read()))
      local disregard_the_clock_source = tonumber(io.read())
      local disregard = tonumber(io.read())
      params:set("lock_pat",1)
      for i = 1,3 do
        bank[i].crow_execute = tonumber(io.read())
        bank[i].snap_to_bars = tonumber(io.read())
      end
      for i = 1,3 do
        for j = 1,16 do
          bank[i][j].offset = tonumber(io.read())
        end
      end
    end
    if io.read() == "crow execute count" then
      for i = 1,3 do
        crow.count_execute[i] = tonumber(io.read())
      end
    end
    if io.read() == "step seq loop points" then
      for i = 1,3 do
        step_seq[i].start_point = tonumber(io.read())
        step_seq[i].current_step = step_seq[i].start_point
        step_seq[i].end_point = tonumber(io.read())
      end
    end
    if io.read() == "Live buffer max" then
      params:set("live_buff_rate",tonumber(io.read()))
    end
    if io.read() == "loop Pattern per step" then
      for i = 1,3 do
        for k = 1,16 do
          step_seq[i][k].loop_pattern = tonumber(io.read())
        end
      end
    end
    if io.read() == "collect live?" then
      local restore_live = tonumber(io.read())
      params:set("collect_live",restore_live)
      if restore_live == 2 then
        if io.read() == "sample refs" then
          for i = 1,3 do
            local string_to_sample = io.read()
            reload_collected_samples(string_to_sample,i)
          end
        end
      end
    end
    if io.read() == "last Pattern playmode" then
      for i = 1,3 do
        grid_pat[i].playmode = tonumber(io.read())
        set_pattern_mode(i)
      end
    end
    if io.read() == "1.2.1: arc patterning" then
      params:set("arc_patterning", tonumber(io.read()))
    end
    if io.read() == "1.2.2: crow_pad_execute" then
      for i = 1,3 do
        for k = 1,16 do
          bank[i][k].crow_pad_execute = tonumber(io.read())
        end
      end
    end
    if io.read() == "1.3: Pattern random pitch range" then
      for i  = 1,3 do
        grid_pat[i].random_pitch_range = tonumber(io.read())
      end
    end
    io.close(file)
    for i = 1,3 do
      if bank[i][bank[i].id].loop == true then
        cheat(i,bank[i].id)
      else
        softcut.loop(i+1, 0)
        softcut.position(i+1,bank[i][bank[i].id].start_point)
      end
    end
  end
  already_saved()
  for i = 1,3 do
    if step_seq[i].active == 1 and step_seq[i][step_seq[i].current_step].assigned_to ~= 0 then
      test_load(step_seq[i][step_seq[i].current_step].assigned_to+((i-1)*8),i)
    end
  end
  --maybe?
  if selected_coll ~= params:get("collection") then
    meta_shadow(selected_coll)
  elseif selected_coll == params:get("collection") then
    cleanup()
  end
  one_point_two()
  for i = 1,3 do
    local dirname = _path.data .. "cheat_codes/arc-patterns/collection-"..params:get("collection").."/encoder-"..i..".data"
    if os.rename(dirname, dirname) ~= nil then
      load_arc_pattern(i)
    end
  end
end

function test_save(i)
  if grid.alt_pp == 0 then
    if grid_pat[i].count > 0 and grid_pat[i].rec == 0 then
      copy_entire_pattern(i)
      save_pattern(i,pattern_saver[i].save_slot+8*(i-1))
      pattern_saver[i].saved[pattern_saver[i].save_slot] = 1
      pattern_saver[i].load_slot = pattern_saver[i].save_slot
      g:led(math.floor((i-1)*5)+1,9-pattern_saver[i].save_slot,15)
      g:refresh()
    else
      print("no pattern data to save")
      g:led(math.floor((i-1)*5)+1,9-pattern_saver[i].save_slot,0)
      g:refresh()
    end
  else
    if pattern_saver[i].saved[pattern_saver[i].save_slot] == 1 then
      delete_pattern(pattern_saver[i].save_slot+8*(i-1))
      pattern_saver[i].saved[pattern_saver[i].save_slot] = 0
      pattern_saver[i].load_slot = 0
    else
      print("no pattern data to delete")
    end
  end
end

function test_load(slot,destination)
  if pattern_saver[destination].saved[slot-((destination-1)*8)] == 1 then
    if grid_pat[destination].play == 1 then
      grid_pat[destination]:stop()
    elseif grid_pat[destination].tightened_start == 1 then
      grid_pat[destination].tightened_start = 0
      grid_pat[destination].step = grid_pat[destination].start_point
      quantized_grid_pat[destination].current_step = grid_pat[destination].start_point
      quantized_grid_pat[destination].sub_step = 1
    end
    load_pattern(slot,destination)
    if grid_pat[destination].quantize == 0 then
      grid_pat[destination]:start()
    elseif grid_pat[destination].quantize == 1 then
      grid_pat[destination].tightened_start = 1
    end
  end
end

function save_pattern(source,slot)
  local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..slot..".data", "w+")
  io.output(file)
  io.write("stored pad pattern: collection "..selected_coll.." + slot "..slot.."\n")
  io.write(original_pattern[source].count .. "\n")
  for i = 1,original_pattern[source].count do
    io.write(original_pattern[source].time[i] .. "\n")
    io.write(original_pattern[source].event[i].id .. "\n")
    io.write(original_pattern[source].event[i].rate .. "\n")
    io.write(tostring(original_pattern[source].event[i].loop) .. "\n")
    if original_pattern[source].event[i].mode ~= nil then
      io.write(original_pattern[source].event[i].mode .. "\n")
    else
      io.write("nil" .. "\n")
    end
    io.write(tostring(original_pattern[source].event[i].pause) .. "\n")
    io.write(original_pattern[source].event[i].start_point .. "\n")
    if original_pattern[source].event[i].clip ~= nil then
      io.write(original_pattern[source].event[i].clip .. "\n")
    else
      io.write("nil" .. "\n")
    end
    io.write(original_pattern[source].event[i].end_point .. "\n")
    if original_pattern[source].event[i].rate_adjusted ~= nil then
      io.write(tostring(original_pattern[source].event[i].rate_adjusted) .. "\n")
    else
      io.write("nil" .. "\n")
    end
    io.write(original_pattern[source].event[i].y .. "\n")
    io.write(original_pattern[source].event[i].x .. "\n")
    io.write(tostring(original_pattern[source].event[i].action) .. "\n")
    io.write(original_pattern[source].event[i].i .. "\n")
    if original_pattern[source].event[i].previous_rate ~= nil then
      io.write(original_pattern[source].event[i].previous_rate .. "\n")
    else
      io.write("nil" .. "\n")
    end
    if original_pattern[source].event[i].row ~=nil then
      io.write(original_pattern[source].event[i].row .. "\n")
    else
      io.write("nil" .. "\n")
    end
    if original_pattern[source].event[i].con ~= nil then
      io.write(original_pattern[source].event[i].con .. "\n")
    else
      io.write("nil" .. "\n")
    end
    if original_pattern[source].event[i].bank ~= nil and #original_pattern[source].event > 0 then
      io.write(original_pattern[source].event[i].bank .. "\n")
    else
      io.write("nil" .. "\n")
    end
  end
  io.write(original_pattern[source].metro.props.time .. "\n")
  io.write(original_pattern[source].prev_time .. "\n")
  io.write("which playmode?" .. "\n")
  io.write(original_pattern[source].playmode .. "\n")
  io.write("start point" .. "\n")
  io.write(original_pattern[source].start_point .. "\n")
  io.write("end point" .. "\n")
  io.write(original_pattern[source].end_point .. "\n")
  io.close(file)
  save_external_timing(source,slot)
  print("saved pattern "..source.." to slot "..slot)
end

function already_saved()
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..i..".data", "r")
    if file then
      io.input(file)
      if io.read() == "stored pad pattern: collection "..selected_coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 1
      else
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 0
        os.remove(_path.data .. "cheat_codes/pattern" ..selected_coll.."_"..i..".data")
      end
      io.close(file)
    else
      local current = math.floor((i-1)/8)+1
      pattern_saver[current].saved[i-(8*(current-1))] = 0
    end
  end
end

function one_point_two()
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..i..".data", "r")
    if file then
      io.input(file)
      if io.read() == "stored pad pattern: collection "..selected_coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
                ---
        --create pre-1.2 external files
        local ext_file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..selected_coll.."_"..i.."_external-timing.data", "r")
        if ext_file then
          io.close(ext_file)
        else
          load_pattern(i,current)
        end
      else
      end
      io.close(file)
    end
  end
  for i = 1,3 do
    grid_pat[i]:rec_stop()
    grid_pat[i]:stop()
    grid_pat[i].tightened_start = 0
    grid_pat[i]:clear()
    pattern_saver[i].load_slot = 0
  end
end

function clear_zero()
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/pattern0_"..i..".data", "r")
    if file then
      io.input(file)
      if io.read() == "stored pad pattern: collection 0 + slot "..i then
        os.remove(_path.data .. "cheat_codes/pattern0_"..i..".data")
        print("cleared default pattern")
      end
      io.close(file)
    end
  end
  for i = 1,24 do
    local external_timing_file = io.open(_path.data .. "cheat_codes/external-timing/pattern0_"..i.."_external-timing.data", "r")
    if external_timing_file then
      io.input(external_timing_file)
      if io.read() == "external clock timing for stored pad pattern: collection 0 + slot "..i then
        os.remove(_path.data .. "cheat_codes/external-timing/pattern0_"..i.."_external-timing.data")
        print("cleared default external timing")
      end
      io.close(external_timing_file)
    end
  end
end

function delete_pattern(slot)
  local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..slot..".data", "w+")
  io.output(file)
  io.write()
  io.close(file)
  print("deleted pattern from slot "..slot)
  local external_timing_file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..selected_coll.."_"..slot.."_external-timing.data", "w+")
  io.output(external_timing_file)
  io.write()
  io.close(external_timing_file)
  print("deleted external timing from slot "..slot)
end

function copy_pattern_across_coll(read_coll,write_coll,slot)
  local infile = io.open(_path.data .. "cheat_codes/pattern"..read_coll.."_"..slot..".data", "r")
  local outfile = io.open(_path.data .. "cheat_codes/pattern"..write_coll.."_"..slot..".data", "w+")
  io.output(outfile)
  for line in infile:lines() do
    if line == "stored pad pattern: collection "..read_coll.." + slot "..slot then
      io.write("stored pad pattern: collection "..write_coll.." + slot "..slot.."\n")
    else
      io.write(line.."\n")
    end
  end
  io.close(infile)
  io.close(outfile)

  --/externalshadow
  local external_timing_infile = io.open(_path.data .. "cheat_codes/external-timing/pattern"..read_coll.."_"..slot.."_external-timing.data", "r")
  local external_timing_outfile = io.open(_path.data .. "cheat_codes/external-timing/pattern"..write_coll.."_"..slot.."_external-timing.data", "w+")
  io.output(external_timing_outfile)
  for line in external_timing_infile:lines() do
    if line == "external clock timing for stored pad pattern: collection "..read_coll.." + slot "..slot then
      io.write("external clock timing for stored pad pattern: collection "..write_coll.." + slot "..slot.."\n")
    else
      io.write(line.."\n")
    end
  end
  io.close(external_timing_infile)
  io.close(external_timing_outfile)
  --externalshadow/
  
end

function shadow_pattern(read_coll,write_coll,slot)
  local infile = io.open(_path.data .. "cheat_codes/pattern"..read_coll.."_"..slot..".data", "r")
  local outfile = io.open(_path.data .. "cheat_codes/shadow-pattern"..write_coll.."_"..slot..".data", "w+")
  io.output(outfile)
  for line in infile:lines() do
    if line == "stored pad pattern: collection "..read_coll.." + slot "..slot then
      io.write("stored pad pattern: collection "..write_coll.." + slot "..slot.."\n")
    else
      io.write(line.."\n")
    end
  end
  io.close(infile)
  io.close(outfile)
  
  --/externalshadow
  local external_timing_infile = io.open(_path.data .. "cheat_codes/external-timing/pattern"..read_coll.."_"..slot.."_external-timing.data", "r")
  local external_timing_outfile = io.open(_path.data .. "cheat_codes/external-timing/shadow-pattern"..write_coll.."_"..slot.."_external-timing.data", "w+")
  io.output(external_timing_outfile)
  for line in external_timing_infile:lines() do
    if line == "external clock timing for stored pad pattern: collection "..read_coll.." + slot "..slot then
      io.write("external clock timing for stored pad pattern: collection "..write_coll.." + slot "..slot.."\n")
    else
      io.write(line.."\n")
    end
  end
  io.close(external_timing_infile)
  io.close(external_timing_outfile)
  --externalshadow/

end

function meta_shadow(coll)
  for i = 1,3 do
    for j = 1,8 do
      if pattern_saver[i].saved[j] == 1 then
        shadow_pattern(coll,coll,j+(8*(i-1)))
      elseif pattern_saver[i].saved[j] == 0 then
        local file = io.open(_path.data .. "cheat_codes/shadow-pattern"..coll.."_"..j+(8*(i-1))..".data", "w+")
        -- need an already saved shadow thing here to clear out
        if file then
          io.output(file)
          io.write()
          io.close(file)
        end
        
        --/externalshadow
        local external_timing_file = io.open(_path.data .. "cheat_codes/external-timing/shadow-pattern"..coll.."_"..j+(8*(i-1)).."_external-timing.data", "w+")
        if external_timing_file then
          io.output(external_timing_file)
          io.write()
          io.close(external_timing_file)
        end
        --externalshadow/
      end
    end
  end
end

function clear_empty_shadows(coll)
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/shadow-pattern"..coll.."_"..i..".data", "r")
    if file then
      io.input(file)
      if io.read() == "stored pad pattern: collection "..coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 1
      else
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 0
        os.remove(_path.data .. "cheat_codes/shadow-pattern" ..coll.."_"..i..".data")
      end
      io.close(file)
    else
      local current = math.floor((i-1)/8)+1
      pattern_saver[current].saved[i-(8*(current-1))] = 0
    end
  end
  
  --/externalshadow
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/external-timing/shadow-pattern"..coll.."_"..i.."_external-timing.data", "r")
    if file then
      io.input(file)
      if io.read() == "external clock timing for stored pad pattern: collection "..coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 1
      else
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 0
        os.remove(_path.data .. "cheat_codes/external-timing/shadow-pattern" ..coll.."_"..i.."_external-timing.data")
      end
      io.close(file)
    end
  end
  --externalshadow/
  
end

function shadow_to_play(coll,slot)
  local infile = io.open(_path.data .. "cheat_codes/shadow-pattern"..coll.."_"..slot..".data", "r")
  local outfile = io.open(_path.data .. "cheat_codes/pattern"..coll.."_"..slot..".data", "w+")
  io.output(outfile)
  if infile then
    for line in infile:lines() do
      if line == "stored pad pattern: collection "..coll.." + slot "..slot then
        io.write("stored pad pattern: collection "..coll.." + slot "..slot.."\n")
      else
        io.write(line.."\n")
      end
    end
    io.close(infile)
    io.close(outfile)
  end
  
  --/externalshadow
  local external_timing_infile = io.open(_path.data .. "cheat_codes/external-timing/shadow-pattern"..coll.."_"..slot.."_external-timing.data", "r")
  local external_timing_outfile = io.open(_path.data .. "cheat_codes/external-timing/pattern"..coll.."_"..slot.."_external-timing.data", "w+")
  io.output(external_timing_outfile)
  if external_timing_infile then
    for line in external_timing_infile:lines() do
      if line == "external clock timing for stored pad pattern: collection "..coll.." + slot "..slot then
        io.write("external clock timing for stored pad pattern: collection "..coll.." + slot "..slot.."\n")
      else
        io.write(line.."\n")
      end
    end
    io.close(external_timing_infile)
    io.close(external_timing_outfile)
  end
  --externalshadow/
  
end

function meta_copy_coll(read_coll,write_coll)
  for i = 1,3 do
    for j = 1,8 do
      if pattern_saver[i].saved[j] == 1 then
        copy_pattern_across_coll(read_coll,write_coll,j+(8*(i-1)))
      elseif pattern_saver[i].saved[j] == 0 then
        local file = io.open(_path.data .. "cheat_codes/pattern"..write_coll.."_"..j+(8*(i-1))..".data", "w+")
        if file then
          io.output(file)
          io.write()
          io.close(file)
        end
        
        --/externalshadow
        local external_timing_file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..write_coll.."_"..j+(8*(i-1)).."_external-timing.data", "w+")
        if external_timing_file then
          io.output(external_timing_file)
          io.write()
          io.close(external_timing_file)
        end
        --externalshadow/
        
      end
    end
  end
end

function load_pattern(slot,destination)
  local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..slot..".data", "r")
  if file then
    io.input(file)
    if io.read() == "stored pad pattern: collection "..selected_coll.." + slot "..slot then
      grid_pat[destination].event = {}
      grid_pat[destination].count = tonumber(io.read())
      for i = 1,grid_pat[destination].count do
        grid_pat[destination].time[i] = tonumber(io.read())
        grid_pat[destination].event[i] = {}
        grid_pat[destination].event[i].id = {}
        grid_pat[destination].event[i].rate = {}
        grid_pat[destination].event[i].loop = {}
        grid_pat[destination].event[i].mode = {}
        grid_pat[destination].event[i].pause = {}
        grid_pat[destination].event[i].start_point = {}
        grid_pat[destination].event[i].clip = {}
        grid_pat[destination].event[i].end_point = {}
        grid_pat[destination].event[i].rate_adjusted = {}
        grid_pat[destination].event[i].y = {}
        grid_pat[destination].event[i].x = {}
        grid_pat[destination].event[i].action = {}
        grid_pat[destination].event[i].i = {}
        grid_pat[destination].event[i].previous_rate = {}
        grid_pat[destination].event[i].row = {}
        grid_pat[destination].event[i].con = {}
        grid_pat[destination].event[i].bank = nil
        grid_pat[destination].event[i].id = tonumber(io.read())
        grid_pat[destination].event[i].rate = tonumber(io.read())
        local loop_to_boolean = io.read()
        if loop_to_boolean == "true" then
          grid_pat[destination].event[i].loop = true
        else
          grid_pat[destination].event[i].loop = false
        end
        grid_pat[destination].event[i].mode = tonumber(io.read())
        local pause_to_boolean = io.read()
        if pause_to_boolean == "true" then
          grid_pat[destination].event[i].pause = true
        else
          grid_pat[destination].event[i].pause = false
        end
        grid_pat[destination].event[i].start_point = tonumber(io.read())
        grid_pat[destination].event[i].clip = tonumber(io.read())
        grid_pat[destination].event[i].end_point = tonumber(io.read())
        local rate_adjusted_to_boolean = io.read()
        if rate_adjusted_to_boolean == "true" then
          grid_pat[destination].event[i].rate_adjusted = true
        else
          grid_pat[destination].event[i].rate_adjusted = false
        end
        grid_pat[destination].event[i].y = tonumber(io.read())
        local loaded_x = tonumber(io.read())
        grid_pat[destination].event[i].action = io.read()
        grid_pat[destination].event[i].i = destination
        local source = tonumber(io.read())
        if destination < source then
          grid_pat[destination].event[i].x = loaded_x - (5*(source-destination))
        elseif destination > source then
          grid_pat[destination].event[i].x = loaded_x + (5*(destination-source))
        elseif destination == source then
          grid_pat[destination].event[i].x = loaded_x
        end
        grid_pat[destination].event[i].previous_rate = tonumber(io.read())
        grid_pat[destination].event[i].row = tonumber(io.read())
        grid_pat[destination].event[i].con = io.read()
        local loaded_bank = tonumber(io.read())
        if loaded_bank ~= nil then
          if destination < source then
            grid_pat[destination].event[i].bank = loaded_bank - (5*(source-destination))
          elseif destination > source then
            grid_pat[destination].event[i].bank = loaded_bank + (5*(source-destination))
          elseif destination == source then
            grid_pat[destination].event[i].bank = loaded_bank
          end
        end
      end
      grid_pat[destination].metro.props.time = tonumber(io.read())
      grid_pat[destination].prev_time = tonumber(io.read())
      if io.read() == "which playmode?" then
        grid_pat[destination].playmode = tonumber(io.read())
      else
        grid_pat[destination].playmode = 1
      end
      set_pattern_mode(destination)
      if io.read() == "start point" then
        grid_pat[destination].start_point = tonumber(io.read())
      else
        grid_pat[destination].start_point = 1
      end
      if io.read() == "end point" then
        grid_pat[destination].end_point = tonumber(io.read())
      else
        grid_pat[destination].end_point = grid_pat[destination].count
      end
    end
    io.close(file)
    load_external_timing(destination,slot)
  else
    print("nofile")
  end
end

function cleanup()
  clear_zero()
  for i = 1,3 do
    for j = 1,8 do
      shadow_to_play(selected_coll,j+(8*(i-1)))
    end
  end
  
  --need all this to just happen at cleanup after save
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/pattern"..selected_coll.."_"..i..".data", "r")
    if file then
      io.input(file)
      if io.read() == "stored pad pattern: collection "..selected_coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 1
      else
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 0
        os.remove(_path.data .. "cheat_codes/pattern" ..selected_coll.."_"..i..".data")
      end
      io.close(file)
    else
      local current = math.floor((i-1)/8)+1
      pattern_saver[current].saved[i-(8*(current-1))] = 0
    end
  end
  
  --/externalshadow
  for i = 1,24 do
    local file = io.open(_path.data .. "cheat_codes/external-timing/pattern"..selected_coll.."_"..i.."_external-timing.data", "r")
    if file then
      io.input(file)
      if io.read() == "external clock timing for stored pad pattern: collection "..selected_coll.." + slot "..i then
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 1
      else
        local current = math.floor((i-1)/8)+1
        pattern_saver[current].saved[i-(8*(current-1))] = 0
        os.remove(_path.data .. "cheat_codes/external-timing/pattern" ..selected_coll.."_"..i.."_external-timing.data")
      end
      io.close(file)
    else
      --print("can't clean these external files?")
    end
  end
  --externalshadow/
  
  clear_empty_shadows(selected_coll)
end

-- arc pattern stuff!

function save_arc_pattern(which)
  local dirname = _path.data.."cheat_codes/arc-patterns/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  
  local dirname = _path.data.."cheat_codes/arc-patterns/collection-"..selected_coll.."/"
  if os.rename(dirname, dirname) == nil then
    os.execute("mkdir " .. dirname)
  end
  
  local file = io.open(_path.data .. "cheat_codes/arc-patterns/collection-"..selected_coll.."/encoder-"..which..".data", "w+")
  io.output(file)
  io.write("stored arc pattern: collection "..selected_coll.." + encoder "..which.."\n")
  io.write(arc_pat[which].count .. "\n")
  for i = 1,arc_pat[which].count do
    io.write(arc_pat[which].time[i] .. "\n")
    io.write(arc_pat[which].event[i].i .. "\n")
    io.write(arc_pat[which].event[i].param .. "\n")
    io.write(arc_pat[which].event[i].pad .. "\n")
    io.write(arc_pat[which].event[i].start_point .. "\n")
    io.write(arc_pat[which].event[i].end_point .. "\n")
    io.write(arc_pat[which].event[i].prev_tilt .. "\n")
    io.write(arc_pat[which].event[i].tilt .. "\n")
  end
  io.write(arc_pat[which].metro.props.time .. "\n")
  io.write(arc_pat[which].prev_time .. "\n")
  io.write("start point: " .. arc_pat[which].start_point .. "\n")
  io.write("end point: " .. arc_pat[which].end_point .. "\n")
  io.close(file)
  print("saved arc pattern for encoder "..which)
end

function load_arc_pattern(which)
  local file = io.open(_path.data .. "cheat_codes/arc-patterns/collection-"..selected_coll.."/encoder-"..which..".data", "r")
  if file then
    io.input(file)
    if io.read() == "stored arc pattern: collection "..selected_coll.." + encoder "..which then
      arc_pat[which].event = {}
      arc_pat[which].count = tonumber(io.read())
      for i = 1,arc_pat[which].count do
        arc_pat[which].time[i] = tonumber(io.read())
        arc_pat[which].event[i] = {}
        arc_pat[which].event[i].i = {}
        arc_pat[which].event[i].param = {}
        arc_pat[which].event[i].pad = {}
        arc_pat[which].event[i].start_point = {}
        arc_pat[which].event[i].end_point = {}
        arc_pat[which].event[i].prev_tilt = {}
        arc_pat[which].event[i].tilt = {}
        --
        arc_pat[which].event[i].i = tonumber(io.read())
        arc_pat[which].event[i].param = tonumber(io.read())
        arc_pat[which].event[i].pad = tonumber(io.read())
        arc_pat[which].event[i].start_point = tonumber(io.read())
        arc_pat[which].event[i].end_point = tonumber(io.read())
        arc_pat[which].event[i].prev_tilt = tonumber(io.read())
        arc_pat[which].event[i].tilt = tonumber(io.read())
      end
      arc_pat[which].metro.props.time = tonumber(io.read())
      arc_pat[which].prev_time = tonumber(io.read())
      local new_arc_array = io.read()
      if new_arc_array ~= nil then
        arc_pat[which].start_point = tonumber(string.match(new_arc_array, ': (.*)'))
      else
        arc_pat[which].start_point = 1
      end
      local new_arc_array = io.read()
      if new_arc_array ~= nil then
        arc_pat[which].end_point = tonumber(string.match(new_arc_array, ': (.*)'))
      else
        arc_pat[which].end_point = arc_pat[which].count
      end
    end
    io.close(file)
  else
    print("nofile")
  end
end
