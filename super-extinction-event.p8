pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--super extinction event
--casey labrack

--todo:
 --spinosaurus: fish pop up
 	--you grab, roid near misses 
 	--pop them out of your mouth
 	--and in the air again
	--egg crack game mode
	--2p is palm tree and egg goals
		--at the same time
	--stego mode: push a boulder
		--into a tarpit
		
--😐
	--mult is # in a row?
	--score threshold to unlock
		--extra hard mode variant
		--(like meat boy hell world)
		--rex mode. and hyperex mode
		--crown appears on dino
		--roids lethal only in rex mode?
	--score animation is dino
		--running around circumference
		--where 1 turn is hell world
		--and a marker for previous best
		--and crown at 0 degrees?
		--replay all score callouts
	--pickup text: "neat","rad","wicked"
		--instead of numerical score
		--including end of game total
		--color the text
	--jiggle vertices
	--multiplier color coded
		--maybe only color?
	--can jump (volcano)
	--time scale?
	--slow time?
	--just roids; volcano; trex
	--hypercubes
	--ptero can swoop up over obstacles
		--so we can have multiple obstacles
		--ptero's idle is perched
	--hypercube
	--stars
	--add occasion eggs to plant games and vice versa
 --respawn animation: egg hatch
	--gameover animation
		--every game ends with the big one?
		--hit and fly off into space?
		--turn into bird?
		--earth shatters,exposing score screen
		--trophy flies from foreground (scaled up), down and crashes through last troph (silver->gold)
	--hitstop maybe
	--leaves are round, scales down
 --pterodactyl pushed by roids, bronto killed?
 --bronto stands to eat animation?
	--"super extinction challenge"?
	--'nautilus' is pretty nice for this

log=""

defaultchallenge=1
--challenges:
--1: trex
--2: volcano
--3: eggs
--4: egg volcano

rexgoals={350,100,100,100}

function _init()

	cartdata("caseylabrack_superdino")
	
	pal({[0]=0,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143},1)
	
	reinit()
end

function reinit()
	log=""
	⧗=0 --tick (frame count)
	g⧗=60 --game time
	score=0
	oldhs=0 --old high score
	mult=1
	mult2=0
	lmult2=0
	shake=0
	gameover=false
	
	stara=0
	trexs={}
	trees={}
	vs={}
	ss={}
	rs={}
	parts={}
	bo={x=-64,y=-64,r=0,c=6,enabled=true,
	fr=1,frames={bigonepts}}
	eggs={}
	ebirds={} --egg birds
	isrex=false
	scores={}
	
	--player
	p={x=64,y=29,r=0,state="idle",enabled=true,dx=0,dy=0,
		--angle, delta angle, mag, delta mag, grounded
	 a=.25,da=0,m=37,dm=0,gr=true,
		--speed, facing direction,
	 s=.004,d=1,c=15,
	 --last position
	 lpx,lpy=0,0,
	 --frame index, all frames
	 fr=1,frames={bronto_idle,bronto_run1,bronto_run2,}
	}
	
	pdead={x=0,y=-37,r=0,c=p.c,⧗=0,enabled=false,fr=1,frames={}}
	e={x=0,y=0,a=0,r=0,s=.01,d=1,c=130,
		enabled=true,
		fr=1,frames={earthconts}}

	--center artwork on origin
	for i=1,#p.frames do
		p.frames[i]=translate(p.frames[i],28,13)
	end
	pdead.frames[1]=p.frames[1]

	p.x=0
	p.y=-30
	p.parent=e
	
	cr={x=0,y=0,r=0,enabled=false,
		fr=1,frames={crownpts},c=7}
	cr.parent=p
	cr.y=-16	cr.x=7
	
	chal=stat(6)
	if chal=="" then
		chal=""..defaultchallenge
	end
 chal=tonum(chal)

	oldhs=dget(chal)
	if oldhs>rexgoals[chal] then
		isrex=true
		cr.enabled=true
	end

	if contains({2},chal) then
		spawnvolcano()
		lethalroids=true
	end

	if contains({1},chal) then
		spawntrex()
	end
	
	if contains({1,2},chal) then
		spawntree()	
	end
	
	if contains({3},chal) then
		spawnptero()
		lethalroids=true
	end
	
	if contains({4},chal) then
		spawnvolcano()
		spawnptero()
		lethalroids=true
	end
	
--	g⧗=1
--	scores={5,10,17,8,10,19,4,2,6}
--	scores={5,17,19,4}
end

function _update()

	⧗+=1
	e.x,e.y=0,0

	if ⧗%60==0 then
--	if g⧗>0 then
		g⧗-=1
	end
	
	stara+=.001

	if p.enabled then	mult+=1 end

	lmult2=mult2
	zpct=mid(.1,mid(1,mult,1000)/1000,1)
	zpct=zpct*zpct
--	zpct=mid(1,mult,1000)/1000
--	zpct=easeoutcubic(zpct)
	mult2=ceil(20*zpct)
			
	--big one approaches
	local pct=g⧗/60
	local impact=0--49
	local startdist=78
	local travel=startdist-impact
	local d=travel*pct+impact
	bo.x=cos(.375)*d
	bo.y=sin(.375)*d

	--dramatic shaking right before impact
	if g⧗<8 and g⧗>0 then
		local pct=1-g⧗/6
--		local pct=easeinexpo(pct)
		local pct=pct*pct*pct
		local mx=12*pct
