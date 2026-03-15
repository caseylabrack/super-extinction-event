pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--dinos animations
--menu shows metascore?
---"crowns 3/6"?
--speako-8 reads dinosaur names?

bronto={}

#include super-extinction-event.p8:1
#include font-util.p8:3

moving=false
start⧗=0
yoff=0

speciestxt={}
speciestxt[1]={}
speciestxt[2]={}
speciestxt[3]={}

xoffs={[0]=0,0,0}
bws={[0]=68,48,0} --button widths
bwps={[0]=80,62,0} --w/padding
bhs={[0]=68,10,0} --button heights
--bwps={[0]=80,,0} --w/padding

pidxs={[0]=0,0,0}
idxs={[0]=0,0,0}

pct=1

yidx=0
pyidx=0

idx=0
pidx=0

movetype="x"

⧗=0
dx=0

dframes={} --frames around dinos
mframes={} --frames around mode
sframe1={} --selection frame
sframe2={} --selection frame

dinoinfo={}
dinoinfo[1]={}
dinoinfo[2]={}
dinoinfo[3]={}

dbtext={} --difficulty btn text
ditext={} --difficulty info text

earths={}

parts={}
parts[1]={}
parts[2]={}
parts[3]={}

pressx={}

bscore=0
oscore=0
sscore=0

ru={} --rex unlocked


function _init()

	cartdata("caseylabrack_superdino")
	add(ru,dget(1)>rexgoals[1])
	add(ru,dget(2)>rexgoals[2])
	add(ru,dget(3)>rexgoals[3])

	bronto=new_ent()
	bronto.frames={bronto_idle,bronto_run1,bronto_run2,}
	bronto.c=15
	bronto.y0=11
	bronto.x0=-20
	bronto.s=.25 --speed
	bronto.rcr=8 --speed
	
	tree=new_ent()
	tree.frames={treepts}
	tree.c=10
	tree.y0=5
	tree.x0=10
	tree.t=0
	
	ovi=new_ent()
	egg=new_ent()
	ovi.frames={ovi_idle,ovi_run1,ovi_run2}
	egg.frames={eggpts}
	ovi.s=.5
	ovi.x0=80
	ovi.rcr=4		
	egg.x0=bwps[0]+30
	ovi.c=15
	egg.c=7
	ovi.y0=10
	egg.y0=-32
	egg.dy=.5
	egg.enabled=false
	ptero=new_ent()
	ptero.frames={pteropts1,pteropts2,}
	ptero.x0,ptero.y0=bwps[0],-20
	ptero.dx,ptero.⧗=1,0

	spino=new_ent()
	spino.frames={spino_idle}
	spino.x=80*2
	spino.y=-10
	spino.c=15

	fonts=font_parser(fontdata)

	local speciescolor=3

	add(speciestxt[1],cvstring("brontosaurus",0,-56,speciescolor,2))
	add(speciestxt[1],cvstring("herbivore",0,-50,13,1))

	add(speciestxt[2],cvstring("oviraptor",80,-56,speciescolor,2))
	add(speciestxt[2],cvstring("egg-i-vore",80,-50,13,1))

	add(speciestxt[3],cvstring("spinosaurus",160,-56,speciescolor,2))
	add(speciestxt[3],cvstring("fish-i-vore",160,-50,13,1))

	infocolor=13
	add(dinoinfo[1],cvstring("eats plants (slowly)",0,30,infocolor,1))
	add(dinoinfo[1],cvstring("t-rex is deadly",0,36,infocolor,1))
	add(dinoinfo[1],cvstring("death resets score multiplier",0,42,infocolor,1))

	add(dinoinfo[2],cvstring("catches dropped eggs",80,30,infocolor,1))
	add(dinoinfo[2],cvstring("volcano is annoying",80,36,infocolor,1))
	add(dinoinfo[2],cvstring("miss resets score multiplier",80,42,infocolor,1))

	add(dinoinfo[3],cvstring("snag flying fish",80*2,30,infocolor,1))
	add(dinoinfo[3],cvstring("the megalodon lurks",80*2,36,infocolor,1))
	add(dinoinfo[3],cvstring("lose fish on death/near miss",80*2,42,infocolor,1))	

	add(dbtext,cvstring("hatchling",0,12,13,1))
	add(dbtext,cvstring("mode",0,18,13,1))
	add(dbtext,cvstring("rex",bwps[1],12,13,1))
	add(dbtext,cvstring("mode",bwps[1],18,13,1))

	add(ditext,cvstring("eat up before the big one",0,38,13,1))
	add(ditext,cvstring("all asterods are deadly",bwps[1],38,13,1))

	add(pressx,cvstring("press x",0,48,13,1))

	--selection rect
	local s=36--one side of sqr
	local sp=5 --subpoints
	sframe1=tconcat(sframe1,
	usl({x=-s,y=-s}, --top left
					{x=s,y=-s},sp)) --top right
	sframe1=tconcat(sframe1,
	usl({x=s,y=-s}, --top right
					{x=s,y=s},sp)) --bottom right
	sframe1=tconcat(sframe1,
	usl({x=s,y=s}, --bottom right
					{x=-s,y=s},sp))	--bottom left
	sframe1=tconcat(sframe1,
	usl({x=-s,y=s}, --bottom left
					{x=-s,y=-s},sp))	--top left

	--earths (grounding line)
	for i=0,2 do
		add(earths,usl({x=-s+4+bwps[0]*i,y=10},{x=s-4+bwps[0]*i,y=10},10))
