start_up = {}

function start_up.init()
  
  softcut.buffer_clear()
  softcut.pan(1, 0.0)
  
  for i = 1, 4 do
    softcut.level(i,0.0)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.buffer(i, 1)
    audio.level_adc_cut(1)
    softcut.fade_time(i, 0.01)
    softcut.play(i, 1)
    softcut.rate(i, 1)
    softcut.loop_start(i, 1)
    softcut.loop_end(i, 9)
    softcut.loop_end(1,8.99)
    softcut.loop(i, 1)
    softcut.rec(1, 1)
    softcut.rec_level(1, 1)
    softcut.pre_level(1, 0.25)
    softcut.position(i, 1)
    softcut.phase_quant(i, 0.01)
    softcut.rec_offset(i, -0.0003)
    softcut.enable(i, 1)
    softcut.rate_slew_time(4,0.2)
  end
  
  softcut.event_phase(phase)
  softcut.poll_start_phase()
  
  softcut.level(5,1)
  softcut.pan(5,-1)
  softcut.buffer(5,1)
  softcut.play(5, 1)
  softcut.rate(5, 1)
  softcut.loop_start(5, 41)
  softcut.loop_end(5, 41.5)
  softcut.loop(5, 1)
  softcut.rec(5, 1)
  softcut.rec_level(5, 1)
  softcut.pre_level(5, 0.5)
  softcut.position(5, 41)
  softcut.rec_offset(5, -0.0003)
  softcut.enable(5, 1)
  
  softcut.level(6,1)
  softcut.pan(6,1)
  softcut.level_cut_cut(2,6,0.3)
  softcut.level_cut_cut(3,6,0.7)
  softcut.level_cut_cut(4,6,1)
  softcut.buffer(6,1)
  softcut.play(6, 1)
  softcut.rate(6, 1)
  softcut.loop_start(6, 71)
  softcut.loop_end(6, 71.5)
  softcut.loop(6, 1)
  softcut.rec(6, 1)
  softcut.rec_level(6, 1)
  softcut.pre_level(6, 0.5)
  softcut.position(6, 71)
  softcut.rec_offset(6, -0.0003)
  softcut.enable(6, 1)
  
  --params:add_separator()
  
  params:add_group("loops + buffers", 8)
  
  for i = 1,3 do
    params:add_file("clip "..i.." sample", "clip "..i.." sample")
    params:set_action("clip "..i.." sample", function(file) load_sample(file,i) end)
  end
  
  params:add{id="live_rec_feedback", name="live rec feedback", type="control", 
  controlspec=controlspec.new(0,1.0,'lin',0,0.25,""),
  action=function(x)
    if rec.state == 1 then
      softcut.pre_level(1,x)
    end
  end}

  params:add_option("rec_loop", "live rec behavior", {"loop","1-shot"}, 1)
  params:set_action("rec_loop",
    function(x)
      rec.loop = 2-x
      softcut.loop(1,rec.loop)
      softcut.position(1,rec.start_point)
      rec.state = 1
      rec.clear = 0
      softcut.rec_level(1,rec.state)
      if x == 2 then
        rec_state_watcher:start()
        softcut.pre_level(1,params:get("live_rec_feedback"))
      elseif x == 1 then
        softcut.pre_level(1,params:get("live_rec_feedback"))
      end
    end
  )

  params:add_control("offset", "global pitch offset", controlspec.new(-24, 24, 'lin', 1, 0, "st"))
  params:set_action("offset",
    function(value)
      for i=1,3 do
        for j = 1,16 do
          bank[i][j].offset = math.pow(0.5, -value / 12)
        end
        if bank[i][bank[i].id].pause == false then
          softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
        end
      end
    end
  )
  
  params:add_option("loop_enc_resolution", "loop encoder resolution", {"0.1","0.01","1/16","1/8","1/4","1/2","1 bar"}, 1)
  params:set_action("loop_enc_resolution", function(x)
    local resolutions =
    { [1] = 10
    , [2] = 100
    , [3] = 1/((60/bpm)/4)
    , [4] = 1/((60/bpm)/2)
    , [5] = 1/((60/bpm))
    , [6] = (1/((60/bpm)))/2
    , [7] = (1/((60/bpm)))/4
    }
    loop_enc_resolution = resolutions[x]
  end)
  
  params:add_option("live_buff_rate", "Live buffer max", {"8 sec", "16 sec", "32 sec"}, 1)
  params:set_action("live_buff_rate", function(x)
    local buff_rates = {1,0.5,0.25}
    softcut.rate(1,buff_rates[x])
  end)
  
  --params:add_separator()
  
  params:add_group("grid/arc pattern params",2)
  params:add_option("zilchmo_patterning", "grid pattern style", { "classic", "rad sauce" })
  params:add_option("arc_patterning", "arc pattern style", { "passive", "active" })
  
  params:add_group("manual control params",27)
  
  for i = 1,3 do
    banks = {"(a)","(b)","(c)"}
    params:add_separator(banks[i])
    params:add_control("current pad "..i, "current pad "..banks[i], controlspec.new(1,16,'lin',1,1))
    params:set_action("current pad "..i, function(x)
      if bank[i].id ~= x then
        bank[i].id = x
        selected[i].x = (math.ceil(bank[i].id/4)+(5*(i-1)))
        selected[i].y = 8-((bank[i].id-1)%4)
        cheat(i,bank[i].id)
        redraw()
      end
    end)
    local rates = {-4,-2,-1,-0.5,-0.25,-0.125,0.125,0.25,0.5,1,2,4}
    --params:add_control("rate "..i, "rate "..banks[i].." (RAW)", controlspec.new(1,12,'lin',1,10))
    params:add_option("rate "..i, "rate "..banks[i], {"-4x","-2x","-1x","-0.5x","-0.25x","-0.125x","0.125x","0.25x","0.5x","1x","2x","4x"}, 10)
    params:set_action("rate "..i, function(x)
      bank[i][bank[i].id].rate = rates[x]
      if bank[i][bank[i].id].pause == false then
        softcut.rate(i+1, bank[i][bank[i].id].rate*bank[i][bank[i].id].offset)
      end
    end)
    params:add_control("rate slew time "..i, "rate slew time "..banks[i], controlspec.new(0,3,'lin',0.01,0))
    params:set_action("rate slew time "..i, function(x) softcut.rate_slew_time(i+1,x) end)
    params:add_control("pan "..i, "pan "..banks[i], controlspec.new(-1,1,'lin',0.01,0))
    params:set_action("pan "..i, function(x) softcut.pan(i+1,x) bank[i][bank[i].id].pan = x redraw() end)
    params:add_control("pan slew "..i,"pan slew "..banks[i], controlspec.new(0.,200.,'lin',0.1,5.0))
    params:set_action("pan slew "..i, function(x) softcut.pan_slew_time(i+1,x) end)
    params:add_control("level "..i, "level "..banks[i], controlspec.new(0.,2.,'lin',0.01,1.0))
    params:set_action("level "..i, function(x)
      bank[i][bank[i].id].level = x
      if not bank[i][bank[i].id].enveloped then
        softcut.level(i+1,x)
        softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,bank[i][bank[i].id].pan)*(bank[i][bank[i].id].left_delay_level*bank[i][bank[i].id].level))
        softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,bank[i][bank[i].id].pan)*(bank[i][bank[i].id].right_delay_level*bank[i][bank[i].id].level))
      end
      redraw()
      end)
    params:add_control("start point "..i, "start point "..banks[i], controlspec.new(100,890,'lin',1,100))
    params:set_action("start point "..i, function(x)
      local s_p = bank[i][bank[i].id].start_point - (8*(bank[i][bank[i].id].clip-1))
      local e_p = bank[i][bank[i].id].end_point - (8*(bank[i][bank[i].id].clip-1))
      if s_p <= x/100 and s_p < (e_p - 0.1) then
        bank[i][bank[i].id].start_point = x/100+(8*(bank[i][bank[i].id].clip-1))
      elseif s_p > x/100 then
        bank[i][bank[i].id].start_point = x/100+(8*(bank[i][bank[i].id].clip-1))
      end
      softcut.loop_start(i+1, bank[i][bank[i].id].start_point)
      redraw()
      end)
    params:add_control("end point "..i, "end point "..banks[i], controlspec.new(110,899,'lin',1,150))
    params:set_action("end point "..i, function(x)
      local s_p = bank[i][bank[i].id].start_point - (8*(bank[i][bank[i].id].clip-1))
      local e_p = bank[i][bank[i].id].end_point - (8*(bank[i][bank[i].id].clip-1))
      if e_p >= x/100 and s_p < e_p - 0.1 then
        bank[i][bank[i].id].end_point = x/100+(8*(bank[i][bank[i].id].clip-1))
      elseif e_p < x/100 then
        bank[i][bank[i].id].end_point = x/100+(8*(bank[i][bank[i].id].clip-1))
      end
      softcut.loop_end(i+1, bank[i][bank[i].id].end_point)
      redraw()
      end)
  end
  
  params:add_group("delay params",24)
  
  for i = 4,5 do
    local sides = {"L","R"}
    params:add_control("delay "..sides[i-3]..": global level", "delay "..sides[i-3]..": global level", controlspec.new(0,1,'lin',0,0,""))
    params:set_action("delay "..sides[i-3]..": global level", function(x) softcut.level(i+1,x) redraw() end)
    params:add_option("delay "..sides[i-3]..": rate", "delay "..sides[i-3]..": div/mult", {"x2","x1 3/4","x1 2/3","x1 1/2","x1 1/3","x1 1/4","x1","/1 1/4","/1 1/3","/1 1/2","/1 2/3","/1 3/4","/2"},7)
    params:set_action("delay "..sides[i-3]..": rate", function(x)
      delay[i-3].rate = delay_rates[x]
      delay[i-3].id = x
      local delay_rate_to_time = (60/bpm) * delay_rates[x]
      local delay_time = delay_rate_to_time + (41 + (30*(i-4)))
      delay[i-3].end_point = delay_time
      softcut.loop_end(i+1,delay[i-3].end_point)
      redraw()
      end)
    params:add_control("delay "..sides[i-3]..": feedback", "delay "..sides[i-3]..": feedback", controlspec.new(0,100,'lin',0,50,"%"))
    params:set_action("delay "..sides[i-3]..": feedback", function(x) softcut.pre_level(i+1,(x/100)) redraw() end)
  end
  
  for i = 1,3 do
    local banks = {"a","b","c"}
    params:add_control("delay L: ("..banks[i]..") send", "delay L: ("..banks[i]..") send", controlspec.new(0,1,'lin',0.1,1,""))
    params:set_action("delay L: ("..banks[i]..") send", function(x)
      if bank[i][bank[i].id].enveloped == false then
        softcut.level_cut_cut(i+1,5,x*bank[i][bank[i].id].level)
      end
      for j = 1,16 do
        bank[i][j].left_delay_level = x
      end
    end)
    params:add_control("delay R: ("..banks[i]..") send", "delay R: ("..banks[i]..") send", controlspec.new(0,1,'lin',0.1,1,""))
    params:set_action("delay R: ("..banks[i]..") send", function(x)
      if bank[i][bank[i].id].enveloped == false then
        softcut.level_cut_cut(i+1,6,x*bank[i][bank[i].id].level)
      end
      for j = 1,16 do
        bank[i][j].right_delay_level = x
      end
    end)
  end
  
  --params:add_separator()
  
  for i = 4,5 do
    local sides = {"L","R"}
    params:add_control("delay "..sides[i-3]..": filter cut", "delay "..sides[i-3]..": filter cut", controlspec.new(10,12000,'exp',1,12000,"Hz"))
    params:set_action("delay "..sides[i-3]..": filter cut", function(x) softcut.post_filter_fc(i+1,x) end)
    params:add_control("delay "..sides[i-3]..": filter q", "delay "..sides[i-3]..": filter q", controlspec.new(0.0005, 8.0, 'exp', 0, 1.0, ""))
    params:set_action("delay "..sides[i-3]..": filter q", function(x) softcut.post_filter_rq(i+1,x) end)
    params:add_control("delay "..sides[i-3]..": filter lp", "delay "..sides[i-3]..": filter lp", controlspec.new(0, 1, 'lin', 0, 1, ""))
    params:set_action("delay "..sides[i-3]..": filter lp", function(x) softcut.post_filter_lp(i+1,x) end)
    params:add_control("delay "..sides[i-3]..": filter hp", "delay "..sides[i-3]..": filter hp", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("delay "..sides[i-3]..": filter hp", function(x) softcut.post_filter_hp(i+1,x) end)
    params:add_control("delay "..sides[i-3]..": filter bp", "delay "..sides[i-3]..": filter bp", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("delay "..sides[i-3]..": filter bp", function(x) softcut.post_filter_bp(i+1,x) end)
    params:add_control("delay "..sides[i-3]..": filter dry", "delay "..sides[i-3]..": filter dry", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("delay "..sides[i-3]..": filter dry", function(x) softcut.post_filter_dry(i+1,x) end)
  end
  
  --params:add_separator()
  
  params:add_group("ignore",18)
  params:hide(124)
  
  --params:add{type = "trigger", id = "ignore", name = "ignore, data only:"}
  
  for i = 1,3 do
    local banks = {"(a)", "(b)", "(c)"}
    params:add_control("filter "..i.." cutoff", "filter "..banks[i].." cutoff", controlspec.new(10,12000,'lin',1,12000,"Hz"))
    params:set_action("filter "..i.." cutoff", function(x) softcut.post_filter_fc(i+1,x) bank[i][bank[i].id].fc = x end)
    params:add_control("filter "..i.." q", "filter "..banks[i].." q", controlspec.new(0.0005, 8.0, 'exp', 0, 0.32, ""))
    params:set_action("filter "..i.." q", function(x)
      softcut.post_filter_rq(i+1,x)
      for j = 1,16 do
        bank[i][j].q = x
      end
    end)
    params:add_control("filter "..i.." lp", "filter "..banks[i].." lp", controlspec.new(0, 1, 'lin', 0, 1, ""))
    params:set_action("filter "..i.." lp", function(x) softcut.post_filter_lp(i+1,x) bank[i][bank[i].id].lp = x end)
    params:add_control("filter "..i.." hp", "filter "..banks[i].." hp", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("filter "..i.." hp", function(x) softcut.post_filter_hp(i+1,x) bank[i][bank[i].id].hp = x end)
    params:add_control("filter "..i.." bp", "filter "..banks[i].." bp", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("filter "..i.." bp", function(x) softcut.post_filter_bp(i+1,x) bank[i][bank[i].id].bp = x end)
    params:add_control("filter "..i.." dry", "filter "..banks[i].." dry", controlspec.new(0, 1, 'lin', 0, 0, ""))
    params:set_action("filter "..i.." dry", function(x) softcut.post_filter_dry(i+1,x) bank[i][bank[i].id].fd = x end)
  end
  
end

return start_up