--		e.x=rnd()*mx
--		e.y=rnd()*mx
		bo.x+=rnd()*mx
		bo.y+=rnd()*mx
	end	
	
	--gameover handle
	if g⧗==0 and not gameover then
		gameover=true
		e⧗=0 --ticks since gameover

		--score
		score=0
		rscore=0 --running score
		nscore=#scores
		for s in all(scores) do
			score+=s
		end	
		if score>oldhs then
			dset(chal,score)
		end

		pdead.enabled=false

		local todestroy=tconcat({bo,e,p,cr},rs,vs,trexs,trees,ebirds,ss,eggs)

		for d in all(todestroy) do		
			if not d.enabled then goto destroycontinue end
			d.enabled=false		
			local lines=ent2lineparts(d)		
			for part in all(lines) do
				local a=atan2(part.x,part.y)
				local d=disto(part.x,part.y)
				local f=1/d*60
				part.dx,part.dy=cos(a)*f,sin(a)*f
				part.f=rndr(.9,.95)
				part.⧗=rndr(10,60)
				part.dr=rndr(-0.005,.005)
				add(parts,part)
			end 
			::destroycontinue::
		end		
	end

	doparticles()

	if gameover then 
		e⧗+=1 
	
		if e⧗>30 then
			if btnp(❎) then
				reinit()
			end
		end		
	end
	if gameover then return end
	
	e.r+=.01
	
	--do egg pterodactyls
	for eb in all(ebirds) do
		eb.⧗+=1
		if eb.state=="fly" then
			if eb.⧗<eb.f⧗ then
				local t=eb.⧗/eb.f⧗
				t=easeinoutcubic(t)
				eb.t=t
				local a=(eb.ea-eb.sa)*t+eb.sa
				eb.x,eb.y=cos(a)*55,sin(a)*55			
			else
				eb.state="drop"
				eb.⧗=0
			end
		elseif eb.state=="drop" then
			if eb.⧗==1 then
				--drop egg
				local egg={}
				local a=atan2(eb.x,eb.y)
				egg.x,egg.y=eb.x,eb.y
				egg.dx,egg.dy=cos(a+.5)/3,sin(a+.5)/3
				egg.r=a+.75
				egg.c=7 egg.enabled=true
				egg.fr=1 egg.frames={eggpts}
				add(eggs,egg)
				
				eb.f⧗=rndr(60,180)
				eb.sa=a
				eb.ea=a+rndr(.5,1.5)
				eb.state="fly"
				eb.⧗=0
			end
		end	
		local a=atan2(eb.x,eb.y)
		eb.r=a+.75
		local flapr=30 --flap rate
		flapr-=(1-abs(.5-eb.t))*16
		if ⧗%flapr<(flapr/2) then
			eb.fr=1
		else
			eb.fr=2
		end
	end
	
	--eggs	
	for egg in all(eggs) do
		egg.x+=egg.dx
		egg.y+=egg.dy
		egg.r+=.01
		
		local gpx,gpy=gpos(p)
		local ga=atan2(gpx,gpy)
		local ea=atan2(egg.x,egg.y)
		
		if distt(egg,e)<35  
			and abs(sad(ga,ea))<.04 then
			ep={}
			ep.x,ep.y=egg.x,egg.y
			ep.⧗=30 ep.c=9
--			local a=atan2(ep.x,ep.y)
			ep.x+=cos(ea)*20
			ep.y+=sin(ea)*20
			ep.dx,ep.dy=cos(ea)*2,sin(ea)*2
			ep.f=.8
			ep.type="text"
			ep.label="+"..mult2
			add(parts,ep)
			del(eggs,egg)
			
			score+=mult2
			add(scores,mult2)
		end
		
		--egg smash
		if distt(egg,e)<30 then
		
			local lines=ent2lineparts(egg)		
			for part in all(lines) do
				part.dx=egg.dx*-1*6
				part.dy=egg.dy*-1*6
				part.f=.7--rndr(.7,2)
				part.g=.1
				part.⧗=rndr(10,30)
				part.dr=rndr(-0.05,.05)
				add(parts,part)
			end 
			del(eggs,egg)
		end
	end
	
	--fire roids
	if ⧗%14==0 then
		local roid={}
		local a=rnd()
		roid.x,roid.y=cos(a)*70,sin(a)*70
		roid.dx,roid.dy=cos(a+.5),sin(a+.5)
		roid.r=rnd() roid.c=141--134
		roid.enabled=true
		roid.fr=ceil(rnd()+.5) roid.frames={roidspr1,roidspr2}
		add(rs,roid)
	end
		
	--do roids
	for roid in all(rs) do
		roid.x+=roid.dx
		roid.y+=roid.dy
		
		--roid particle
		local rp={}
		rp.x,rp.y=roid.x+roid.dx*4+rndr(-2,2),roid.y+roid.dy*4+rndr(-2,2)
		local ra=atan2(rp.x,rp.y)
		rp.dx,rp.dy=cos(ra)*9,sin(ra)*9
		rp.type="point"
		rp.⧗=4 rp.c=5 rp.f=.25
		add(parts,rp)
		
		if distt(roid,e)<30 then
			del(rs,roid) --probably do don't this
			local s={⧗=0}
			s.x,s.y,s.r=roid.x,roid.y,0
			s.d=1 s.r=0 s.fr=1 s.c=9
			s.enabled=true
			s.frames={impactpts}
			addchild(e,s)
			add(ss,s)
			
			--knockback/hit
			sa=atan2(s.x,s.y)
			pa=atan2(p.x,p.y)
			
			diff=sad(sa,pa)
			if abs(diff)<.1 then
				local pct=1-abs(diff)/.1
