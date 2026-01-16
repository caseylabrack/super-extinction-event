pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
record=true
record=false
angle=0
points={}
pu={} -- points unit square
⧗=-4
cidx=1--color index

function _init()
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

	--save the original unit coords
	for l=0,15 do
		pu[l]={}
		pu[l].x=points[l].x
		pu[l].y=points[l].y
		pu[l].z=points[l].z
		pu[l].w=points[l].w
	end

	cls()
end

function _draw()

	⧗+=2

	if ⧗==-2 then
--		cls()
--		return
	elseif ⧗==0 then
		cls()
		extcmd("rec",4,1)
	end

	cidx=0
	
	camera(-64,-64)
	
	local projected2d={}
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
--		t4=1-(1-t3)*(1-t3)*(1-t3)
		t4=t3*t3*t3*t3
		distance=2.25+t4*7.2
--		distance=2.25

  local w=1/(distance-rotated.w)

  local projection={
  [0]={[0]=w,0,0,0},
  				{[0]=0,w,0,0},
  				{[0]=0,0,w,0},
  }

  projected=matmul(projection,rotated)

  local z=1/(distance-rotated.z)

		local projection2d={
  [0]={[0]=z,0,0,0},
  				{[0]=0,z,0,0},
  				{[0]=0,0,0,0},
  }

  projected=matmul(projection2d,projected)
		vec4mult(projected,128/2)
  projected2d[i]=projected
  
  projected2d[i].x0=pu[i].x
  projected2d[i].y0=pu[i].y
  projected2d[i].z0=pu[i].z
  projected2d[i].w0=pu[i].w    
 end

	layers={}
	layers[1]={} --1st layer (red)
	layers[2]={} --2nd layer (blu)
	layers[3]={} --3rd layer (grn)
	layers[4]={} --3rd layer (grn)

 for i=0,3 do
  connect(0,i,(i+1)%4,projected2d)
  connect(0,i+4,((i+1)%4)+4,projected2d)
  connect(0,i,i+4,projected2d)
 end

 for i=0,3 do
  connect(8,i,(i+1)%4,projected2d)
  connect(8,i+4,((i+1)%4)+4,projected2d)
  connect(8,i,i+4,projected2d)
 end

 for i=0,7 do
  connect(0,i,i+8,projected2d)
 end

	local lw=2 --line weight

	cls()
	color(1)
	for r in all(layers[1]) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 memcpy(0x8000, 0x6000, 0x2000)

	cls()
	color(2)
	for r in all(layers[2]) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 memcpy(0xA000, 0x6000, 0x2000)

	cls()
	color(4)
	for r in all(layers[3]) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 memcpy(0xC000, 0x6000, 0x2000)

	cls()	
	color(8)
	for r in all(layers[4]) do
		xline(r[1].x,r[1].y,r[2].x,r[2].y,lw)
	end
 for addr = 0x6000, 0x7FFF, 4 do
  poke4(addr, $addr | $(addr + 0x2000) | $(addr + 0x4000) | $(addr + 0x6000))
 end

	pal(1,12,1) --cyan
	pal(2,14,1) --magenta
	pal(4,10,1) --yellow
	pal(8,11,1) --green

	pal(3,1,1)	 --cyan+mag
	pal(5,1,1)	 --cyan+yel
	pal(6,2,1)  --mag+yel	
	pal(7,2,1)	 --cyan+mag+yel
	pal(9,3,1)	 --green+cyan
	pal(10,3,1) --mag+green
	pal(11,1,1)	--cyan+mag+green
	pal(12,3,1)	--yel+green
	pal(13,1,1)	--cyan+yel+green
	pal(14,3,1)	--mag+yel+green

	pal(15,0,1) --all=black
	pal(0,7,1)  

 angle=⧗/300 	 

	if record and ⧗==1200 then
 	extcmd("video")
 	stop()		
	end
end

function connect(offset,i,j,points)
 a=points[i+offset]
 b=points[j+offset]

	idx=-1
	if a.x0 != b.x0 then idx=1 end
	if a.y0 != b.y0 then idx=2 end
	if a.z0 != b.z0 then idx=3 end
	if a.w0 != b.w0 then idx=4 end

	add(layers[idx],{a,b})
end

--xtra thick line
function xline(x1,y1,x2,y2,w) 
	for i=-w,w do
		for j=-w,w do
			line(x1+i,y1+j,x2+i,y2+j)
		end
	end
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
