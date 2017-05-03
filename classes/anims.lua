anim = {length=.5,image="",quads={}};
function anim.new(l,i,w,h)
	local img=love.graphics.newImage(i);
	local quads={}
	local sw=img:getWidth();
	for i=-1,sw-64, w do
		local s=i;
		if s==-1 then s=0; end
		--  love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H);
		table.insert(quads,love.graphics.newQuad(s,0,w,h,img:getWidth(),img:getHeight()));
	end
	print(#quads)
	local o={length=l,image=img,quads=quads};
	setmetatable(o,{__index=anim});
	return o;
end

function anim.draw(self,x,y,t)
	local d=math.ceil(#self.quads/self.length);
	local f=math.min(math.max(1,math.ceil(((t)*d))),#self.quads);
	love.graphics.draw(self.image,self.quads[math.floor(f)],x,y); --self.x*scale-scale
end