--				local pct=sgn(diff)-(diff/.1)
				pct=pct*pct
				p.da+=pct*.075*sgn(diff)
				p.gr=false
				p.dm+=6*pct
			end
			if lethalroids and abs(diff)<.04 and p.enabled then
				playerdied()
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
	
	--player
	--record position last frame
	p.lpx,p.lpy=gpos(p)
	
	if pdead.enabled then
		pdead.⧗+=1
	end
	
	if p.enabled then
		p.state="idle"
		if btn(⬅️) then
			if p.gr then p.da+=p.s p.d=-1 end
			p.state="run" 
		end
		if btn(➡️) then 
			if p.gr then p.da-=p.s p.d=1 end
	  p.state="run" 
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
		
		--rising and falling
		if not p.gr then
			p.dm-=1 --gravity
			p.m+=p.dm
			if p.m<37 then
				p.gr=true
				p.m=37
				p.dm=0
			end
		end
		
		local a=atan2(p.x,p.y)
		
		--colliding with volcano?
		for v in all(vs) do
			local va=atan2(v.x,v.y)
			local pa=atan2(p.x,p.y)
			local vdiff=sad(va,pa)
	
			--player moving toward volcano
			if sgn(vdiff)~=sgn(p.da) then
				if abs(p.da)>abs(vdiff)-.05 then
					a=va+.05*sgn(vdiff)--fixed angle
					p.da=0
				end
			end
		end		
		
		a+=p.da
		
		p.x=cos(a)*p.m
		p.y=sin(a)*p.m
		p.r=a+.75--stand upright
		p.da*=.75--friction
	else
		if pdead.⧗>60 then
			if btn()~=0 then
				p.enabled=true
				p.parent=nil
				p.x,p.y,p.da=0,-37,0
				p.dx,p.dy,p.dm,p.gr=0,0,0,true
				p.m=37
				p.d=1
				addchild(e,p)
				pdead.enabled=false
				pdead.⧗=0
				if isrex then cr.enabled=true end
			end
		end	
	end
		
	--eat leaves
	if p.enabled then
		for tree in all(trees) do
			local myangle=atan2(tree.x,tree.y)
			local pangle=atan2(p.x,p.y)
			local diff=sad(myangle,pangle)		
			
			if abs(diff)<.1 then
				tree.ec+=1
				if tree.ec<60 then
					local pct=tree.ec/60
					local ta=atan2(tree.x,tree.y)
					tree.x=cos(ta+.5)*(-30+18*pct)
					tree.y=sin(ta+.5)*(-30+18*pct)
					tree.r=ta+.75+rndr(-.05,.05)
					
					--particles
					lp={}
					lp.x,lp.y=gpos(p)
					lp.⧗=4
					lp.c=tree.c
					lp.type="point"
					addchild(e,lp)
					local a=atan2(p.x,p.y)
					--move up from body
					lp.x+=cos(a)*12
					lp.y+=sin(a)*12
					--move out toward mouth
					lp.x+=cos(a+.25)*10*p.d*-1
					lp.y+=sin(a+.25)*10*p.d*-1
					lp.dx=rndr(-2,2)
					lp.dy=rndr(-2,2)
					lp.f=.8
					lp.g=.25
					add(parts,lp)					
				else
				 --points particle
					tp={}
					tp.x,tp.y=gpos(tree)
					tp.⧗=30 tp.c=tree.c
					local a=atan2(tp.x,tp.y)
					tp.x+=cos(a)*20
					tp.y+=sin(a)*20
					tp.dx,tp.dy=cos(a)*2,sin(a)*2
					tp.f=.8
					tp.type="text"
					tp.label="+"..mult2
					add(parts,tp)

					del(trees,tree)
					score+=mult2
					add(scores,mult2)
					spawntree()
				end								
			end 
		end
	end
	
	--trex chase
	for t in all(trexs) do	
		if p.enabled then
			pa=atan2(p.x,p.y)
			ta=atan2(t.x,t.y)
			
			--player killed
			diff=sad(pa,ta)
			if abs(diff)<.05 then
				playerdied()
			elseif abs(diff)<.3 then
				ta+=t.s*sgn(diff)*-1
				t.x=cos(ta)*36
				t.y=sin(ta)*36
				t.r=ta+.75
				t.d=sgn(diff)
				if ⧗%8<4 then --alternate
					t.fr=2
				else
					t.fr=3
				end
				if ⧗%8==5 then --stomp
					shake=12
				end
			else
				t.fr=1
			end
		else
			t.fr=1		
		end
	end	
end

function _draw()
	cls()
	
	--stars attempt
--	for i=1,500 do
--		local a=(i+stara)*1.618
--		local r=8*i--c*sqrt(i)
--		local x=cos(a)*r
--		local y=sin(a)*r
--		if mid(0,x,128)==x and
--			mid(0,y,128)==y then
--				pset(x,y,6)		
--		end
--	end
	
	camera(-64,-64)
	
	if shake>0 then
		local a=rnd()
		local mag=(shake/8)^2
		e.x,e.y=cos(a)*mag,sin(a)*mag
		shake-=1
	end
		
	for splode in all(ss) do
		render_ent(splode)
	end	
	
	for tree in all(trees) do
		render_ent(tree)
	end
	
	for v in all(vs) do
		render_ent(v)
	end
	
	for egg in all(eggs) do
		render_ent(egg)
--		circ(egg.x,egg.y,4,14)
	end
	
	--earth surface,fill
	if not gameover then
		circfill(e.x,e.y,29,0)	
		circ(e.x,e.y,29,e.c)
	end
	--	circ(0,0,3,11)--ctr ref
		
	for roid in all(rs) do
		render_ent(roid)
	end
	
	render_ent(cr)
		
	if p.enabled then 
		render_ent(p)
	else
		if pdead.⧗>60 then
			if ⧗%12<6 then
				render_ent(pdead)
			end				
		end
	end
		
	render_ent(e)
	for t in all(trexs) do
		render_ent(t)	
	end
	
	for eb in all(ebirds) do
		render_ent(eb)
