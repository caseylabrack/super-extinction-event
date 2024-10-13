pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--super extinction event
--casey labrac

--asteroid strikes push back?

⧗=0

p={x=64,y=29,a=.25,r=0,m=37,s=.015,d=1,fr=1,
	state="idle",
	frames={
	--idle
	split("24.51,16.5,20.51,17.5,26.51,10.5,30.51,10.5,32.51,.5,36.51,.5,36.51,3.5,34.51,3.5,33.51,11.5,32.97,19.56,31.61,19.31,30.51,16.5,27.51,16.5,26.89,19.51,25.48,19.74,24.51,16.5"),
	--run
	split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,35.97,18.56,34.61,19.31,30.51,16.5,27.51,16.5,24.89,19.51,23.48,19.74,24.51,16.5"),
	split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,31.97,19.56,29.61,19.31,30.51,16.5,27.51,16.5,27.89,19.51,25.48,19.74,24.51,16.5"),
	}}
e={x=0,y=0,a=0,r=0,s=.01,d=1,
	fr=1,frames={split("25.89,8.21,25.16,10.49,25.92,10.67,28.79,10.52,28.41,9.21,31.2,9.4,34.77,11.51,32.8,12.83,31.32,17.96,30.05,19.54,28.49,20.67,26.34,21.05,24.46,22.12,25.51,24.51,27.5,25.39,31.04,30.04,38.79,29.38,48.99,35.65,45.94,43.96,33.46,55.41,32.84,55.52,32.39,54.17,35.51,44.69,34.98,42.4,31.88,37.83,29.51,31.51,23.84,27.93,19.51,25.51,14.27,17.76,14.12,16.41,15.09,13.72,15.12,10.48,14.62,9.94,13.92,9.62,11.91,10.07,14.09,7.98,17.04,7.01,18.1,7.54,25.22,7.57,25.89,8.21")}}

function _init()

	--center artwork on origin
	for i=1,#p.frames do
		p.frames[i]=translate(p.frames[i],28,13)
	end

	e.frames[1]=translate(e.frames[1],29,29)
	p.parent=e
end

function _update()

	⧗+=1
	e.r+=.01

	p.state="idle"
	if btn(⬅️) then p.a+=p.s p.d=-1 p.state="run" end
	if btn(➡️) then p.a-=p.s p.d=1  p.state="run" end

	if p.state=="idle" then
		p.fr=1
	end
	if p.state=="run" then
		if ⧗%8<4 then --alternate
			p.fr=2
		else
			p.fr=3
		end
	end

	p.x=cos(p.a)*p.m
	p.y=sin(p.a)*p.m
	p.r=p.a+.75
	
	
end

function _draw()
	cls()
	
	circ(64,64,29,7)
	
	camera(-64,-64)
	render_ent(p)
	render_ent(e)		
	camera()
end
-->8
--utils

function dist(x1,y1,x2,y2)
	return sqrt((x1-x2) * (x1-x2)+(y1-y2)*(y1-y2))
end

--distance from origin
function disto(x,y)
	return dist(x,y,0,0)
end

function translate(ps,x,y)
	local os={}
	
	for i=1,#ps,2 do
		add(os,ps[i]-x)
		add(os,ps[i+1]-y)
	end
	
	return os
end

function rotate(ps,a)
	local os={}
	for i=1,#ps,2 do
		local x=ps[i]
		local y=ps[i+1]
		local ang=atan2(x,y)
		local mag=disto(x,y)
		local x=cos(ang+a)*mag
		local y=sin(ang+a)*mag
		add(os,x)
		add(os,y)
	end	
	return os
end

function scale(ps,sx,sy)
	local os={}
	for i=1,#ps,2 do
		add(os,ps[i]*sx)
		add(os,ps[i+1]*sy)
	end
	return os
end

function gpos(e)
	local p=e.parent
	if p then
		local a=atan2(e.x,e.y)+p.r
		local d=disto(e.x,e.y)
		return p.x+cos(a)*d,p.y+sin(a)*d
	end
	return e.x,e.y
end

function grote(e)
	local p=e.parent
	if p then
		return p.r+e.r
	end
	return e.r
end

function renderpoly(ps,c)
	color(c or 7)
	line(ps[1],ps[2],ps[3],ps[4])
	for i=5,#ps,2 do
		line(ps[i],ps[i+1])
	end
	line(ps[1],ps[2])
end

function render_ent(e)
	local frame=e.frames[e.fr]
	local scaled=scale(frame,e.d,1)
--	local rotated=rotate(scaled,e.r)
	local rotated=rotate(scaled,grote(e))
--	local translated=translate(rotated,-e.x,-e.y)
	local x,y=gpos(e)
	local translated=translate(rotated,-x,-y)
	renderpoly(translated)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
