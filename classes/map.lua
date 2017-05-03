require( "classes.tile" );
require( "classes.objects" );
require( "classes.utilities" );
map = { width = 10, height = 10, wmap = {}, tmp = {}, done = {} };
for x = 1, 10 do --generate the default wmap ( world map )
	map.wmap[x] = {};
	for y = 1, 10 do
		map.wmap[x][y] = { tile = tiles[1]:dup(  ), contents = {} };
	end
end

function map.floodfill( self, x, y ) --orthogonal flood fill
	if self.wmap[x][y].tile.opaque then 	
		 -- don't add opaque tiles or search from them
		return;
	end
	for k, v in ipairs( self.wmap[x][y].contents ) do
		if v.opaque then
			return;
		end
	end
	table.insert( self.tmp, { x = x, y = y } );
	if not self.done[x] then
		self.done[x] = {};
	end
	if not self.done[x - 1] then
		self.done[x - 1] = {};
	end
	if not self.done[x + 1] then
		self.done[x + 1] = {};
	end
	self.done[x][y] = 1;
	if not self.done[x - 1][y] then
		if self:inBounds( x - 1, y ) then
			self:floodfill( x - 1, y );
		end
	end
	if not self.done[x + 1][y] then
		if self:inBounds( x + 1, y ) then
			self:floodfill( x + 1, y );
		end
	end
	if not self.done[x][y - 1] then
		if self:inBounds( x, y - 1 ) then
			self:floodfill( x, y - 1 );
		end
	end
	if not self.done[x][y + 1] then
		if self:inBounds( x, y + 1 ) then
			self:floodfill( x, y + 1 );
		end
	end
	return;
end

function map.updateAtmos( self, x, y, accel )
	self.tmp, self.done = {  }, {  };
	self.spaces = {  };
	local airs = {  };
	local checkspace = false;
	self:floodfill( x, y );
	if #self.tmp > 0 then
		for k, v in ipairs( self.tmp ) do
			if self.wmap[v.x][v.y].tile.name == "Space" then
				self.wmap[v.x][v.y].tile.air:update(  );
				self.wmap[v.x][v.y].tile.air:remove( 100 );
				if not self.spaces[v.x] then
					self.spaces[v.x] = {};
				end
				self.spaces[v.x][v.y] = true;
			else
				if math.floor(self.wmap[v.x][v.y].tile.air.pressure) ~= 0 then
					checkspace = true;
				end
			end
			table.insert( airs, self.wmap[v.x][v.y].tile.air );
		end
		local newair = airs;
		local nair;
		for i=1, accel or 1 do
			nair = air.avg( newair );
			newair = {}
			for k,v in ipairs(self.tmp) do
				table.insert(newair,nair);
			end
		end
		local newair = nair;
		for k, v in ipairs( self.tmp ) do
			if self.wmap[v.x][v.y].tile.air.lastUpdate < os.time(  ) then
				if not newair then error( "oh no" ); end
				self.wmap[v.x][v.y].tile.air = table.copy( newair );
				self.wmap[v.x][v.y].tile.air:update(  );
				self.wmap[v.x][v.y].tile.air.lastUpdate = os.time(  );
			end
		end
	end
	local dummy;
	for k,v in pairs(self.spaces) do
		dummy = true;
		break;
	end
	return dummy and checkspace;
end

function map.new( w, h, wmap )
	local o = { width = w, height = h, wmap = wmap };
	setmetatable( o, { __index = map } );
	return o;
end

function map.randomMap( self )
	for x = 1, self.width do
		self.wmap[x] = {}
		for y = 1, self.height do
			local tpe = math.random( 1, 100 );
			if tpe == 1 then --1% chance of space for every tile
				self.wmap[x][y] = { tile = tiles[1]:dup(  ), contents = {} };
			elseif tpe <= 41 then --40% chance of walls
				self.wmap[x][y] = { tile = tiles[3]:dup(  ), contents = {} };
			elseif tpe <= 96 then --55% chance of plating.
				self.wmap[x][y] = { tile = tiles[2]:dup(  ), contents = {} };
			else --4% chance of plating with an airlock.
				self.wmap[x][y] = { tile = tiles[2]:dup( ), contents = {airlock.new( )} };
			end
		end
	end
end
function map.render( self, zoom, ox, oy )
	for x = 1, self.width do
		for y = 1, self.height do
			self.wmap[x][y].tile:draw( x, y, 64*zoom );
			for k, v in ipairs( self.wmap[x][y].contents ) do
				v:draw( x*64 - 64, y*64 - 64 );
			end
		end
	end
end
function map.inBounds( self, x, y )
	if x >= 1 and x <= self.width and y >= 1 and y <= self.height then
		return true;
	end
	return false;
end

function map.toGrid( x, y, scale )
	return math.ceil( x/scale ), math.ceil( y/scale );
end

function map.fromGrid( x, y, scale )
	return x * scale, y * scale;
end

function map.getTile( self, x, y, scale )
	local tx, ty = map.toGrid( x, y, scale );
	if self:inBounds( tx, ty ) then
		return self.wmap[tx][ty].tile;
	end
end
function map.setTile( self, tile, x, y, scale )
	local tx, ty = map.toGrid( x, y, scale );
	if self:inBounds( tx, ty ) then
		self.wmap[tx][ty].tile = tile:dup(  );
	end
end