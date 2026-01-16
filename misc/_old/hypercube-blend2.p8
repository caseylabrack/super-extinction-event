pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--p8cos = cos function cos(angle) return p8cos(angle/(3.1415*2)) end
--p8sin = sin function sin(angle) return -p8sin(angle/(3.1415*2)) end
--pi=3.141592

angle=0
points={}
⧗=0
rate=1

function _init()
--	poke(0x5f2c,3)
	points[0]=newvec4(-1,-1,-1,1)
	points[1]=newvec4(1,-1,-1,1)
	points[2]=newvec4(1,1,-1,1)
	points[3]=newvec4(-1,1,-1,1)
	points[4]=newvec4(-1,-1,1,1)
	points[5]=newvec4(1,-1,1,1)
	points[6]=newvec4(1,1,1,1)
	points[7]=newvec4(-1,1,1,1)
	points[8]=newvec4(-1,-1,-1,-1)
	points[9]=newvec4(1,-1,-1,-1)
	points[10]=newvec4(1,1,-1,-1)
	points[11]=newvec4(-1,1,-1,-1)
	points[12]=newvec4(-1,-1,1,-1)
	points[13]=newvec4(1,-1,1,-1)
	points[14]=newvec4(1,1,1,-1)
	points[15]=newvec4(-1,1,1,-1)

	cls()
	extcmd("rec",4,1)

end

function _draw()
	⧗+=1


	camera()
	mcls()
--	cls()
--	camera()
--	for i=1,500 do
--		circ(rnd()*120,rnd()*120,8,0)
--	end
--	color(11)
	
	camera(-64,-64)
	
	local projected3d={}
 for i=0,len(points)-1 do
  local v=points[i]
  local rotationxy={
  [0]={[0]=cos(angle),-sin(angle),0,0},
  				{[0]=sin(angle),cos(angle),0,0},
 				 {[0]=0,0,1,0},
 				 {[0]=0,0,0,1},
	 }
	 
	 local rotatex={
  [0]={[0]=1,0,0,0},
  			 {[0]=0,cos(angle),-sin(angle),0},
  			 {[0]=0,sin(angle),cos(angle),0},
  			 {[0]=0,0,0,1},
	 }
	 
  local rotationyz={
  [0]={[0]=1,0,0,0}, 
  				{[0]=0,cos(angle),-sin(angle),0}, 
  				{[0]=0,sin(angle),cos(angle),0}, 
  				{[0]=0,0,0,1}
		}

  local rotationzw={
  [0]={[0]=1,0,0,0},
    		{[0]=0,1,0,0},
    		{[0]=0,0,cos(angle),-sin(angle)},
    		{[0]=0,0,sin(angle),cos(angle)}
  }
	
--  rotated=matmul(rotatex,v)	
	 rotated=matmul(rotationyz,v)
	 rotated=matmul(rotationxy,rotated)
  rotated=matmul(rotationzw,rotated)
  rotated=matmul(rotatex,rotated)

--  distance=10-t()/1
--		distance=cos(⧗/1000)*10
		t2=(10+t())/20 --inc
		t3=2*abs(t2-flr(t2+0.5))--osc
		t3b=(10+t())/20
		t3b=(1-t3)
--		printh(t3)
--		t4=1-(1-t3)*(1-t3)*(1-t3)
		t4=t3*t3
--		t4=t3
--		if ⧗<15 then t4=1 end
--		distance=8-⧗/50
--  distance=4-⧗/100
  distance=8-(⧗/100)*rate
  rate*=1.0001
  if distance<-12 then
--  	extcmd("video")
--  	stop()
  end
--  distance*=10
  local w=1/(distance-rotated.w)

  local projection={
  [0]={[0]=w,0,0,0},
  				{[0]=0,w,0,0},
  				{[0]=0,0,w,0},
  }

  local d=2.5
