
function string.is_found_in(str, table)
	for i,j in pairs(table) do
		if str:includes(j) then
			return j
		end
	end
	return false
end

function string.starts_with(str, with)
	return str:match("^" .. with) == with
end

function string.get_before(str, with)
	return str:match("^.*"..with)
end

function string.get_after(str, with)
	local _, e = str:find(with,1,true)
	return str:match(".*$",e+1)
end

function string.includes(str, this)
	found,_ = str:find(this,1,true) or 0
	return found > 0
end

function string.get_pos(str, this)
	return str:find(this,1,true) or 0
end

function string.rjust(str, len, pad)
	str = str or ""
	if string.len(str) >= len then
	 	return str
	else
		return string.rjust(pad .. str, len, pad)
	end
end

function string.ljust(str, len, pad)
	str = str or ""
	if string.len(str) >= len then
	 	return str
	else
		return string.ljust(str .. pad, len, pad)
	end
end

function string.center(str, len, pad)
	str = str or ""
	if string.len(str) >= len then
		return str
	else
		return string.center(pad .. str .. pad, len, pad)
	end
end

function string.plural(str, int)
	if int==1 then
		return str
	else
		return str .. "s"
	end
end

-- "bla xx yy"
-- "123456789"
-- "s  e"
-- "bla " en "xx yy""

function string.split(str, sep)
	sep = sep or "%s"
	t = {}
	i = 1
	for s in string.gmatch(str, "([^"..sep.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end

function string.dice(str)
	t = {}
	for c=1, #str do
		t[c] = string.char(str:byte(c))
	end
	return t
end