--		add(earths,usl({x=-s+4+bwps[0]*i,y=18},{x=s-4+bwps[0]*i,y=18},10))
	end

	--dino frames
	for i=0,2 do
		local frame={}
		local xoff=i*64+16*i
		frame=tconcat(frame,
		usl({x=-32+xoff,y=-32},
						{x=32+xoff,y=-32},sp))
		frame=tconcat(frame,
		usl({x=32+xoff,y=-32},
						{x=32+xoff,y=32},sp))
		frame=tconcat(frame,
		usl({x=32+xoff,y=32},
						{x=-32+xoff,y=32},sp))	
		frame=tconcat(frame,
		usl({x=-32+xoff,y=32},
						{x=-32+xoff,y=-32},sp))				
		add(dframes,frame)
	end
	
	--mode frames
	local my=0 --mode frames y pos
	local w,h=48,32 --width and height
--	w=bwps[1]
	w=bws[1]
--	local x1=-32
	local x1=-w/2
	local x2=x1+w
--	local y1=42
	local y1=44
	local y2=y1+h
	for i=0,1 do
		local frame={}
--		local xoff=i*w+16*i
		local xoff=i*bwps[1]
		frame=tconcat(frame,
		usl({x=x1+xoff,y=y1},
						{x=x2+xoff,y=y1},sp))
		frame=tconcat(frame,
		usl({x=x2+xoff,y=y1},
						{x=x2+xoff,y=y2},sp))
		frame=tconcat(frame,
		usl({x=x2+xoff,y=y2},
						{x=x1+xoff,y=y2},sp))	
		frame=tconcat(frame,
		usl({x=x1+xoff,y=y2},
						{x=x1+xoff,y=y1},sp))				
		add(mframes,frame)
	end

	y1=44-32
	y2=y1+h
	x1-=4
	x2+=4
	y1-=4
	y2+=4
	sframe2={}
	sframe2=tconcat(sframe2,
	usl({x=x1,y=y1},
					{x=x2,y=y1},sp))
	sframe2=tconcat(sframe2,
	usl({x=x2,y=y1},
					{x=x2,y=y2},sp))
	sframe2=tconcat(sframe2,
	usl({x=x2,y=y2},
					{x=x1,y=y2},sp))	
	sframe2=tconcat(sframe2,
	usl({x=x1,y=y2},
					{x=x1,y=y1},sp))	
end

