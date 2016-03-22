local o = {}

local function compare(a, b)
	return a > b
end

function o.insertSorted(t, a, comp)
	comp = comp or compare
	for i, b in ipairs(t) do
		if comp(b, a) then
			table.insert(t, i, a)
			return
		end
	end
	table.insert(t, a)
end

function o.remove(t, a)
	for i, b in ipairs(t) do
		if a == b then
			table.remove(t, i)
			return true
		end
	end
	return false
end

return o
