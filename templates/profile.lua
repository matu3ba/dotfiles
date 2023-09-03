local time_start = os.time()

--------------------------------------
-- Your script is here
-- For example, just spend 5 seconds in CPU busy loop
repeat until os.clock() > 5
-- or call some external file containing your original script:
-- dofile("path/to/your_original_script.lua")
--------------------------------------

local mem_KBytes = collectgarbage("count") -- memory currently occupied by Lua
local CPU_seconds = os.clock()                  -- CPU time consumed
local runtime_seconds = os.time() - time_start  -- "wall clock" time elapsed
print(mem_KBytes, CPU_seconds, runtime_seconds)
-- Output to stdout: 24.0205078125  5.000009  5