--		rect(eb.x,eb.y,eb.x+5,eb.y+5,15)
	end
			
	render_ent(bo)
	if bo.enabled~=false then
		print("the\nbig\none",bo.x-6,bo.y-8,bo.c)
	end
		
	for part in all(parts) do
		if part.type=="line" then
--			line(part[1],part[2],part[3],part[4],part.c)
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
	
	
	if gameover then
		cprint("extinct!",0,-34,6)
		
		local endline=max(score,max(oldhs,rexgoals[chal]))
		
		local rpct=mid(0,e⧗/30,1)
		circ(0,0,128-65*rpct,2)
		
		if e⧗>45 then
		
			e2⧗=e⧗-45
			
			--track
			line(-34,0,34,0,5)
			
			if #scores>0 then
				if e2⧗%(flr(60/nscore))==0 then
					sc=deli(scores,1)					
					rscore+=sc
					
					z={}
					z.x=-34+34*2*(rscore/endline)
					z.y=0
					z.⧗=30 z.c=9
					z.dx,z.dy=0,rndr(-3,-1)
					z.f=.8
					z.type="text"
					
					z.label="+"..sc		
					add(parts,z)
				end
				
			end

			local scorep=rscore/endline
			local endpoint=-34+(34*2)*scorep
			line(-34,0,endpoint,0,10)			
			circ(endpoint,0,1)
			
			hspct=oldhs/endline
			hsmark=-34+(34*2)*hspct-1
			spr(16,hsmark,2)

			local col=6
			if rscore>oldhs then
				if e⧗%6==0 then
					col=9
				end
				cprint("new best!",0,18,col) 
			end
			print("best",hsmark-6,5,col)
			
			goalpct=rexgoals[chal]/endline
			goalcr=translate(crownpts,34+-34*2*goalpct,8)
			local col=6
			if rscore>rexgoals[chal] then
				if e⧗%6==0 then
					col=9
				end
				local msg="beat the rex score!"
				if oldhs<rexgoals[chal] then
					msg="unlocked rex mode!"				
				end
				cprint(msg,0,26,col)
			end
			
			renderpoly(goalcr,col)
			spr(16,-34+34*2*goalpct-1,-10,1,1,false,true)
			
			cprint("❎ try again",0,42,6)
		end
	end

	camera()
		
--	line(0,126,128*(g⧗/60),126,7)	
		
	print(log,0,10,11)
	print("X",0,113,7)
	color(7)
	if lmult2~=mult2 then
		color(9)
	end
	if mult2==20 then
		if ⧗%4==0 then color(9) end
	end
	print(" "..mult2,0,113)
	print(" "..score,0,120,7)
end

function playerdied()
	p.enabled=false
	pdead.enabled=true
	p.dm,p.m,p.gr=0,37,true
	mult=0
	local px,py=gpos(p)
	local dinoparts=ent2lineparts(p)
	for dp in all(dinoparts) do
		dp.dx,dp.dy=(px-p.lpx)*rnd()/2,(py-p.lpy)*rnd()/2
		dp.⧗=40+rndr(-20,20)
		dp.dr=.0025
		add(parts,dp)
	end
	
	if cr.enabled then
		cr.enabled=false
		local crparts=ent2lineparts(cr)
		for cr in all(crparts) do
			cr.dx,cr.dy=(px-p.lpx)*rnd()/2,(py-p.lpy)*rnd()/2
			cr.⧗=40+rndr(-20,20)
			cr.dr=.0025
			add(parts,cr)
		end
	end
end

function doparticles()
	for part in all(parts) do
		part.⧗-=1
		if part.⧗<0 then
			del(parts,part)
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

--random range, from low to high not inclusive
function rndr(low,high)
	return low+rnd(high-low)
end

--table concat
--sequences (arrays) only
function tconcat(...) 
 local result={}
 local arrays={...}
	for array in all(arrays) do
		for _,v in ipairs(array) do
			add(result,v)
		end
	end	
	return result
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

function easeoutcubic(x)
	return 1-(1 - x)^3
end

function easeinoutcubic(x) 
	return x < 0.5 and (4 * x * x * x) or (1 - ((-2 * x + 2)^3) / 2)
end

function cprint(str,x,y,col)
 local strl=#str
 print(str,x-strl*2,y,col)
end

function contains(xs,x)
	for thing in all(xs) do
		if thing==x then
			return true
		end
	end
	return false
end

--points array to line segments
function p2ls(pts)
	local lx={}
	for i=1,#pts-2,2 do
		add(lx,{pts[i],pts[i+1],pts[i+2],pts[i+3],})
	end
	return lx
end

--entity to line particles
function ent2lineparts(e)
	epoints=p2ls(pushtransforms(e))
	eparts={}
	for part in all(epoints) do
		part.x,part.y=(part[3]+part[1])/2,(part[4]+part[2])/2
		part.c=e.c or 8 
		part.⧗=30
		part.a=atan2(part.x-part[1],part.y-part[2])
		part.d=dist(part[1],part[2],part[3],part[4])/2		
		part.f=1
		part.dx,part.dy=0,0
		part.type="line"
		add(eparts,part)
	end
	return eparts
end

function translate(ps,x,y)
	local os={}
	for i=1,#ps,2 do
		add(os,ps[i]-x)
		add(os,ps[i+1]-y)
	end	
	return os
end

function jiggle(ps,a)
	local os={}
	for p in all(ps) do
		add(os,p+rndr(-a,a))
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
		add(os,ps[i]*(sx or 1))
		add(os,ps[i+1]*(sy or 1))
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
	local myrote=e.r or 0
	if p then
		return p.r+myrote
	end
	return myrote
end

