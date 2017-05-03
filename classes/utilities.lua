function table.copy( t )
	local copy = { };
	for k, v in pairs( t ) do
		copy[k] = v;
		if type( copy[k] ) == "table" then
			copy[k] = table.copy(v);
		end
	end
	setmetatable( copy, getmetatable( t ) );
	return copy;
end