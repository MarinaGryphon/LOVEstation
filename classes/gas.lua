require( "classes.utilities" );

chem = { name = "Oxygen", sph = .919 };

 -- Q = mcT
 -- T = delta - temperature ( KELVINS )
 -- m = mass
 -- c = specific heat
 -- Q = energy in joules

 -- T = Q/( mc )

function chem.new( n, s )
	local o = { name = n, sph = s };
	setmetatable( o, { __index = chem } );
	return o;
end


chems = {};
chems[1] = chem.new();
chems[2] = chem.new( "Nitrogen", 1.040 );
chems[3] = chem.new( "Phoron", 200 );
chems[4] = chem.new( "Carbon Dioxide", 0.846 );

gas = { chem = chems[2], moles = 107, pressure = 81.06, temperature = 293.15 }; --moles of chemicals; pressure in kPa; temperature in Kelvins; 107 mol of nitrogen at 81.06 kPa and 20 degrees Celsius.

 -- volume is always 3 cubic meters per tile, 1x1x3 meters or about 3x3x9 feet

function gas.new( chem, m, p, t )
	local o = { chem = chem, moles = m, pressure = p, temperature = t };
	setmetatable( o, { __index = gas } );
	return o;
end

function gas.add( self, moles )
	self.moles = self.moles + moles;
	self.pressure = ( 8.31*self.temperature*self.moles)/3000; --to raise by 10 kPa, at constant temperature and volume, you'd need: (8.31*273.15n )/3000 mol	
end

 -- PV = nRT
 -- P = ( nRT )/V

 -- PV = nRT
 -- V is constant per tile, 3 meters = 3000 L
 -- P = ( nRT )/3
 -- R = 8.31
 -- P = ( 8.31nT )/3


air = { gases = {}, pressure = 101.325, lastUpdate =- 1 }; --pressure is calculated each tick, from partial pressures
air.gases[chems[2].name], air.gases[chems[1].name], air.gases[chems[3].name], air.gases[chems[4].name] = gas.new( chems[2]), gas.new(chems[1], 26.75, 20.265), gas.new(chems[3], 0, 0, 0, 0 ), gas.new(chems[4], 0, 0, 0, 0 );

function air.new(g)
	local o = { gases = {} };
	setmetatable( o, { __index = air } );
	setmetatable( o.gases, { __index = air.gases } );
	if g then
		for k, v in pairs(g) do
			o.gases[v.chem.name] = v;
			setmetatable( o.gases[v.chem.name], gas );
		end
	end
	return o
end

function air.remove( self, percent )
	local mult = 1 - ( percent/100 );
	for k, v in ipairs( chems ) do
		self.gases[v.name].moles = self.gases[v.name].moles * mult;
		self.gases[v.name].pressure = self.gases[v.name].pressure * mult;
	end
end

function air.avg( airs ) --average a ton of airs
	local tmp = air.new( {} );
	local gss = {};
	local newgas = {};
	if airs == 0 then
		return;
	end
	for k, v in ipairs( airs ) do
		tmp.pressure = tmp.pressure + v.pressure;
		for b, c in ipairs( chems ) do
			if not gss[c.name] then
				gss[c.name] = {}
			end
			table.insert( gss[c.name], v.gases[c.name] );
		end
	end
	for k, v in ipairs( chems ) do
		newgas[v.name] = gas.avg( gss[v.name] );
	end
	tmp.pressure = tmp.pressure / #airs; --average!!
	tmp.gases = table.copy( newgas );
	tmp:update();
	return tmp;
end

function gas.avg( gases ) --average a bunch of gases
	if #gases > 1 then
		local g = { chem = gases[1].chem.name, moles = 0, temperature = 0, pressure = 0 };
		setmetatable( g, { __index = gas } );
		for k, v in ipairs( gases ) do
			g.moles = g.moles + ( v.moles/#gases );
			g.temperature = g.temperature + ( v.temperature/#gases );
			g.pressure = g.pressure + ( v.pressure/#gases );
		end
		return g;
	else
		return gases[1];
	end
end

function air.update( self )
	self.pressure = 0;
	self.lastUpdate = os.time();
	for k, v in pairs( self.gases ) do
		 -- v:update();
		self.pressure = self.pressure + self:getChemPressure(k); --woo partial pressure law thanks dalton
	end
end

function air.getChemPressure( self, chem )
	return self.gases[chem].pressure;
end