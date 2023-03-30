local input = { 'one', 'two', 'three', 'four', 'five', 'six' }
local expected = {'one', 'four', 'five', 'six'}

local closed = 0
local function closable()
  return setmetatable( {}, {
      __close = function()
        closed = closed + 1
      end
    } )
end

-- Test Case 1 --
do
  local odds = {}
  local expected_idx = 0
  for i = 1, 10 do
    if i % 2 == 0 then continue end
    expected_idx = expected_idx + 1
    odds[expected_idx] = i
  end
  assert( #odds == 5 )
  assert( odds[1] == 1 )
  assert( odds[2] == 3 )
  assert( odds[3] == 5 )
  assert( odds[4] == 7 )
  assert( odds[5] == 9 )
end

-- Test Case 2: repeat/until --
do
  local idx = 0
  local expected_idx = 0
  closed = 0
  repeat
    idx = idx + 1
    print( idx, input )
    local word = input[idx]
    local _<close> = closable()
    if word:sub( 1, 1 ) == 't' then continue end
    expected_idx = expected_idx + 1
    assert( word == expected[expected_idx] )
  until idx >= 6
  assert( idx == 6 )
  assert( expected_idx == 4 )
  assert( closed == 6 )
end

-- Test Case 3: while/end --
do
  local idx = 0
  local expected_idx = 0
  closed = 0
  while idx < 6 do
    idx = idx + 1
    local word = input[idx]
    local _<close> = closable()
    if word:sub( 1, 1 ) == 't' then continue end
    expected_idx = expected_idx + 1
    assert( word == expected[expected_idx] )
  end
  assert( idx == 6 )
  assert( expected_idx == 4 )
  assert( closed == 6 )
end

-- Test Case 4: for/end --
do
  local expected_idx = 0
  closed = 0
  for idx, word in ipairs( input ) do
    local _<close> = closable()
    if word:sub( 1, 1 ) == 't' then continue end
    expected_idx = expected_idx + 1
    assert( word == expected[expected_idx] )
  end
  assert( expected_idx == 4 )
  assert( closed == 6 )
end

-- Test Case 5: for/end non-optimized if/continue. --
do
  local expected_idx = 0
  local continued = 0
  closed = 0
  for idx, word in ipairs( input ) do
    local _<close> = closable()
    if word:sub( 1, 1 ) == 't' then
      continued = continued + 1
      continue
    end
    expected_idx = expected_idx + 1
    assert( word == expected[expected_idx] )
  end
  assert( expected_idx == 4 )
  assert( closed == 6 )
  assert( continued == 2 )
end

-- Test Case 5: continue past local variable. --
do
  local expected_idx = 0
  local continued = 0
  closed = 0
  for idx, word in ipairs( input ) do
    local _<close> = closable()
    if word:sub( 1, 1 ) == 't' then
      continued = continued + 1
      continue
    end
    local c = 1
    expected_idx = expected_idx + 1
    assert( word == expected[expected_idx] )
  end
  assert( expected_idx == 4 )
  assert( closed == 6 )
  assert( continued == 2 )
end

-- Finished.
return 123