--  local z=1/(d-rotated.z)
  local z=1/(distance-rotated.z)

		local projection2d={
  [0]={[0]=z,0,0,0},
  				{[0]=0,z,0,0},
  				{[0]=0,0,0,0},
  }

  local projected=matmul(projection,rotated)
  projected=matmul(projection2d,projected)
		vec4mult(projected,128/2)
  projected3d[i]=projected
 end

	mcls()
	color(1)
 for i=0,3 do
  connect(0,i,(i+1)%4,projected3d)
  connect(0,i+4,((i+1)%4)+4,projected3d)
  connect(0,i,i+4,projected3d)
 end
 memcpy(0x8000, 0x6000, 0x2000)

	mcls()
	color(2)
 for i=0,3 do
  connect(8,i,(i+1)%4,projected3d)
  connect(8,i+4,((i+1)%4)+4,projected3d)
  connect(8,i,i+4,projected3d)
 end
 memcpy(0xA000, 0x6000, 0x2000)

 mcls()
 color(4)
 for i=0,7 do
  connect(0,i,i+8,projected3d)
 end
 for addr = 0x6000, 0x7FFF, 4 do
  poke4(addr, $addr | $(addr + 0x2000) | $(addr + 0x4000))
 end
 
--	pal(1,8,1) --red color 1
--	pal(2,140,1) --blue color 2
--	pal(4,11,1) --green color 3
--
--	pal(3,14,1) --red+blue=pink
--	pal(6,12,1) --blue+green=lblue
--	pal(5,10,1) --red+green=yellow

	pal(1,139,1) --red color 1
	pal(2,139,1) --blue color 2
	pal(4,139,1) --green color 3

	pal(3,138,1) --red+blue=pink
	pal(6,138,1) --blue+green=lblue
	pal(5,138,1) --red+green=yellow
	pal(7,135,1) --white

--	pal(1,14,1) --red color 1
--	pal(2,12,1) --blue color 2
--	pal(4,11,1) --green color 3
--
--	pal(3,15,1) --red+blue=pink
--	pal(6,135,1) --blue+green=lblue
--	pal(5,10,1) --red+green=yellow
	
--	pal(1,2,1) --red color 1
--	pal(2,1,1) --blue color 2
--	pal(4,3,1) --green color 3
--
--	pal(3,14,1) --red+blue=pink
--	pal(6,12,1) --blue+green=lblue
--	pal(5,10,1) --red+green=yellow



--	pal(1,-8,1) --remap red
--	pal(2,-4,1) --remap blue
--	pal(4,-5,1) --remap green

-- angle=cos(⧗/750) 	 

-- angle=(t4)*5 --t()/10 	 
-- angle=t3b*t3b --t()/10 	 
--		angle=⧗/100
		angle=cos(⧗/750)
--	print(distance)

--pal(split("5,5,6,5,6,6,7,8,9,10,11,12,13,14,15,0"),1)
end

function connect(offset,i,j,points)
  local a=points[i+offset]
  local b=points[j+offset]
--  line(a.x+1,a.y+1,b.x+1,b.y+1)
--  line(a.x+.5,a.y+.5,b.x+.5,b.y+.5)
--  line(a.x,a.y,b.x,b.y)
  xline(a.x,a.y,b.x,b.y,1)
--  line(a.x-1,a.y-1,b.x-1,b.y-1)
--  line(a.x-.5,a.y-.5,b.x-.5,b.y-.5)
end

--xtra thick line
function xline(x1,y1,x2,y2,w) 
	for i=-w,w do
		for j=-w,w do
			if x1>-80 and x1<80 and
			y1>-80 and y1<80 and
			x2>-80 and x2<80 and
			y2>-80 and y2<80 then
				line(x1+i,y1+j,x2+i,y2+j)
			end
		end
	end
end

--messy clear
function mcls()
	cls()
--	for i=1,100 do
--		circ(-64+rnd()*128,-64+rnd()*128,8,0)
--	end	
end
-->8
--matrix
--https://editor.p5js.org/codingtrain/sketches/n0y8ntgwi

function vectomatrix(v) 
 local m={}	
	for i=0,2 do
		m[i]={}
	end	
 m[0][0]=v.x
 m[1][0]=v.y
 m[2][0]=v.z
	return m 
end

function vec4tomatrix(v) 
	local m=vectomatrix(v)
 m[3]={}
 m[3][0]=v.w
 return m
end

function matrixtovec(m) 
	return createvector(m[0][0], m[1][0], m[2][0])
end

function createvector(x,y,z,w)
	local v={x=x,y=y,z=z,w=w}
	return v
end

function matrixtovec4(m) 
 local r={x=m[0][0],y=m[1][0],z=m[2][0],w=0}
 if len(m)>3 then
  r.w=m[3][0]
 end
 return r
end

function matmulvec(a,vec) 
 local m=vectomatrix(vec)
 local r=matmul(a,m)
 return matrixtovec(r)