function _update()
	
	⧗+=1
	
	--update bronto
	if yidx==0 and idxs[yidx]==0 then
		local dx=bronto.x0-tree.x0
		bronto.d=sgn(dx)*-1
		if abs(dx)>12 then
			bronto.x0=mid(bronto.x0,bronto.x0-bronto.s*sgn(dx),tree.x0)
			if ⧗%bronto.rcr<bronto.rcr/2 then --alternate
				bronto.fr=2
			else
				bronto.fr=3
			end
		else --eating
			bronto.fr=1
			tree.t+=1/60
			tree.r=rndr(-.01,.01)
			tree.frames={clamppoints(translate(treepts,0,-tree.t*25),tree.t)}
			--particles
			lp={}
			lp.x,lp.y=bronto.x0,bronto.y0
			lp.⧗=4
			lp.c=tree.c
			lp.type="point"
			lp.y-=18
			lp.x+=10*bronto.d
			lp.dx=rndr(-2,2)
			lp.dy=rndr(-2,2)
			lp.f=.8
			lp.g=.25
			add(parts[idxs[yidx]+1],lp)
		end
		if tree.t>1 then
			tree.t,tree.r,tree.y0=0,0,5
			tree.frames={treepts}
			local newt=rndr(-26,26)
			while abs(bronto.x0-newt)<12 do
				newt=rndr(-26,26)
			end
			tree.x0=newt
			
			bscore+=1
			tp={}
			tp.x,tp.y=bronto.x0,bronto.y0-20
			tp.⧗=30 tp.c=10
			tp.dx,tp.dy=0,-3
			tp.f=.8
			tp.type="text"
			tp.label="+"..bscore
			add(parts[idxs[yidx]+1],tp)

		end
	end
	
	--function oviraptor update
	if yidx==0 and idxs[yidx]==1 then
	
		ptero.⧗+=.005
		ptero.px0=ptero.x0
		ptero.x0=bwps[1]+16+cos(ptero.⧗)*32
		ptero.scale=(cos(ptero.⧗+.25)+1)/2	
		ptero.d=ptero.px0-ptero.x0>0 and -1 or 1
		ptero.fr=⧗%8>3 and 1 or 2
		
		if egg.enabled then
			egg.r+=.01
			egg.y0+=egg.dy		
			local dx=ovi.x0-egg.x0
			ovi.d=sgn(dx)*-1
			if abs(dx)>8 then
				ovi.x0=mid(ovi.x0,ovi.x0-ovi.s*sgn(dx),egg.x0)
				if ⧗%ovi.rcr<ovi.rcr/2 then --alternate
					ovi.fr=2
				else
					ovi.fr=3
				end
			else
				ovi.fr=1
			end
		else
			ovi.fr=1
		end
		if egg.y0>-4 and egg.enabled then
			egg.enabled=false
--			egg.⧗=30
			local nextx=bwps[1]+rnd()*32
			while abs(ovi.x0-nextx)<16 do
				nextx=bwps[1]+rnd()*32
			end
--			egg.nextx=nextx
			egg.x0=nextx
			egg.y0=ptero.y0
		end
		
		if ptero.d==1 and egg.enabled==false then
			if abs(ptero.x0-egg.x0)<1 then
				egg.enabled=true
			end
		end
	end
	
	if btn(➡️) and not moving then
		moving=true
		movetype="x"
		start⧗=⧗
		pidxs[yidx]=idxs[yidx]
		idxs[yidx]+=1
		resetphis()
	end
	
	if btn(⬅️) and not moving then
		moving=true
		movetype="x"
		start⧗=⧗
		pidxs[yidx]=idxs[yidx]
		idxs[yidx]-=1
--		resetdinoinfo()
		resetphis()
	end
	
	if btn(⬇️) and not moving then
		if yidx<1 then
			moving=true
			movetype="y"	
			start⧗=⧗
			pyidx=yidx
			yidx+=1	
		end		
		resetphis()
	end
	
	if btn(⬆️) and not moving then
		if yidx>0 then	
			moving=true
			movetype="y"	
			start⧗=⧗
			pyidx=yidx
			yidx-=1
		end
		resetphis()
	end
	
	if btnp(❎) then
		local dino=idxs[0]+1
		local mode=idxs[1]+1
		load("super-extinction-event",
			"back to menu",
			dino..","..mode)

	end
	
	if moving then
		local d=pidxs[yidx]-idxs[yidx]
		local dy=pyidx-yidx
--		local pct=(⧗-start⧗)/8
		pct=(⧗-start⧗)/8
		if pct>1 then 
			pct=1 
			moving=false 
		end
		pct=easeoutcubic(pct)
		if movetype=="x" then
			xoffs[yidx]=bwps[yidx]*idxs[yidx]+d*bwps[yidx]*(1-pct)
		end
		if movetype=="y" then
			yoff=32*yidx+dy*32*(1-pct)		
		end
	end
		
	bronto.x=bronto.x0-xoffs[0]
	bronto.y=bronto.y0-yoff
	
	tree.x=tree.x0-xoffs[0]
	tree.y=tree.y0-yoff
	
