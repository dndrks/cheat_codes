local tracktions = {}
t = tracktions

function tracker_init(target)
    tracker[target] = {}
    tracker[target].step = 1
    tracker[target].start_point = 1
    tracker[target].end_point = 1
    tracker[target].recording = false
    tracker[target].max_memory = 128
    for i = 1,tracker[target].max_memory do
      tracker[target][i] = {}
      for j = 1,3 do
        tracker[target][i][j] = nil
      end
    end
  end
  
  tracker = {}
  for i = 1,3 do
    tracker_init(i)
  end
  
  function snake_tracker(target,mode)
    if #tracker[target] > 0 then
      clear_tracker(target)
    end
    for i = 1,16 do
      tracker[target][i] = {}
      tracker[target][i][1] = snakes[mode][i]
      tracker[target][i][2] = 1/4
      tracker[target][i][3] = "next"
    end
    tracker[target].end_point = #tracker[target]
    tracker[target].clock = clock.run(tracker_advance,target)
  end
  
  function add_to_tracker(target,entry)
    table.remove(tracker[target],page.track_sel[page.track_page])
    table.insert(tracker[target],page.track_sel[page.track_page],entry)
    local reasonable_max = nil
    for i = 1,tracker[target].max_memory do
      --if tracker[page.track_page][i][1] ~= nil and tracker[page.track_page][i][2] ~= nil then
      if tracker[page.track_page][i][1] ~= nil then
        reasonable_max = i
      end
    end
    tracker[target].end_point = reasonable_max
    page.track_sel[page.track_page] = page.track_sel[page.track_page] + 1
    redraw()
  end
  
  function append_to_tracker() -- TODO add arguments
    if page.track_sel[page.track_page] > tracker[page.track_page].end_point then
      tracker[page.track_page].end_point = page.track_sel[page.track_page]
    end
  end
  
  function remove_from_tracker(target,entry)
    table.remove(tracker[target],page.track_sel[page.track_page])
    redraw()
  end
  
  function clear_tracker(target)
    clock.cancel(tracker[target].clock)
    tracker_init(target)
  end
  
  function stop_tracker(target)
    clock.cancel(tracker[target].clock)
  end
  
  function tracker_transport(target)
    tracker[target].clock = clock.run(tracker_advance,target)
  end
  
  function tracker_advance(target)
    while true do
      if #tracker[target] > 0 then
        local step = tracker[target].step
        tracker_cheat(target,step)
        clock.sync(tracker[target][step][2])
        --tracker_action(tracker[1][tracker.step][3])
        tracker[target].step = tracker[target].step + 1
        if tracker[target].step > tracker[target].end_point then
          tracker[target].step = tracker[target].start_point
        end
      end
      redraw()
    end
  end
  
  function tracker_sync(target)
    tracker[target].step = tracker[target].start_point - 1
  end
  
  function tracker_cheat(target,step)
    bank[target].id = tracker[target][step][1]
    selected[target].x = (5*(target-1)+1)+(math.ceil(bank[target].id/4)-1)
    if (bank[target].id % 4) ~= 0 then
      selected[target].y = 9-(bank[target].id % 4)
    else
      selected[target].y = 5
    end
    cheat(target,bank[target].id)
  end
  
  function tracker_copy_prev(source,destination)
    for k,v in pairs(source) do
      destination[k] = v
    end
    redraw()
  end

  return tracker