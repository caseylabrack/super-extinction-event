pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
record=true
record=false
angle=0
points={}
⧗=-4
cidx=1
cs={[0]=1,2,4}

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
end

function _draw()

	⧗+=2

	if ⧗==-2 then
		cls()
		return
	elseif ⧗==0 then
		extcmd("rec",4,1)
	end

	camera()
	mcls()

	cidx=0
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
  			 {[0]=0,cos(.5),-sin(.5),0},
  			 {[0]=0,sin(.5),cos(.5),0},
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
--  rotated=matmul(rotatex,rotated)

--  distance=10-t()/1
--		distance=cos(⧗/1000)*10
--		t2=(10+t())/20 --inc
		t2=(20+⧗/30)/40 --inc
		t3=2*abs(t2-flr(t2+0.5))--osc
		t3b=(10+t())/20
		t3b=(1-t3)
--		printh(t3)
--		t4=1-(1-t3)*(1-t3)*(1-t3)
		t4=t3*t3*t3*t3
--		t4=t3
--		if ⧗<15 then t4=1 end

--		distance=2.5+t4*7
		distance=2.25+t4*7.2

  local w=1/(distance-rotated.w)

  local projection={
  [0]={[0]=w,0,0,0},
  				{[0]=0,w,0,0},
  				{[0]=0,0,w,0},
  }

--  local d=2.5
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

	reds={}
	blues={}
	greens={}

 for i=0,3 do
  connect(0,i,(i+1)%4,projected3d)
  connect(0,i+4,((i+1)%4)+4,projected3d)
  connect(0,i,i+4,projected3d)
 end

 for i=0,3 do
  connect(8,i,(i+1)%4,projected3d)
  connect(8,i+4,((i+1)%4)+4,projected3d)
  connect(8,i,i+4,projected3d)
 end

 for i=0,7 do
  connect(0,i,i+8,projected3d)
 end

	local lw=2

	cls()
	color(1)
	for r in all(reds) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 memcpy(0x8000, 0x6000, 0x2000)

	cls()
	color(2)
	for r in all(blues) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 memcpy(0xA000, 0x6000, 0x2000)

	cls()
	color(4)
	for r in all(greens) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 for addr = 0x6000, 0x7FFF, 4 do
  poke4(addr, $addr | $(addr + 0x2000) | $(addr + 0x4000))
 end


	pal(1,8,1) --red color 1
	pal(2,140,1) --blue color 2
	pal(4,11,1) --green color 3

	pal(3,14,1) --red+blue=pink
	pal(6,12,1) --blue+green=lblue
	pal(5,10,1) --red+green=yellow

--	pal(1,139,1) --red color 1
--	pal(2,139,1) --blue color 2
--	pal(4,139,1) --green color 3
--
--	pal(3,138,1) --red+blue=pink
--	pal(6,138,1) --blue+green=lblue
--	pal(5,138,1) --red+green=yellow
--	pal(7,135,1) --white

	pal(1,14,1) --red color 1
	pal(2,12,1) --blue color 2
	pal(4,11,1) --green color 3

	pal(3,15,1) --red+blue=pink
	pal(6,138,1) --blue+green=lblue
	pal(5,135,1) --red+green=yellow
	
	pal(1,2,1) --red color 1
	pal(2,1,1) --blue color 2
	pal(4,131,1) --green color 3

	pal(3,14,1) --red+blue=pink
	pal(6,12,1) --blue+green=lblue
	pal(5,10,1) --red+green=yellow



--	pal(1,-8,1) --remap red
--	pal(2,-4,1) --remap blue
--	pal(4,-5,1) --remap green


-- angle=(t4)*5 --t()/10 	 
 angle=t3b*t3b --t()/10 	 
 angle=⧗/300 	 


--	camera()
--	print(⧗)
	if record and ⧗==1200 then
 	extcmd("video")
 	stop()		
	end

--pal(split("5,5,6,5,6,6,7,8,9,10,11,12,13,14,15,0"),1)
end

function connect(offset,i,j,points)
  local a=points[i+offset]
  local b=points[j+offset]
		 
  local r=flr(cidx)%3 
  
  if r==0 then
  	add(reds,{a,b})
		elseif r==1 then
  	add(blues,{a,b})
  elseif r==2 then
	  add(greens,{a,b})
  end
  
  
--  line(a.x,a.y,b.x,b.y)

--  xline(a.x,a.y,b.x,b.y,1)

	cidx+=.5
end

--xtra thick line
function xline(x1,y1,x2,y2,w) 
	for i=-w,w do
		for j=-w,w do
			line(x1+i,y1+j,x2+i,y2+j)
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
