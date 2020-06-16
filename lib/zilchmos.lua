local zilchmos = {}
local z = zilchmos

--[[
    which_bank is a global & being set from inside of here
    bpm
    grid_alt should be boolean
]]--

zilchmos.sc = {}

---------------------------------------
--- main function

-- this is the new zilchmos.init
function zilchmos.init(k,i)
  -- for .help functionality
  which_bank = i -- FIXME should be in the help. namespace
  if menu == 11 then
    help_menu = "zilchmo_"..k
  end


  local b = bank[i] -- just alias for shorter lines
  local p = b.focus_hold and b.focus_pad or b.id -- was 'which_pad'

  -- TODO fingers should be passed in as an argument, not globally accessed
  local finger    = fingers[k][i].con
  local p_action  = z.actions[k][finger][1]
  local sc_action = z.actions[k][finger][2]

  -- here's where we call the action
  --if grid.alt == 0 then
  if not b.alt_lock and grid.alt == 0 then
    p_action( b[p] )
    --trackers.inherit(which_bank,p)
  elseif b.alt_lock or grid.alt == 1 then
    z.map( p_action, b ) -- or map it over the whole bank
  end
  if not b.focus_hold then
    sc_action( b[p], i ) -- and then update softcut if we're in perform mode
  end
end

-- this function tanks a single bank, and applies function fn to each pad
function zilchmos.map( fn, bank ) -- this is a local bank, represents bank[i]
  for i=1,16 do -- will execute for each of the 16 elements in bank
    fn( bank[i] ) -- pass each pad to the supplied function
    --trackers.inherit(which_bank,i)
  end
end


-- pad helpers

function z.level_down( pad ) z.level_inc( pad, -0.125 ) end
function z.level_up( pad )   z.level_inc( pad, 0.125 ) end
function z.pan_left( pad )   z.pan( pad, -1 ) end
function z.pan_center( pad ) z.pan( pad, 0 ) end
function z.pan_right( pad )  z.pan( pad, 1 ) end
function z.pan_nudge_left( pad )  z.pan_nudge( pad, -0.1 ) end
function z.pan_nudge_right( pad ) z.pan_nudge( pad, 0.1 ) end
function z.rate_double( pad )  z.rate_mul( pad, 2 ) end
function z.rate_halve( pad )   z.rate_mul( pad, 0.5 ) end
function z.rate_reverse( pad ) z.rate_mul( pad, -1 ) end
function z.loop_sync_left( pad )  z.loop_sync( pad, -1 ) end
function z.loop_sync_right( pad ) z.loop_sync( pad, 1 ) end

-- core pad modifiers

function zilchmos.level_inc( pad, delta )
  pad.level = util.clamp( pad.level + delta, 0, 2 )
end

function zilchmos.pan_reverse( pad )
  pad.pan = -pad.pan
end

function zilchmos.play_toggle( pad )
  pad.pause = not pad.pause
end

function zilchmos.pan( pad, position )
  pad.pan = position
end

function zilchmos.pan_nudge( pad, delta )
  pad.pan = util.clamp( pad.pan + delta, -1, 1 )
end

function zilchmos.pan_random( pad )
  pad.pan = math.random(-100,100)/100
end

function zilchmos.start_zero( pad )
  pad.start_point = (8*(pad.clip-1)) + 1
end

function zilchmos.start_end_default( pad )
  pad.start_point = 1+((8/16) * (pad.pad_id-1)) + (8*(pad.clip-1))
  pad.end_point   = 1+((8/16) *  pad.pad_id)    + (8*(pad.clip-1))
end

function zilchmos.start_end_sixteenths( pad )
  -- FIXME bpm is global
  pad.start_point = (1+((8/16)*(pad.pad_id-1)))+(8*(pad.clip-1))
  pad.end_point   = pad.start_point + (60/bpm)/4
end

function zilchmos.end_at_eight( pad )
  pad.end_point = (8*pad.clip)+1
end

function zilchmos.start_random( pad )
  local current_end = math.floor(pad.end_point * 100)
  local min_start = math.floor(((8*(pad.clip-1))+1) * 100)
  pad.start_point = math.random(min_start,current_end)/100
end

function zilchmos.end_random( pad )
  local current_start = math.floor(pad.start_point * 100)
  local max_end = nil
  --if params:get("zilchmo_bind_rand") == 1 then
    max_end = math.floor(((8*pad.clip)+1) * 100)
  --else
    --max_end = math.floor(rec.end_point * 100)
  --end
  pad.end_point = math.random(current_start,max_end)/100
end


function zilchmos.start_end_random( pad )
  local jump = math.random(100,900)/100+(8*(pad.clip-1))
  local current_difference = (pad.end_point - pad.start_point)
  if jump+current_difference >= 9+(8*(pad.clip-1)) then
    pad.end_point = 9+(8*(pad.clip-1))
    pad.start_point = pad.end_point - current_difference
  else
    pad.start_point = jump
    pad.end_point = pad.start_point + current_difference
  end
end

function zilchmos.loop_double( pad )
  local double = (pad.end_point - pad.start_point)*2
  local maximum_val = 9+(8*(pad.clip-1))
  local minimum_val = 1+(8*(pad.clip-1))
  if pad.start_point - double >= minimum_val then
    pad.start_point = pad.end_point - double
  elseif pad.start_point - double < minimum_val then
    if pad.end_point + double < maximum_val then
      pad.end_point = pad.end_point + double
    end
  end
end