--	ovi.x=80-xoffs[0]
	ovi.x=ovi.x0-xoffs[0]
	ovi.y=ovi.y0-yoff
	egg.x=egg.x0-xoffs[0]
	egg.y=egg.y0-yoff
	ptero.x=ptero.x0-xoffs[0]
	ptero.y=ptero.y0-yoff
	
	spino.x=80*2-xoffs[0]
	spino.y=-yoff+10	
	
	doparticles()
end

function _draw()
	cls()

	camera(-64,-64)
		
	render_ent_sph(tree)

	for e in all(earths) do	
		color(2)
		line()
		for pair in all(e) do
			local x,y=pair.x-xoffs[0],pair.y-yoff
			x,y=sphp(x,y)
			line(x,y)
		end
	end

	render_ent_sph(ovi)
	render_ent_sph(spino)
	render_ent_sph(bronto)
	render_ent_sph(egg)
	render_ent_sph(ptero)

	for frame in all(dframes) do
		color(2)
		line()
		for pair in all(frame) do
			local x,y=pair.x-xoffs[0],pair.y-yoff
			x,y=sphp(x,y)
			line(x,y)
		end
	end
	
	--mode frames render
	if yidx==1 then
		for frame in all(mframes) do
			color(2)
			line()
			for pair in all(frame) do
				local x,y=pair.x-xoffs[1],pair.y-yoff
				x,y=sphp(x,y)
				line(x,y)
			end
		end
	end
	
	--selection frame render
	color(⧗%7>3 and 2 or 13)
	line()
	for i,pair in ipairs(sframe1) do
		local x1,y1=pair.x,pair.y
		local x2,y2=sframe2[i].x,sframe2[i].y

		local pct=movetype=="x" and 1 or pct

		local dx,dy=x2-x1,y2-y1
		local x,y=x1+dx*yidx*pct,y1+dy*yidx*pct

		if yidx==0 then
			local dx,dy=x1-x2,y1-y2
			x,y=x2+dx*pct,y2+dy*pct			
		end
		x,y=sphp(x,y)
		line(x,y)
	end
	
	color(14)
	for idx,text in ipairs(speciestxt[idxs[yidx]+1]) do
		color(text.clr or 14)
		for i,seg in ipairs(text) do
--		for i,seg in ipairs(speciestxt[idxs[yidx]+1]) do
				line()
				for pair in all(seg) do
					if pair.⧗<1 then
						pair.⧗+=.05
					else
						x,y=pair.x-xoffs[0],pair.y-yoff
						line(x,y)
					end				
				end	
		end	
	end
	
	if yidx==0 and not moving then
		for text in all(dinoinfo[idxs[yidx]+1]) do
			color(text.clr or 14)
			for seg in all(text) do
					line()
					for pair in all(seg) do
						if pair.⧗<1 then
							pair.⧗+=.15
						else
							line(pair.x-xoffs[0],pair.y)
						end				
					end	
			end	
		end
	end
	
	if yidx==1 then
		for text in all(dbtext) do
			color(text.clr or 14)
			for i,seg in ipairs(text) do
				line()
				for pair in all(seg) do
					local x,y=pair.x-xoffs[1],pair.y
					x,y=sphp(x,y)
					line(x,y)
				end	
			end	
		end
		
		if not moving then
			for i,seg in ipairs(ditext[idxs[yidx]+1]) do
				line()
				for pair in all(seg) do
					if pair.⧗<1 then
						pair.⧗+=.15
					else
						local x,y=pair.x-xoffs[1],pair.y
						line(x,y)				
					end
				end	
			end				
		end
	end
	
	for text in all(pressx) do
		color(⧗%7>3 and 2 or 13)
		for i,seg in ipairs(text) do
			line()
			for pair in all(seg) do
				local x,y=pair.x,pair.y
				line(x,y)
			end	
		end	
	end
		
	
	for part in all(parts[idxs[yidx]+1]) do
		if part.type=="line" then
			local x1=part.x+cos(part.a)*part.d
			local x2=part.x-cos(part.a)*part.d
			local y1=part.y+sin(part.a)*part.d
			local y2=part.y-sin(part.a)*part.d
			line(x1,y1,x2,y2,part.c)
		end
		if part.type=="point" then
			local px,py=gpos(part)
			pset(px,py,part.c)
		end
		if part.type=="text" then
			local px,py=gpos(part)
			cprint(part.label,px,py,part.c)
		end
	end

