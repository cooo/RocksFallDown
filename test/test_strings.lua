----------------------------------------------------------------------
-- testing:
-- run with: lua strings.lua
----------------------------------------------------------------------
require("lib/strings")

local tests = 0
local fail = 0
local function test(func, expect)
	tests = tests + 1
	
	if (type(expect)=="table") then
		local table_ok = true
		for i,j in pairs(func) do
			if not (j == expect[i]) then
				table_ok = false
				print(j .. " is not " .. expect[i])
			end
		end
		if table_ok then
			io.write(".")
		else
			io.write("F")
			fail = fail + 1
		end
	else
		if not (func == expect) then
			io.write("F")
			fail = fail + 1
			print("expected  " ..  tostring(expect) .. " got " .. tostring(func))
		else
			io.write(".")
		end
	end
end

local numbers = { "1", "2", "3"}
test(string.is_found_in("1", numbers), "1"  )
test(string.is_found_in("4", numbers), false)

test(string.starts_with("blabla", "b"   ), true )
test(string.starts_with("blavla", "bla" ), true )
test(string.starts_with("blavla", "blah"), false)
test(string.starts_with("blabla", "l"   ), false)


test(string.get_pos("10 0", " "), 3 )
test(string.get_pos("10 0", "a"), 0 )

test(string.get_after("bla=this",  "bla="), "this" )
test(string.get_after("bla=bla",   "bla="), "bla"  )
test(string.get_after("bla=10 0",  "bla="), "10 0" )

test(string.includes("abc",     "b"   ), true )
test(string.includes("abc",     "d"   ), false)
test(string.includes("abc",     "ab"  ), true )
test(string.includes("abc",     "abc" ), true )
test(string.includes("abc",     "abcd"), false)
test(string.includes("bla=bla", "bla="), true )
test(string.includes("bla=bla", "=bla"), true )

test(string.rjust("12",  6, "0" ), "000012")
test(string.rjust("12",  6, "01"), "010112")
test(string.rjust("12",  2, "0" ), "12"    )
test(string.rjust("123", 2, "0" ), "123"   )
test(string.rjust(nil,   2, "0" ), "00"    )

test(string.ljust("12",  6, "0" ), "120000")
test(string.ljust("12",  6, "01"), "120101")
test(string.ljust("12",  2, "0" ), "12"    )
test(string.ljust("123", 2, "0" ), "123"   )
test(string.ljust("hi",  6, " " ), "hi    ")
test(string.ljust(nil,   2, "0" ), "00"    )

test(string.center("1",   6, "0" ), "0001000")
test(string.center("12",  6, "0" ), "001200")
test(string.center("12",  6, " " ), "  12  ")
test(string.center("123", 2, "0" ), "123"   )
test(string.center("hi",  6, " " ), "  hi  ")
test(string.center(nil,   2, "0" ), "00"    )


test(string.split("1,2", ","), {"1" , "2"} )
test(string.split("1 2"), {"1" , "2"} )
test(string.split("1"), {"1"} )

test(string.dice("1"), {"1"} )
test(string.dice("12345"), {"1", "2", "3", "4", "5"} )
test(string.dice("12 45"), {"1", "2", " ", "4", "5"} )

print()
print((tests - fail) .. " / " .. tests .. ". " .. fail .. " failed " .. string.plural("test", fail))