function zilchmos.loop_halve( pad )
  local quarter = ((pad.end_point - pad.start_point)/2)/2
  pad.start_point = pad.start_point + quarter
  pad.end_point   = pad.end_point - quarter
end

function zilchmos.loop_sync( pad, dir )
  local src_bank_num = (pad.bank_id-1 + dir)%3 + 1
  local src_bank     = bank[src_bank_num] -- FIXME global access of bank
  local src_pad      = src_bank[src_bank.id]
  -- shift start/end by the difference between clips
  pad.start_point = src_pad.start_point + 8*(pad.clip - src_pad.clip)
  pad.end_point   = src_pad.end_point   + 8*(pad.clip - src_pad.clip)
end

function zilchmos.rate_mul( pad, mul )
  pad.rate = pad.rate * mul
  -- NOTE: here we ensure speed doesn't surpass 4, but don't clamp, drop an octave
  if math.abs(pad.rate) > 4     then pad.rate = pad.rate / 2 end
  if math.abs(pad.rate) < 0.125 then pad.rate = pad.rate * 2 end
end

function zilchmos.rate_up_fifth( pad )
  -- should a 'raise-a-fifth' command fail if exceeds 4x, or raise fifth then drop oct
  -- how to handle release from raising
  if math.abs(pad.rate) < 4 then
    if pad.fifth then
      pad.rate = pad.rate < 0 and math.ceil(math.abs(pad.rate)) * -1 or pad.rate > 0 and math.ceil(math.abs(pad.rate))
      pad.fifth = false
      if math.abs(pad.rate) == 3 then
        pad.rate = pad.rate == 3 and 4 or pad.rate == -3 and -4
      end
    else
      pad.rate  = pad.rate*1.5
      pad.fifth = true
    end
  end
end


-- softcut

function zilchmos.sc.level( pad, i )
  if not pad.enveloped then
    softcut.level_slew_time(i+1,1.0)
    softcut.level(i+1,pad.level)
    softcut.level_cut_cut(i+1,5,util.linlin(-1,1,0,1,pad.pan)*(pad.left_delay_level*pad.level))
    softcut.level_cut_cut(i+1,6,util.linlin(-1,1,1,0,pad.pan)*(pad.right_delay_level*pad.level))
  end
end

function zilchmos.sc.play_toggle( pad, i )
  if pad.pause then
    softcut.level(i+1, 0.0)
    softcut.rate(i+1, 0.0)
  else
    if pad.enveloped then
      cheat( i, pad.pad_id )
    else
      softcut.level(i+1, pad.level)
    end
    softcut.rate(i+1, pad.rate * pad.offset)
  end
end

function zilchmos.sc.pan( pad, i )
  softcut.pan(i+1,pad.pan)
end

function zilchmos.sc.start( pad, i )
  softcut.loop_start(i+1,pad.start_point)
end

function zilchmos.sc.start_end( pad, i )
  softcut.loop_start(i+1,pad.start_point)
  softcut.loop_end(i+1,pad.end_point)
end

function zilchmos.sc._end( pad, i )
  softcut.loop_end(i+1,pad.end_point)
end

function zilchmos.sc.rate( pad, i )
  if pad.pause == false then
    softcut.rate(i+1, pad.rate*pad.offset)
  end
end

function zilchmos.sc.sync( pad, i )
  zilchmos.sc.start_end( pad, i )
  softcut.position(i+1, pad.start_point )
end

function zilchmos.sc.cheat( pad, i, p )
  if pad.loop and not pad.enveloped then
    cheat( i, pad.pad_id )
  end
end


--------------------------------------
--- actions


-- mapping of key-combos to pad functions & softcut actions
-- TODO the softcut actions should occur automatically using metatable over pad{}
zilchmos.actions =
{ [2] = -- level & play/pause
  { ['1']  = { z.level_down   , z.sc.level }
  , ['2']  = { z.level_up     , z.sc.level }
  , ['12'] = { z.play_toggle  , z.sc.play_toggle }
  }
, [3] = -- panning
  { ['1']   = { z.pan_left        , z.sc.pan }
  , ['2']   = { z.pan_center      , z.sc.pan }
  , ['3']   = { z.pan_right       , z.sc.pan }
  , ['12']  = { z.pan_nudge_left  , z.sc.pan }
  , ['23']  = { z.pan_nudge_right , z.sc.pan }
  , ['13']  = { z.pan_reverse     , z.sc.pan }
  , ['123'] = { z.pan_random      , z.sc.pan }
  }
, [4] = -- start/end points, rate, direction
  { ['1']    = { z.start_zero           , z.sc.start }
  , ['2']    = { z.start_end_default    , z.sc.start_end }
  , ['3']    = { z.start_end_sixteenths , z.sc.start_end }
  , ['4']    = { z.end_at_eight         , z.sc._end }
  , ['12']   = { z.start_random         , z.sc.cheat }
  , ['34']   = { z.end_random           , z.sc._end }
  , ['23']   = { z.start_end_random     , z.sc.start_end }
  , ['13']   = { z.loop_double          , z.sc.start_end }
  , ['24']   = { z.loop_halve           , z.sc.start_end }
  , ['123']  = { z.loop_sync_left       , z.sc.sync }
  , ['234']  = { z.loop_sync_right      , z.sc.sync }
  , ['124']  = { z.rate_double          , z.sc.rate }
  , ['134']  = { z.rate_halve           , z.sc.rate }
  , ['14']   = { z.rate_reverse         , z.sc.rate }
  , ['1234'] = { z.rate_up_fifth        , z.sc.rate }
  }
}


return zilchmos