--	print(ptero.d,0,0,12)
	
	pal(split("129,130,14,132,133,134,135,136,137,138,139,140,141,142,143,0"),1)
end

function resetphis()

	local phi=0

	for text in all(ditext) do
		for i,seg in ipairs(text) do
			for pair in all(seg) do
				phi+=.61803398875
				pair.⧗=phi%1
			end	
		end
	end
	
	for info in all(dinoinfo) do
		for text in all(info) do
			for seg in all(text) do
					for pair in all(seg) do
						phi+=.61803398875
						pair.⧗=phi%1				
					end	
			end	
		end	
	end
	
	for text in all(speciestxt) do
		for t in all(text) do
			for seg in all(t) do
					for pair in all(seg) do
							phi+=.61803398875
							pair.⧗=phi%1				
					end	
			end	
		end	
	end

		
end

function easeoutcubic (x) 
	local ix=1-x
--	return 1 - math.pow(1 - x, 3);
	return 1-ix*ix*ix
end

function easeoutcirc (x)
--	return math.sqrt(1 - math.pow(x - 1, 2));
	local ix=x-1
	return sqrt(1 - ix*ix)
end

function render_ent2(e)
	if e.enabled==false then return end	
	renderpoly(pushtransforms(e),e.c)	
end

function clamppoints(ps,pct)
	local os={}
	
	local h=5-35*pct
	
	for i=1,#ps,2 do
	
		local x,y=ps[i],ps[i+1]
--		if y>h then y=h end
		if y>5 then y=5 end
	
		add(os,x) 
		add(os,y)
	end	
	return os	
end

function doparticles()

--	for partlayer in all(parts) do
		for part in all(parts[idxs[yidx]+1]) do
			part.⧗-=1
			if part.⧗<0 then
--				del(partlayer,part)
				del(parts[idxs[yidx]+1],part)
			end
			if part.type=="line" then
				part.a+=part.dr or 0
			end
			if part.g then
				local a=atan2(part.x,part.y)
				part.dx+=cos(a+.5)*part.g
				part.dy+=sin(a+.5)*part.g
			end			
			part.x+=part.dx
			part.y+=part.dy
			part.dx*=part.f or 1
			part.dy*=part.f or 1
		end		
--	end
end
-->8
bronto_idle=split("-4.3165,-4.0968,-8.3866,-3.0792,-2.2815,-10.2019,1.7886,-10.2019,3.8236,-20.377,7.8937,-20.377,7.8937,-17.3245,5.8587,-17.3245,4.8412,-9.1843,4.3324,-1.0442,2.8061,-1.2986,1.7886,-4.0968,-1.2639,-4.0968,-1.7727,-1.0442,-3.299,-0.7898")
bronto_run1=split("-4.3385,-3.7286,-8.6183,-3.7286,-2.1985,-10.1484,2.0814,-10.1484,6.3612,-16.5683,10.6411,-16.5683,10.6411,-13.3584,8.5012,-13.3584,5.2913,-9.0785,7.9662,-1.5887,6.3612,-0.7862,2.0814,-3.7286,-1.1285,-3.7286,-3.8035,-0.5187,-5.4084,-0.2512")
bronto_run2=split("-4.377,-3.6942,-8.698,-3.6942,-2.2166,-10.1757,2.1044,-10.1757,6.4254,-16.6572,10.7464,-16.6572,10.7464,-13.4164,8.5859,-13.4164,5.3452,-9.0955,3.7248,-0.4535,1.0242,-0.7236,2.1044,-3.6942,-1.1363,-3.6942,-0.5962,-0.4535,-3.2968,-0.1834")
treepts=split("3.62,-8.69,3.04,-10.49,12.04,-11.49,10.04,-15.49,3.04,-16.49,2.04,-14.49,0.56,-18.11,-1.87,-19.29,-9.1,-16.13,-9.48,-13.86,-7.96,-11.49,-5.96,-13.49,0.04,-11.49,-1.66,-9.52,-2.83,-5.74,-3.07,0.17,-0.96,5.51,4.04,4.4,2.78,-0.14,2.92,-5.38,3.62,-8.69")