function gposr(e)
	local obj=e
	local x,y,r=e.x,e.y,e.r
	
	while(obj.parent) do
		local a=atan2(x*obj.parent.d,y)+obj.parent.r
		local d=disto(x*obj.parent.d,y)
		x=obj.parent.x+cos(a)*d
		y=obj.parent.y+sin(a)*d
		r=obj.parent.r+(obj.r or 0)
		obj=obj.parent
	end

	return x,y,r	
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

--function pushtransforms(e)
--	local es=e.scale or 1
--	local frame=e.frames[e.fr]
--	local scaled=scale(frame,(e.d or 1)*es,1*es)
--	local rotated=rotate(scaled,grote(e))
--	local x,y=gpos(e)
--	return translate(rotated,-x,-y)
--end

function pushtransforms(e)
	local es=e.scale or 1
	local frame=e.frames[e.fr]
	local scaled=scale(frame,(e.d or 1)*es,1*es)	
	local x,y,r=gposr(e)
	local rotated=rotate(scaled,r)
	return translate(rotated,-x,-y)
end

--function render_ent(e)
--	if e.enabled==false then return end
--	local es=e.scale or 1
--	local frame=e.frames[e.fr]
--	local scaled=scale(frame,(e.d or 1)*es,1*es)
--	local rotated=rotate(scaled,grote(e))
--	local x,y=gpos(e)
--	local translated=translate(rotated,-x,-y)
--	renderpoly(translated,e.c)
--end

--function render_ent(e)
--	if e.enabled==false then return end
--	local es=e.scale or 1
--	local frame=e.frames[e.fr]
--	local scaled=scale(frame,(e.d or 1)*es,1*es)	
--	local x,y,r=gposr(e)
--	local rotated=rotate(scaled,r)
--	local translated=translate(rotated,-x,-y)
--	renderpoly(translated,e.c)	
--end

function render_ent(e)
	if e.enabled==false then return end	
	renderpoly(pushtransforms(e),e.c)	
end

--render ent multiframe
function render_ent_m(e)
	local es=e.scale or 1
	for _,frame in ipairs(e.frames[e.fr]) do
		local scaled=scale(frame,(e.d or 1)*es,1*es)
		local rotated=rotate(scaled,grote(e))
		local x,y=gpos(e)
		local translated=translate(rotated,-x,-y)
		renderpoly(translated,frame.c or e.c)	
	end
end
-->8
--things
function spawntree()
	local a=rnd()
	local t={x=cos(a)*30,y=sin(a)*30,
	r=a+.75,d=1,c=10,enabled=true,
 --eat count
	ec=0,
	fr=1,frames={treepts}}
	addchild(e,t)
	add(trees,t)
end

function spawntrex()
	local t={x=0,y=0,r=0,d=1,c=14,s=.005,
		enabled=true,
		fr=1,frames={trexidle,trexrun1,trexrun2,}
	}
	
	t.x=0
	t.y=36
	t.r=.5
	t.parent=e
	add(trexs,t)
end

function spawnvolcano()
	local v={}
	local a=rnd()
	v.x,v.y=cos(a)*32,sin(a)*32
	v.r=a+.75
	v.c=6
	v.parent=e
	v.fr=1
	v.enabled=true
	v.frames={volcanopts}
	add(vs,v)
end

function spawnptero()
	local p={}
	local a=rnd()
	p.x,p.y=cos(a)*55,sin(a)*55
	p.enabled=true
	p.r=.75
	p.state="fly"
	p.⧗=0
	p.f⧗=rndr(60,180)--final time (til drop egg)
	p.sa=0--start angle
	p.ea=rnd()--end angle
	p.c=7
	p.fr=1
	p.frames={pteropts1,pteropts2}
	p.d=-1
	add(ebirds,p)
end
-->8
--sprites
bronto_idle=split("24.51,16.5,20.51,17.5,26.51,10.5,30.51,10.5,32.51,.5,36.51,.5,36.51,3.5,34.51,3.5,33.51,11.5,32.97,19.56,31.61,19.31,30.51,16.5,27.51,16.5,26.89,19.51,25.48,19.74,24.51,16.5")
bronto_run1=split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,35.97,18.56,34.61,19.31,30.51,16.5,27.51,16.5,24.89,19.51,23.48,19.74,24.51,16.5")
bronto_run2=split("24.51,16.5,20.51,16.5,26.51,10.5,30.51,10.5,34.51,4.5,38.51,4.5,38.51,7.5,36.51,7.5,33.51,11.5,31.97,19.56,29.61,19.31,30.51,16.5,27.51,16.5,27.89,19.51,25.48,19.74,24.51,16.5")

--28x30
--split("25.89,8.21,25.16,10.49,25.92,10.67,28.79,10.52,28.41,9.21,31.2,9.4,34.77,11.51,32.8,12.83,31.32,17.96,30.05,19.54,28.49,20.67,26.34,21.05,24.46,22.12,25.51,24.51,27.5,25.39,31.04,30.04,38.79,29.38,48.99,35.65,45.94,43.96,33.46,55.41,32.84,55.52,32.39,54.17,35.51,44.69,34.98,42.4,31.88,37.83,29.51,31.51,23.84,27.93,19.51,25.51,14.27,17.76,14.12,16.41,15.09,13.72,15.12,10.48,14.62,9.94,13.92,9.62,11.91,10.07,14.09,7.98,17.04,7.01,18.1,7.54,25.22,7.57,25.89,8.21")
earthconts=split("-2.3,-22.75,-3.06,-20.37,-2.26,-20.17,0.72,-20.33,0.33,-21.7,3.23,-21.5,6.95,-19.3,4.9,-17.93,3.36,-12.59,2.03,-10.94,0.41,-9.76,-1.83,-9.37,-3.79,-8.26,-2.69,-5.77,-0.62,-4.86,3.07,-0.01,11.13,-0.7,21.76,5.83,18.57,14.49,5.58,26.4,4.94,26.52,4.47,25.11,7.72,15.24,7.16,12.86,3.94,8.1,1.47,2.56,-4.44,-2.21,-8.94,-4.73,-14.4,-12.8,-14.56,-14.2,-13.54,-17,-13.51,-20.38,-14.03,-20.94,-14.76,-21.27,-16.85,-20.8,-14.58,-22.98,-11.51,-23.99,-10.41,-23.44,-3,-23.4,-2.3,-22.75")

