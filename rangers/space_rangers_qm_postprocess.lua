function luaEscapes(s)
	return s:gsub("%^", "\\^"):gsub("\n","^"):gsub("\r",""):gsub("{([^}]+)}","$|%1|");
end

function postprocess(o)
	for k, v in pairs(o) do
		if k ~= "_root" and k ~= "_io" and k ~= "_parent" then
			if type(v) == "table" then
				postprocess(v)
			end
			-- ordering matters! cond strings contain just strings within them
			if type(v) == "table" and type(v.size) == "number" then
				-- print(k, "may be SR string")
				-- it may be an SR string
				s = v.value
				if type(s) == "string" or type(s) == "nil" then
					-- it IS an SR string
					if v.size ~= 0 then
						v = luaEscapes(s)
					else
						-- the original function sets them to nil and the script relies on this
						v = nil
					end
					o[k] = v
				end
			end
			if type(v) == "table" and type(v.present) == "number" then
				-- print(k, "may be a cond SR string")
				-- it may be an SR cond string
				s = v.str
				if type(s) == "string" or type(s) == "nil" then
					-- it IS a cond SR string
					-- print(k, "IS a cond SR string")
					v = s
					o[k] = v
				end
			end
		end
	end
end
return postprocess
