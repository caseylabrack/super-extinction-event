pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--super extinction event
--casey labrac

--todo:
	--helper cart for art import
	--asteroid strikes push back?
	--skid to stop?
	--takes time to pick up egg?
	--asteroids don't kill you?
	--roid trail particles taper

--tick (frame count)
log=""
⧗=0

--player
p={x=64,y=29,r=0,state="idle",e=true,
	--angle, delta angle, magnittude, delta mag
 a=.25,da=0,m=37,dm=0,
	--speed, facing direction,
 s=.004,d=1,
 --frame index, all frames
 fr=1,frames={
		--idle
		split("24.51,16.5,20.51,17.5,26.51,10.5,30.51,10.5,32.51,.5,36.51,.5,36.51,3.5,34.51,3.5,33.51,11.5,32.97,19.56,31.61,19.31,30.51,16.5,27.51,16.5,26.89,19.51,25.48,19.74,24.51,16.5"),
		--run
		split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,35.97,18.56,34.61,19.31,30.51,16.5,27.51,16.5,24.89,19.51,23.48,19.74,24.51,16.5"),
		split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,31.97,19.56,29.61,19.31,30.51,16.5,27.51,16.5,27.89,19.51,25.48,19.74,24.51,16.5"),
		}
	}
	
pdead={x=0,y=-37,r=0,c=6,⧗=0,e=false,fr=1,frames={}}
--earth
e={x=0,y=0,a=0,r=0,s=.01,d=1,c=3,
	fr=1,frames={split("25.89,8.21,25.16,10.49,25.92,10.67,28.79,10.52,28.41,9.21,31.2,9.4,34.77,11.51,32.8,12.83,31.32,17.96,30.05,19.54,28.49,20.67,26.34,21.05,24.46,22.12,25.51,24.51,27.5,25.39,31.04,30.04,38.79,29.38,48.99,35.65,45.94,43.96,33.46,55.41,32.84,55.52,32.39,54.17,35.51,44.69,34.98,42.4,31.88,37.83,29.51,31.51,23.84,27.93,19.51,25.51,14.27,17.76,14.12,16.41,15.09,13.72,15.12,10.48,14.62,9.94,13.92,9.62,11.91,10.07,14.09,7.98,17.04,7.01,18.1,7.54,25.22,7.57,25.89,8.21")}}

--roids
rs={}
--splodes
ss={}
--splode frame
slfr=split("9.2,.81,12.47,4.96,17.7,5.71,15.74,10.62,17.7,15.53,12.47,16.29,9.2,20.44,5.93,16.29,.7,15.53,2.66,10.62,.7,5.71,5.93,4.96,9.2,.81")
--trex
t={x=0,y=0,r=0,d=1,c=10,s=.005,
	fr=1,frames={split("4.51,-12.52,0.51,-7.52,0.51,-3.52,-1.49,-2.52,-3.49,-0.52,-5.95,-0.58,-8.65,1.07,-2.49,2.48,-3.12,5.48,-1.66,5.48,1.02,3.3,1.67,5.48,4.51,5.48,3.48,1.05,6.51,1.48,4.51,-0.52,7.51,-2.52,3.51,-2.52,4.51,-7.52,6.25,-5.14,7.51,-7.52,11.51,-6.52,11.51,-10.52,4.51,-12.52")}}


function _init()

	--center artwork on origin
	for i=1,#p.frames do
		p.frames[i]=translate(p.frames[i],28,13)
	end
	pdead.frames[1]=p.frames[1]

	e.frames[1]=translate(e.frames[1],29,29)

	slfr=translate(slfr,8,10)

	p.x=0
	p.y=-30
	p.parent=e
	
	t.x=0
	t.y=37
	t.r=.5
	t.parent=e	
	
	pal(10,138,1)
	pal(12,140,1)
	pal(8,136,1)
	pal(9,137,1)
	pal(3,131,1)
end