trexidle=split("4.51,-13.52,0.51,-8.52,0.51,-4.52,-1.49,-3.52,-3.49,-1.52,-5.95,-1.58,-8.65,0.07,-2.49,1.48,-3.12,4.48,-1.66,4.48,1.02,2.3,1.67,4.48,4.51,4.48,3.48,0.05,4.51,-1.52,7.51,-3.52,3.51,-3.52,4.51,-8.52,6.25,-6.14,7.51,-8.52,11.51,-7.52,11.51,-11.52,4.51,-13.52")
trexrun1=split("5.51,-11.52,1.51,-6.52,0.51,-4.52,-1.49,-3.52,-3.49,-1.52,-5.95,-1.58,-9.49,-1.52,-2.49,1.48,-5.12,4.48,-3.66,4.48,1.02,2.3,4.67,4.48,7.51,4.48,3.48,0.05,4.51,-0.52,9.51,-1.52,3.51,-3.52,5.51,-6.52,7.25,-4.14,8.51,-6.52,12.51,-5.52,12.51,-9.52,5.51,-11.52")
trexrun2=split("5.51,-11.52,1.51,-6.52,0.51,-4.52,-1.49,-3.52,-3.49,-1.52,-5.95,-1.58,-9.49,-1.52,-2.49,1.48,-1.12,4.48,0.34,4.48,1.02,2.3,-0.33,4.48,2.51,4.48,3.48,0.05,4.51,-0.52,9.51,-1.52,3.51,-3.52,5.51,-6.52,7.25,-4.14,8.51,-6.52,12.51,-5.52,12.51,-9.52,5.51,-11.52")

treepts=split("3.62,-8.69,3.04,-10.49,12.04,-11.49,10.04,-15.49,3.04,-16.49,2.04,-14.49,0.56,-18.11,-1.87,-19.29,-9.1,-16.13,-9.48,-13.86,-7.96,-11.49,-5.96,-13.49,0.04,-11.49,-1.66,-9.52,-2.83,-5.74,-3.07,0.17,-0.96,5.51,4.04,4.4,2.78,-0.14,2.92,-5.38,3.62,-8.69")

roidspr1=split("-0.42,3.68,2.88,3.27,3.37,0.02,2.73,-2.77,-0.02,-2.77,-2.98,-3.36,-2.4,-0.33,-1.99,1.4,-0.42,3.68")
roidspr2=split("0.82,-3.25,-2.2,-2.21,-3.42,0.8,-1.36,2.98,0.82,4.09,2.99,2.97,3.6,0.8,2.66,-1.04,0.82,-3.25")

impactpts=translate(split("9.2,.81,12.47,4.96,17.7,5.71,15.74,10.62,17.7,15.53,12.47,16.29,9.2,20.44,5.93,16.29,.7,15.53,2.66,10.62,.7,5.71,5.93,4.96,9.2,.81"),8,10)

volcanopts=split("0.51,-5.58,3.95,-7.66,4.34,-4.68,5.81,-0.56,8.39,5.51,-6.37,5.51,-4.72,0.53,-4.49,-3.49,-3,-2.73,-2.58,-6.88,0.51,-5.58")

--bigonepts=split("-3.94,12.52,8.19,11,10,-0.93,7.61,-11.19,-2.5,-11.17,-13.37,-13.36,-11.22,-2.23,-9.72,4.15,-3.94,12.52")
--bigonepts=split("18.69,8.41,19.42,3.67,21.58,-1.29,16.31,-4.76,16.48,-10.04,14.44,-15.3,10.58,-20.11,4.71,-21.44,-0.46,-15.2,-6.84,-19.45,-8.73,-12.36,-14.23,-11.02,-19.36,-7.54,-16.22,-1.17,-16.37,3.54,-19.24,9.79,-17.33,15.67,-10.4,16.79,-5.89,19.19,-1.31,22.88,3.6,16.78,7.74,16.19,13.09,16.32,17.77,13.74,18.69,8.41")
--bigonepts=split("17.91,8.7,19.11,3.75,19.71,-1.4,17.31,-6.02,15.47,-10.76,12.24,-14.89,7.9,-18.11,2.64,-19.48,-2.57,-17.79,-7.98,-17.98,-11.79,-14.16,-15.99,-11.13,-19.3,-6.89,-19.45,-1.49,-19.5,3.59,-19.31,8.97,-16.91,13.87,-12.35,16.87,-7.83,19.43,-2.92,21.44,2.22,19.79,7.02,18.66,11.77,16.82,15.75,13.44,17.91,8.7")
bigonepts=split("18.92,8.7,20.12,3.75,20.72,-1.4,18.32,-6.02,16.48,-10.76,13.25,-14.89,8.92,-18.11,3.65,-19.48,-1.56,-17.79,-6.97,-17.98,-10.78,-14.16,-14.98,-11.13,-18.29,-6.89,-18.43,-1.49,-19.49,2.59,-18.3,8.97,-15.9,13.87,-11.33,16.87,-6.82,19.43,-1.91,21.44,3.23,19.79,8.03,18.66,12.79,16.82,16.76,13.44,18.92,8.7")

