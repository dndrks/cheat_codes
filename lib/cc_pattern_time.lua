--- pattern
-- @classmod pattern

local pattern = {}
pattern.__index = pattern

--- constructor
function pattern.new()
  local i = {}
  setmetatable(i, pattern)
  i.rec = 0
  i.play = 0
  i.overdub = 0
  i.prev_time = 0
  i.over_time = 0
  i.curr_time = {}
  i.event = {}
  i.time = {}
  i.count = 0
  i.step = 0
  i.time_factor = 1
  i.loop = 1
  i.start_point = 0
  i.end_point = 0
  i.clock = nil
  i.clock_time = 1

  i.metro = metro.init(function() i:next_event() end,1,1)

  i.process = function(_) print("event") end

  return i
end

--- clear this pattern
function pattern:clear()
  self.metro:stop()
  self.rec = 0
  self.play = 0
  self.overdub = 0
  self.prev_time = 0
  self.over_time = 0
  self.curr_time = {}
  self.event = {}
  self.time = {}
  self.count = 0
  self.step = 0
  self.time_factor = 1
  self.start_point = 0
  self.end_point = 0
  self.clock = nil
  self.clock_time = 1
end

--- adjust the time factor of this pattern.
-- @tparam number f time factor
function pattern:set_time_factor(f)
  self.time_factor = f or 1
end

--- start recording
function pattern:rec_start()
  print("pattern rec start")
  self.rec = 1
end

--- stop recording
function pattern:rec_stop()
  if self.rec == 1 then
    self.rec = 0
    if self.count ~= 0 then
      print("count "..self.count)
      local t = self.prev_time
      self.prev_time = util.time()
      self.time[self.count] = self.prev_time - t
      self.start_point = 1
      self.end_point = self.count
      --tab.print(self.time)
    else
      print("no events recorded")
    end 
  else print("not recording")
  end
end

--- watch
function pattern:watch(e)
  if self.rec == 1 then
    self:rec_event(e)
  elseif self.overdub == 1 then
    self:overdub_event(e)
  end
end

--- record event
function pattern:rec_event(e)
  local c = self.count + 1
  if c == 1 then
    self.prev_time = util.time()
    --print("first event")
  else
    local t = self.prev_time
    self.prev_time = util.time()
    self.time[c-1] = self.prev_time - t
    --print(self.time[c-1])
  end
  self.count = c
  self.event[c] = e
end

function pattern:overdub_event(e)
  local c = self.step + 1
  local t = self.prev_time
  self.prev_time = util.time()
  local a = self.time[c-1]
  self.time[c-1] = self.prev_time - t
  table.insert(self.time, c, a - self.time[c-1])
  table.insert(self.event, c, e)
  --midi_clock_linearize_overdub(1)
  self.step = self.step + 1
  self.count = self.count + 1
  self.end_point = self.count
end

--- start this pattern
function pattern:start()
  --if self.count > 0 then
  if self.count > 0 and self.rec == 0 then
    --print("start pattern ")
    self.prev_time = util.time()
    self.process(self.event[self.start_point])
    self.play = 1
    self.step = self.start_point
    self.metro.time = self.time[self.start_point] * self.time_factor
    self.metro:start()
  end
end

--- process next event
function pattern:next_event()
  local diff = nil
  self.prev_time = util.time()
  if self.count == self.end_point then diff = self.count else diff = self.end_point end
  if self.step == diff and self.loop == 1 then
    self.step = self.start_point
  elseif self.step > diff and self.loop == 1 then
    self.step = self.start_point
  else
    self.step = self.step + 1
  end
  self.process(self.event[self.step])
  self.metro.time = self.time[self.step] * self.time_factor
  self.curr_time[self.step] = util.time()
  --print("next time "..self.metro.time)
  if self.step == diff and self.loop == 0 then
    if self.play == 1 then
      self.play = 0
      self.metro:stop()
    end
  else
    self.metro:start()
  end
end

--- stop this pattern
function pattern:stop()
  if self.play == 1 then
    --print("stop pattern ")
    self.play = 0
    self.overdub = 0
    self.metro:stop()
  else
    --print("not playing")
  end
end

function pattern:set_overdub(s)
  if s == 1 and self.play == 1 and self.rec == 0 then
    self.overdub = 1
  else
    self.overdub = 0
  end
end

--[[

function pattern:start_synced_loop()
  self.clock = clock.run(self.synced_loop)
end

function pattern:synced_loop()
  clock.sync(4)
  while true do
    clock.sync(8)
    self.metro:stop()
    self.metro:start()
  end
end

--]]

return pattern