ovi_idle=split("6.508674,-10.950344,7.798465,-10.501721,8.359244,-13.13738,5.162806,-12.969147,3.816937,-9.268008,-5.491988,-13.081302,-12.333487,-12.071901,-5.884533,-11.511122,-3.417107,-7.697828,-5.828455,-6.183725,-8.015492,-1.192796,-5.267677,-0.463784,-4.987287,-1.697496,-6.221,-2.202197,-4.65082,-4.613545,-0.388903,-6.07157,-1.342226,-3.996689,1.349511,-0.29555,3.031847,-0.632017,0.396187,-4.164922,3.929093,-6.800582,5.106728,-4.333156,4.770261,-2.370431,6.284363,-3.43591,8.415321,-3.099443,7.686309,-5.398635,5.611428,-6.688426")
ovi_run1=split("7.196866,-8.870799,9.271747,-8.702565,9.832526,-11.338224,6.636088,-11.169991,3.103183,-9.431577,-13.047242,-12.23547,-4.130861,-7.861397,-5.981431,-5.618282,-8.729246,-1.356365,-7.102988,-0.571274,-4.972029,-3.711635,-0.597956,-5.001426,0.635757,-3.31909,4.617285,-1.46852,6.299621,-1.804987,2.542404,-4.60888,3.944351,-6.066905,7.084711,-5.618282,8.206268,-6.627683,5.626686,-7.524929")
ovi_run2=split("7.309022,-8.887946,9.383903,-8.719712,9.944682,-11.355371,6.748244,-11.187138,3.215338,-9.448724,-12.935086,-12.252617,-4.018705,-7.878544,-1.817649,-4.710145,-2.616759,-3.111925,-2.448526,-1.569785,-1.158734,-1.429589,-0.177373,-3.588588,1.617119,-1.766056,2.598482,-1.850176,1.420847,-4.990536,4.140624,-6.532678,7.196867,-5.635432,8.318423,-6.644833,5.738842,-7.542079")
eggpts=split("1.51,2.5,2.51,1.5,2.51,-1.5,0.51,-3.5,-1.49,-1.5,-1.49,1.5,-0.49,2.5,1.51,2.5")
pteropts1=split("-9.49,2.5,-1.18,-2.28,-0.49,-8.5,3.91,-0.48,5.51,-1.5,4.51,-4.5,7.51,-3.5,9.51,-1.5,12.51,0.5,7.51,0.5,5.9,1.66,3.51,1.5,0.41,3.03,-1.62,0.75,-2.49,1.5,-4.53,1.14,-9.49,2.5")
pteropts2=split("-10.49,1.5,-2.18,-3.28,2.91,-1.48,4.51,-2.5,3.51,-5.5,6.51,-4.5,8.51,-2.5,11.51,-0.5,6.51,-0.5,4.9,0.66,2.51,0.5,6.51,3.5,4.51,3.5,1.02,8.36,-1.44,3.97,-0.59,2.03,-2.62,-0.25,-3.49,0.5,-5.53,0.14,-10.49,1.5")

spino_idle=split("10.2588,-12.4154,1.2287,-12.2932,-1.2379,-11.8621,-1.6886,-6.5319,-5.0059,-10.968,-7.9749,-11.0008,-8.2998,-8.1142,-10.767,-7.949,-8.9469,-3.9229,-13.9308,1.8989,-8.41,-1.9838,-6.0712,-0.0103,-5.5888,-3.0054,-2.0063,-3.2898,1.1567,-0.311,1.5067,-3.6278,0.9369,-6.6742,1.1741,-9.4058,11.4112,-11.1017")

ddz=32 --distortion dead zone
--ddz=0 --distortion dead zone
dst=128 --distortion strength
--dst=128 --distortion strength

function new_ent()
	local e={}
	e.x,e.y,e.r,e.d,e.fr,e.enabled=
	0,0,0,1,1,true
	e.dx,e.dy,e.dr=
	0,0,0
	return e
end

----sphere projection point
function sphp(x,y)
	local d=disto(x,y)
	
	if d>ddz then