--pteropts1=split("-12.5,2.5,-4.19,-2.28,0.9,-0.48,2.5,-1.5,1.5,-4.5,4.5,-3.5,6.5,-1.5,9.5,0.5,4.5,0.5,2.89,1.66,0.5,1.5,4.5,4.5,2.5,4.5,-0.99,9.36,-3.45,4.97,-2.6,3.03,-4.63,0.75,-5.5,1.5,-7.54,1.14,-12.5,2.5")
--pteropts2=split("-12.5,6.5,-4.19,1.72,-3.5,-4.5,0.9,3.52,2.5,2.5,1.5,-0.5,4.5,0.5,6.5,2.5,9.5,4.5,4.5,4.5,2.89,5.66,0.5,5.5,-2.6,7.03,-4.63,4.75,-5.5,5.5,-7.54,5.14,-12.5,6.5")
pteropts1=split("-9.49,2.5,-1.18,-2.28,-0.49,-8.5,3.91,-0.48,5.51,-1.5,4.51,-4.5,7.51,-3.5,9.51,-1.5,12.51,0.5,7.51,0.5,5.9,1.66,3.51,1.5,0.41,3.03,-1.62,0.75,-2.49,1.5,-4.53,1.14,-9.49,2.5")
pteropts2=split("-10.49,1.5,-2.18,-3.28,2.91,-1.48,4.51,-2.5,3.51,-5.5,6.51,-4.5,8.51,-2.5,11.51,-0.5,6.51,-0.5,4.9,0.66,2.51,0.5,6.51,3.5,4.51,3.5,1.02,8.36,-1.44,3.97,-0.59,2.03,-2.62,-0.25,-3.49,0.5,-5.53,0.14,-10.49,1.5")

--eggpts=split("1.49,-4.05,1.37,-4.16,1.24,-4.25,1.11,-4.33,0.98,-4.39,0.86,-4.44,0.74,-4.47,0.62,-4.49,0.51,-4.5,0.4,-4.49,0.28,-4.47,0.16,-4.44,0.04,-4.39,-0.09,-4.33,-0.22,-4.25,-0.35,-4.16,-0.47,-4.05,-0.95,-3.37,-1.55,-2.19,-2.13,-0.68,-2.54,0.97,-2.63,2.57,-2.25,3.94,-1.25,4.9,0.51,5.26,2.27,4.9,3.27,3.94,3.65,2.57,3.56,0.97,3.15,-0.68,2.57,-2.19,1.97,-3.37,1.49,-4.05,1.49,-4.05")
eggpts=split("1.51,2.5,2.51,1.5,2.51,-1.5,0.51,-3.5,-1.49,-1.5,-1.49,1.5,-0.49,2.5,1.51,2.5")