function _update()

	⧗+=1
	e.r+=.01
	
	if ⧗%10==0 then
		local roid={}
		local a=rnd()
		roid.x,roid.y=cos(a)*60,sin(a)*60
		roid.dx,roid.dy=cos(a+.5),sin(a+.5)
		roid.r=a roid.c=2
		add(rs,roid)
	end
		
	for roid in all(rs) do
		roid.x+=roid.dx
		roid.y+=roid.dy
		
		if distt(roid,e)<29 then
			del(rs,roid) --probably do don't this
			local s={⧗=0}
			s.x,s.y,s.r=roid.x,roid.y,0
			s.d=1 s.r=0 s.fr=1 s.c=9
			s.frames={slfr}
			addchild(e,s)
			add(ss,s)
			
			--knockback/hit
			sa=atan2(s.x,s.y)
			pa=atan2(p.x,p.y)
			
			diff=sad(sa,pa)
			if abs(diff)<.1 then
				local pct=sgn(diff)-(diff/.1)
				p.da+=pct*.075
			end
		end
	end
	
	for splode in all(ss) do
		splode.⧗+=1
		if splode.⧗>40 then
			del(ss,splode)
		else
			splode.c=rnd({8,9})
			local pct=1-splode.⧗/40
			splode.scale=easeinexpo(pct)
		end
	end	
	
	if pdead.e then
		pdead.⧗+=1
	end
	
	if p.e then
		p.state="idle"
		if btn(⬅️) then 
			p.da+=p.s 	
			p.d=-1 p.state="run" 
		end
		if btn(➡️) then 
			p.da-=p.s
			p.d=1  p.state="run" 
		end
		
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
		
		local a=atan2(p.x,p.y)
		a+=p.da
	
		p.x=cos(a)*p.m
		p.y=sin(a)*p.m
		p.r=a+.75--stand upright
		p.da*=.75--friction
	else
		if pdead.⧗>60 then
			if btn()~=0 then
				p.e=true
				p.parent=nil
				p.x,p.y,p.da=0,-37,0
				addchild(e,p)
				pdead.e=false
				pdead.⧗=0
			end
		end	
	end
	
	--trex chase
	if p.e then
		pa=atan2(p.x,p.y)
		ta=atan2(t.x,t.y)
		
		diff=sad(pa,ta)
		if abs(diff)<.05 then
	--		stop("dead: "..⧗)
			p.e=false
			pdead.e=true
		else
			ta+=t.s*sgn(diff)*-1
			t.x=cos(ta)*37
			t.y=sin(ta)*37
			t.r=ta+.75
			t.d=sgn(diff)
		end		
	end
end

function _draw()
	cls()
	
	camera(-64,-64)
	
	for splode in all(ss) do
		render_ent(splode)
	end	
	
	--earth surface,fill
	circfill(0,0,29,0)	
	circ(0,0,29,1)
	--	circ(0,0,3,11)--ctr ref
	
	for roid in all(rs) do
		local gx,gy=gpos(roid)
		circ(gx,gy,3,5)
	end
		
	if p.e then 
		render_ent(p)
	else
		if pdead.⧗>60 then
			if ⧗%12<6 then
				render_ent(pdead)
			end				
		end
	end
	
	render_ent(e)
	render_ent(t)
	camera()
		
--	print(log,0,120,11)
end
-->8
--utils

function dist(x1,y1,x2,y2)
	return sqrt((x1-x2) * (x1-x2)+(y1-y2)*(y1-y2))
end

--distance between vectors
function distt(a,b)
	return dist(a.x,a.y,b.x,b.y)
end

--distance from origin
function disto(x,y)
	return dist(x,y,0,0)
end

--distance from origin vector
function distot(ent)
	return dist(ent.x,ent.y,0,0)
end

--unsigned angle difference:
--shortest angle diff around circle
--(handles wrapping of angles
--from 0-1)
function uad(a,b)
	local phi=abs(a-b)%1
	return phi<.5 and phi or 1-phi
end

--signed angle difference
function sad(a,b)
	local phi=(b-a+.5)%1-.5
	if phi<-.5 then
		return phi+1
	else
		return phi
	end
end

--easings.net
function easeoutexpo(x)
	if x==1 then
		return 1
	else
		return 1-2^(-10*x)
	end
end

function easeinexpo(x)
	if x==0 then
		return 0
	else
		return 2^(10*x-10)
	end
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

function addchild(parent,child)
	local lx,ly=global2local(child,parent)
	child.x,child.y=lx,ly
	child.r=grote(child)-parent.r
	child.parent=parent
end

function global2local(g,l)
	local lx,ly=gpos(l)
	local d=distt(l,g)
	local a=atan2(g.x-lx,g.y-ly)
	local rote=a-grote(l)
	return cos(rote)*d,sin(rote)*d
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
	local es=e.scale or 1
	local frame=e.frames[e.fr]
	local scaled=scale(frame,(e.d or 1)*es,1*es)
--	local rotated=rotate(scaled,e.r)
	local rotated=rotate(scaled,grote(e))
--	local translated=translate(rotated,-e.x,-e.y)
	local x,y=gpos(e)
	local translated=translate(rotated,-x,-y)
	renderpoly(translated,e.c)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