--		local z=(d-dz)/(128-dz)
		local z=(d-ddz)/(dst-ddz)
		x=x/(1+z)
		y=y/(1+z)	
	end		
	return x,y
end

--sphere projection point
--function sphp(x,y)
--	local d=abs(x)
--	
--	local dz=16--distortion deadzone
--	
--	if d>dz then
----		local z=(d-dz)/(128-dz)
--		local z=(d-dz)/(256-dz)
--		x=x/(1+z)
----		y=y/(1+z)	
--	end		
--	return x,y
--end

function render_ent_sph(e)
	if e.enabled==false then return end	
	renderpoly(sph(pushtransforms(e)),e.c)	
end

function sph(ps)
	local os={}
	for i=1,#ps,2 do
	
		local x,y=ps[i],ps[i+1]
		local d=disto(x,y)
		
		local ddz=16--distortion deadzone
		
		if d>ddz then
			local z=(d-ddz)/(dst-ddz)
			x=x/(1+z)
			y=y/(1+z)	
		end		
	
		add(os,x) 
		add(os,y)
	end	
	return os
end

--unsimplified line
--make a line segments with 
--n vertices instead of 2
function usl(a,b,n)
	local segs={}
	local dx,dy=b.x-a.x,b.y-a.y
		
	for i=0,n do
		local t=i/n
		add(segs,{x=a.x+dx*t,y=a.y+dy*t})
	end
	return segs
end

-->8
----painto-8 lite
do
local old_draw=_draw
poke(0x5f2d,1)
poke(0x5f2e,1)

local old_pal=pal

local draw_func=function()
    old_draw()
    pal=function(...)
     local t={...}
     if #t==0 then
      old_pal(split("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0"))
      palt()
      fillp()
     elseif type(t[1])=="table"
     and #t==2
     or #t==3 then
     
     else
      old_pal(t[1],t[2])
     end
    end
end

local sel_pal=sel_pal or 0
local game_palette={}
local sel_clr=sel_clr or 0
local draw_state,press={}
local active
_draw=function()
 if band(stat"34",2)==2 then
  press=press and press+1 or 0
  if (press==0) active=not active
 else
  press=nil
 end
 
 local mousex,mousey=stat"32",stat"33"
 
 draw_func()
    local pal=old_pal
    for i=0,15 do
     game_palette[i]=peek(0x5f10+i)
    end
 if active then
        pal()
     for i=0x5f00,0x5f3f do
      draw_state[i]=peek(i)
     end
     
     if band(stat"34",1)==1 then
      local x8=mousex\8
      if mousey<=8 then
       sel_clr=x8
      elseif mousey<=16 then
       game_palette[sel_clr]=x8+128*sel_pal
       local s="pal(split(\""
       for i=0,14 do
        s..=game_palette[i+1]..","
       end
       s..=game_palette[0].."\"),1)"
       printh(s,"@clip")
      elseif mousey<=23 and mousey<=36 then
       sel_pal=mousex\18
      end
     end
     
     clip()
     camera()
     fillp()
     --current palette
     rectfill(0,0,127,8,1)
     for i=0,15 do
      rectfill(i*8,0,i*8+7,7,i)
     end
     rect(sel_clr*8-1,-1,sel_clr*8+8,8,7)
     rect(sel_clr*8,0,sel_clr*8+7,7,0)
     pal()
     
     --swap palette
     for i=0,15 do
      rectfill(i*8,9,i*8+7,16,i)
     end
     
     --
     rectfill(0,17,36,23,1)
     ?"pal1",1,18,sel_pal==0 and 7 or 5
     ?"pal2",21,18,sel_pal==1 and 7 or 5
     
     pset(mousex,mousey,8)
     
     for i=0x5f00,0x5f3f do
      poke(i,draw_state[i])
     end
     poke(0x5f5f,0x10)
     
     poke(0x5f71,0xfe)
     poke(0x5f72,1)
    else
        pal()
  memset(0x5f71,0,2)
    end
 --screen palette 2
 for i=0,15 do
  pal(i,i+128*sel_pal,2)
  pal(i,game_palette[i],1)
 end
end
end
-->8
rexgoals={50,40,10,}
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
95010020062200612006520067300603006040060400605006050070500806008760095700a3700a2700b2700c3700c3700d3700e3700e1600f1600f160101601015011150121501214013140131401414014140