crownpts=split("-4,-4,-2,-2,0,-4,2,-2,4,-4,4,2,-4,2,-4,-4")
__gfx__
00000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070070007000a0a0a00090909000a0a0a0a0000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000
0007700070007000a0a0a00090909000aa0a0aa00000000a000000000000000a0a00000000000000000000000000000000000000000000000000000000000000
0007700070007000a0a0a00090909000a00000a0000a0aa0aa0a000000000aa000aa000000000000000000000000000000000000000000000000000000000000
0070070007770000aaaaa00099999000a00000a000a0a00a00a0a0000000a00a0a00a00000000000000000000000000000000000000000000000000000000000
0000000000000000aaaaa00099999000a00000a0000a0000000a0000000a0000a0000a0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaaaaaa00000a00000a0000000a00000000000a000000000000000000000000000000000000000000000000000000000
06000000000000000000000000000000000000000000a00000a000000a00aaaaaaaa000a00000000000000000000000000000000000000000000000000000000
66600000a000a000a0000000000000000000000000000aaaaa0000000a0a00000000a00a00000000000000000000000000000000000000000000000000000000
00000000aa0a0a0aa0000000000000000000000000000000000000000aa0a0000000000000000000000000000000000000000000000000000000000000000000
00000000a0a000a0a0000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000000000000000000000000000000
00000000a0000000a0000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000
00000000a0000000a0000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaaa00000000000000000000000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000500000000000005550500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050005000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000050000000000500000500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000555005000000500000500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005000500000000500000500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000050000050000000050005000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000050500050000000005550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000500p00000000000000000050000050000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000p0p0000000000000000005000500000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000p00p0000000000000000000555000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000p50000ppppp00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000pp0000000000p00000000000000000000000000000000000000007000000000000000000000000
00000000000000000000000000000000000000000000000000p00000000000p00000000000000000000000000000000000000770700000000000000000000000
000000000000000000000000000000000000000000000000000p0000o00111111111110000000000000000077777000000077000700000000000000000000000
000000000000000000000000000000000000000000000000000p0001111000000000001111000000007777700000700007700070070000000000000000000000
000000000000000000000000000000000000000000000000000p0110000000000000000000110000000770000000070770007707700000000000000000000000
00000000000000000000000000000000000000000000000000011000000000000000000000001100000007000000007000070007000000000000000000000000
00000000000000000000000000000000000000000000000001100000000000000000000000000011000007000000000000700000000000000000000000000000
00000000000000000000000000000000000000000000000010000000000000000000000000000000100070007000000077000000000000000000000000000000
000000000000000000000000000000000000000000000011000000000000000000000000000jj000011070770700000700000000000000000000000000000000
0000000000000000000000000000000000000000000001000000000000000000000000000000jjj0000107000070007000000000000000000000000000000000
0000000000000000000000000000000000000000000010000000000000000000000000000000j00j000010000700770000000000000000000000000000000000
000000000000000000000000000000000000000000010000000000000000000000000000000jj000j00001000707000000000000000000000000000000000000
0000000000000000000000000000000000000000001000000000000000000000000000jjjjj00000j00000107070000000000000000000000000000000000000
000000000000000000000000000000000000000001000000000000000000000000000j000000000j000000010700000000000000000000000000000000000000
00000000000000000000000000000000000000000100000000000000000000000000j00000000000j00000010000000000000000000000000000000000000000
0000000000000000000000000000000000000000100000000000000000000000000j000000000000j00000001000000000000000000000000000000000000000
000000000000000000000000000000000000000100000000000000000000000000j00000000000000j0000000100000000000000000000000000000000000000
000000000000000000000000000000000000000100000000000000000000000000j00000000000000j0000000100000000000000000000000000000000000000
00000000000000000000000000000000000000100000000000000000000000000j0000000000000000j000000010000000000000000000000000000000000000
0000000000000000000000000000000000000010000000000000000000000000j00000000000000000j000000010000000000000000000000000000000000000
000000000000000000000000000000000000010000000000000000000000000j000000000000000jjjj000000001000000000000000000000000000000000000
000000000000000000000000000000000000010000000000000000000000000j000000000000000j000000000001000000000000000000000000000000000000
000000000000000000000000000000000000100000000000000000000000000j0000000000000000j00000000000100000000000000000000000000000000000
000000000000000000000000000000000000100000000000000000000000000j0000000000000000j0j000000000100000000000000000000000000000000000
000000000000000000000000000000000000100000000000000000000000000j0000j000000000000j0j00000000100000000000000000000000000000000000
000000000000000000000000000000000000100000000000000000000000000j000j0jj000000000000j00000000100000000000000000000000000000000000
000000000000000000000000000000000001000000000000000000000000000j00j0000j00000000000j00000000010000000000000000000000000000000000
00000000000000000000000000000000000100000000000000000000000000j000j0000j00000000000j00000000010000000000000000000000000000000000
00000000000000000000000000000000000100000000000000000000000000j000j00000jj0000jjj0j000000000010000000000000000000000000000000000
00000000000000000000000000000000000100000000000000000000000000j00j00000000jjjj000jj0000000000100000000000000qq000000000000000000
00000000000000000000000000000000000100000000000000000000000000j00j000000000000000000000000000100000000000000q0qqq000000000000000
0000000000000000000000000000000000010000000000000000000000000j00j00000000000000000000000000001000000000000000q00q000000000000000
0000000000000000000000000000000000010000000000000000000000000j00j00000000000000000000000000001000000q000q0000q00q000000000000000
000000000000000000000000000000000001000000000000000000000000j00j0000000000000000000000000000010q0000q00qq000qq00q000000000000000
0000000000000000000000000000000000010000000000000000000000jj0000j00000000000000000000000000001pqqq0q0qq0q0qq00000q00000000000000
000000000000000000000000000000000001000000000000000000000j000000j000000000000000000000000000010q00qq0q0q000q00000q00000000000000
00000000000000000000000000000000000100000000000000000000j00000000j00000000000000000000000000010q0000000qqqqqq0000q00000000000000
0000000000000000000000000000000000001000000000000000000j000000000j000000000000000000000000001000qq000000000000000q00000000000000
0000000000000000000000000000000000001000000000000000000j0000000000j0000000000000000000000000100qq00000000000000qq000000000000000
000000000000000000000000000000000000100000000000000000j00000000000j000000000000000000000000010q00000000qq0qqqqq00000000000000000
000000000000000000000000000000000000100000000000000000j000000000000j0000000000000000000000001kq00000000q0qqqq0qq0000000000000000
00000000000000000000000000000000000001000000000000000j0000000000000j00000000000000000000000100qqqq000qq0000q000q0000000000000000
0000000000000000000000000000000000000100000000jjjjjjj00000000000000j00000000000000000000000100000qkqq000000q000q0000000000000000
00000000000000000000000000000000000000100jjjjj000000000000000000000j00000000000000000000001000000q0qk00000q0000q0000000000000000
0000000000000000000000000000000000000010jj000000000000000000000000j000000000000000000000001000000q0q0kk000q0000q0000000000000000
000000000000000000000000000000000000000100jj0000000000000000000000j00000000000000000000001kkk0000q0q000k0q00000q0000000000000000
00000000000000000000000000000000000000010000jj00000000000000000000j00000000000000000000001000kk00qq00000q000000q0000000000000000
0000000000000000000000000000000000000000100000jj000000000000000000j0000000000000000000001000000kkq00000qk000000q0000000000000000
000000000000000000000000000000000000000001000000jj0000000000000000j000000000000000000001000000000kk0000q0000000q0000000000000000
00000000000000000000000000000000000000000100000000jj00000000000000j00000000000000000000100000000000kk0q0000000q00000000000000000
0000000000000000000000000000000000000000001000000000jj00000000000j00000000000000000000100000000000000q000qqqqq000000000000000000
000000000000000000000000000000000000000000010000000000jj000000000j0000000000000000000100000000000000q00000q000000000000000000000
00000000000000000000000000000000000000000000100000000000jjjjjjjjjj0000000000000000001000000000000000q00000q000000000000000000000
000000000000000000000000000000000000000000000100000000000000000000000000000000000001000000000000000q00000q0000000000000000000000
00000000000000000000000000000000000000000000001100000000000000000000000000000000011000000000000000q000000q0000000000000000000000
0000000000000000000000000000000000000000000000001000000000000000000000000000000010000000000000000q000000q00000000000000000000000
0000000000000000000000000000000000000000000000000110000000000000000000000000001100000000000000000q000000q00000000000000000000000
000000000000000000000000000000000000000000000000000110000000000000000000000011000000000000000000qqqqqqqq000000000000000000000000
00000000000000000000000000000000000000000000000000000110000000000000000000110000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001111000000000001111000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000111111111110000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000550000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000505000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700770077077707770000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007000707070707000070000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707000707077007700000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00707000707070707000070000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000770770070707770000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

