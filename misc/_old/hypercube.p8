pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--p8cos = cos function cos(angle) return p8cos(angle/(3.1415*2)) end
--p8sin = sin function sin(angle) return -p8sin(angle/(3.1415*2)) end
--pi=3.141592

angle=0
points={}
⧗=0

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
	cls()	

end

function _update()
end

function _draw()

-- if ⧗==1 then	extcmd("rec",4,1) end


	⧗+=1

--	cls()
	camera()
	for i=1,500 do
		circ(rnd()*128,rnd()*128,8,0)
	end
	color(11)
	
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

--  local distance=2.5
  local distance=4-⧗/100
  local w=1/(distance-rotated.w)

  local projection={
  [0]={[0]=w,0,0,0},
  				{[0]=0,w,0,0},
  				{[0]=0,0,w,0},
  }

  local d=2.5
  local z=1/(d-rotated.z)

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

 angle=cos(⧗/750) 	 

	if ⧗==375 then
--		extcmd("video")
	end
end

function connect(offset,i,j,points)
  local a=points[i+offset]
  local b=points[j+offset]
  line(a.x,a.y,b.x,b.y)
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