end

function matmulvec4(a,vec)
 local m=vec4tomatrix(vec)
 local r=matmul(a,m)
 return matrixtovec4(r)
end

function matmul(a,b)
	if b.w then --b instanceof p4vector
		return matmulvec4(a,b)
	end
	if b.z then --b instanceof p5.vector
		return matmulvec(a,b)
	end

 local colsa=len(a[0])
 local rowsa=len(a)
 local colsb=len(b[0])
 local rowsb=len(b)

	assert(colsa==rowsb)

	local result={}
  for j=0,rowsa-1 do
   result[j]={}
   for i=0,colsb-1 do
    local sum=0
    for n=0,colsa-1 do
     sum+=a[j][n]*b[n][i]
    end
    result[j][i]=sum
   end
  end
 return result
end

-->8
--"vec4"
function newvec4(x,y,z,w)
	return {x=x,y=y,z=z,w=w}
end

--in-place
function vec4mult(v,f)
	v.x*=f
	v.y*=f
	v.z*=f
	v.w*=f
end

--length operator that counts
--zero indexed tables
function len(m)
	if m[0] then
		return #m+1
	else
		return #m
	end
end
-->8
--do
--local old_draw=_draw
--poke(0x5f2d,1)
--poke(0x5f2e,1)
--
--local old_pal=pal
--
--local draw_func=function()
--	old_draw()
--	pal=function(...)
--	 local t={...}
--	 if #t==0 then
--	  old_pal(split("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0"))
--	  palt()
--	  fillp()
--	 elseif type(t[1])=="table"
--	 and #t==2
--	 or #t==3 then
--	 
--	 else
--	  old_pal(t[1],t[2])
--	 end
--	end
--end
--
--local sel_pal=sel_pal or 0
--local game_palette={}
--local sel_clr=sel_clr or 0
--local draw_state,press={}
--local active
--_draw=function()
-- if band(stat"34",2)==2 then
--  press=press and press+1 or 0
--  if (press==0) active=not active
-- else
--  press=nil
-- end
-- 
-- local mousex,mousey=stat"32",stat"33"
-- 
-- draw_func()
--	local pal=old_pal
--	for i=0,15 do
--	 game_palette[i]=peek(0x5f10+i)
--	end
-- if active then
--		pal()
--	 for i=0x5f00,0x5f3f do
--	  draw_state[i]=peek(i)
--	 end
--	 
--	 if band(stat"34",1)==1 then
--	  local x8=mousex\8
--	  if mousey<=8 then
--	   sel_clr=x8
--	  elseif mousey<=16 then
--	   game_palette[sel_clr]=x8+128*sel_pal
--	   local s="pal(split(\""
--	   for i=0,14 do
--	    s..=game_palette[i+1]..","
--	   end
--	   s..=game_palette[0].."\"),1)"
--	   printh(s,"@clip")
--	  elseif mousey<=23 and mousey<=36 then
--	   sel_pal=mousex\18
--	  end
--	 end
--	 
--	 clip()
--	 camera()
--	 fillp()
--	 --current palette
--	 rectfill(0,0,127,8,1)
--	 for i=0,15 do
--	  rectfill(i*8,0,i*8+7,7,i)
--	 end
--	 rect(sel_clr*8-1,-1,sel_clr*8+8,8,7)
--	 rect(sel_clr*8,0,sel_clr*8+7,7,0)
--	 pal()
--	 
--	 --swap palette
--	 for i=0,15 do
--	  rectfill(i*8,9,i*8+7,16,i)
--	 end
--	 
--	 --
--	 rectfill(0,17,36,23,1)
--	 ?"pal1",1,18,sel_pal==0 and 7 or 5
--	 ?"pal2",21,18,sel_pal==1 and 7 or 5
--	 
--	 pset(mousex,mousey,8)
--	 
--	 for i=0x5f00,0x5f3f do
--	  poke(i,draw_state[i])
--	 end
--	 poke(0x5f5f,0x10)
--	 
--	 poke(0x5f71,0xfe)
--	 poke(0x5f72,1)
--	else
--		pal()
--  memset(0x5f71,0,2)
--	end
-- --screen palette 2
-- for i=0,15 do
--  pal(i,i+128*sel_pal,2)
--  pal(i,game_palette[i],1)
-- end
--end
--end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
