pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include ../font-util.p8:2

fontdata=[[|!40325240p444c|"2a26p6a66|#0484626a88082a22|$62266ap4c40|%008cp2a28p6462|&804c88044084|'266a|h000cp0686p8c80|i0080p404cp0c8c|j0440808c|k000cp8c0660|l80000c|m000c488c80|n000c808c|o000c8c8000|p000c8c8605|q000c8c8400p4480|r000c8c8605p4580|s02208085070c6c8a|t0c8cp4c40|u0c0240828c|v0c408c|w0c2044608c|x008cp0c80|y0c468cp4640|z0c8c0080p2666|{60424a6cp2646|}40626a4cp6686|~04286488|[60202c6c|\0c80|]20606c2c|^264c66|_0080|`2a66|a00084c8880p0484|b000c4c8a46824000|c80000c8c|d000c4c88844000|e80000c8cp0666|f000c8cp0666|g668480000c8c|(6024286c|)2064682c|*004c80088800|+1676p4943|,2042|-2666|.3040|/008c|000808c0c008c|1404c3a|20c8c87050080|30c8c8000p0686|40c0686p8c80|5008086070c8c|60c00808507|70c8c8640|800808c0c00p0686|9808c0c0785|:4947p4543|;4947p4512|<60266c|=1474p1878|>20662c|?084c8844p4140|@844004084c884436|]]

angle=.75
ax=-.0575
ay=0
az=.5
dist=100
points={}
stars={}
⧗=0

function _init()

	fonts=font_parser(fontdata)
		
 points[0]=vec3( 0.5,1.0,0)
 points[1]=vec3(0.35,1.0,0.35)
 points[2]=vec3(0.00,1.0,0.50)
 points[3]=vec3(-.35,1.0,0.35)
 points[4]=vec3(-.50,1.0,0.00)
 points[5]=vec3(-.35,1.0,-.35)
 points[6]=vec3(0.00,1.0,-0.50)
 points[7]=vec3(0.35,1.0,-.35)

 points[8]=vec3(1.00,0.7,0.00)
 points[9]=vec3(0.71,0.7,0.71)
 points[10]=vec3(0.00,0.7,1.00)
 points[11]=vec3(-.71,0.7,0.71)
 points[12]=vec3(-1.00,0.7,0.00)
 points[13]=vec3(-.71,0.7,-0.71)
 points[14]=vec3(0.00,0.7,-1.00)
 points[15]=vec3(0.71,0.7,-0.71)
 
 --change girdle position
 for i=8,15 do
 	points[i].y-=.2
 end
 
 points[16]=vec3(0.00,-1.0,0.00)

	for i=0,100 do
		local x=-1+rnd()*2
		local y=-1+rnd()*2
		local z=-1+rnd()*2
		stars[i]=vec3(x,y,z)
	end

--		for i=0,#points do
--			points[i].y+=1
--		end

end

function _update()
	⧗+=1
	
	if btn(⬅️) then ax-=.01 end
	if btn(➡️) then ax+=.01 end
	if btn(⬆️) then ay+=.01 end
	if btn(⬇️) then ay-=.01 end
	if btn(❎) then az+=.01 end
	if btn(🅾️) then az-=.01 end
	
	
	dist=mid(3,dist*.97,100)
	
	ax+=.005
	ay+=.0025
	az+=.001
		
end

function _draw()

	cls()

	--you might be extinct
	--but you're still great
	if ⧗>30 then cvprint("you're not just any",64,8,8) end
	if ⧗>45 then cvprint("crushed 8it of carbon",64,18,8) end
	if ⧗>120 then cvprint("you're a diamond",64,120,8) end
	
	camera(-64,-64)

	local rotationz={
  [0]={[0]=cos(az),-sin(az), 0},
  {[0]=sin(az), cos(az), 0},
  {[0]=0, 0, 1},
 }

 local rotationx={
  [0]={[0]=1, 0, 0},
  {[0]=0, cos(ax), -sin(ax)},
  {[0]=0, sin(ax),  cos(ax)},
 }

 local rotationy={
  [0]={[0]=cos(ay),  0, sin(ay)},
  {[0]=0, 1, 0},
  {[0]=-sin(ay), 0, cos(ay)},
 }
 
 local projected={}
 for i=0,len(points)-1 do
  local rotated=matmul(rotationy,points[i])
  rotated=matmul(rotationx,rotated)
  rotated=matmul(rotationz,rotated)
--  local distance=3
  local z=1/(dist-rotated.z)
  local projection={
   [0]={[0]=z, 0, 0},
   {[0]=0, z, 0},
  }
  local projected2d=matmul(projection,rotated)

  vecmult(projected2d,128)
  projected[i]=projected2d
 end

	sproj={}
 for i=0,len(stars)-1 do
  local rotated=matmul(rotationy,stars[i])
  rotated=matmul(rotationx,rotated)
  rotated=matmul(rotationz,rotated)
--  local distance=3
  local z=1/(1-rotated.z)
  local projection={
   [0]={[0]=z, 0, 0},
   {[0]=0, z, 0},
  }
  local sprojected2d=matmul(projection,rotated)

  vecmult(sprojected2d,128)
  sproj[i]=sprojected2d
 end
 
 for i=0,len(stars)-1 do
  local v=sproj[i]
 	pset(v.x,v.y,2)
 end

	connect(0,1,projected)
	connect(1,2,projected)
	connect(2,3,projected)
	connect(3,4,projected)
	connect(4,5,projected)
	connect(5,6,projected)
	connect(6,7,projected)
	connect(7,0,projected)

	connect(8,9,projected)
	connect(9,10,projected)
	connect(10,11,projected)
	connect(11,12,projected)
	connect(12,13,projected)
	connect(13,14,projected)
	connect(14,15,projected)
	connect(15,8,projected)

	connect(0,8,projected)
	connect(1,9,projected)
	connect(2,10,projected)
	connect(3,11,projected)
	connect(4,12,projected)
	connect(5,13,projected)
	connect(6,14,projected)
	connect(7,15,projected)

	connect(8,16,projected)
	connect(9,16,projected)
	connect(10,16,projected)
	connect(11,16,projected)
	connect(12,16,projected)
	connect(13,16,projected)
	connect(14,16,projected)
	connect(15,16,projected)

	camera()
--	print("x: "..ax)
--	print("y: "..ay)
--	print("z: "..az)

-- angle+=0.001

end

function connect(i,j,points) 
 local a=points[i]
 local b=points[j]
 line(a.x, a.y, b.x, b.y,rnd({7,7,7,7,8,10}))
end
-->8
--matrix
--https://editor.p5js.org/codingtrain/sketches/r8l8xxd2a

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

function matrixtovec(m) 
	return vec3(m[0][0],m[1][0],len(m)>2 and m[2][0] or 0)
end

function matmulvec(a,vec) 
 local m=vectomatrix(vec)
 local r=matmul(a,m)
 return matrixtovec(r)
end

function matmul(a,b)
	if b.z then
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
--utility

function vec3(x,y,z)
	return {x=x,y=y,z=z}
end

--in-place
function vecmult(v,f)
	v.x*=f
	v.y*=f
	v.z*=f
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
