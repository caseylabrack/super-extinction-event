pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--super extinction event
--casey labrack

--todo:
	--select rex mode from main
	--scoring	
		
--😐
	--graph of score?
	--score screen also show deaths
	--main screen:
		--dinosaur name,eating type
			--oviraptor: ovivore
			--bronto: herbivore
			--lizard: scavenger
			--spinosaurus: piscovore
		--scoring style (fibonacci, total)
		--animation of eating
	--gamemode: pterodactyl hunts you
		--keep earth between you breaking
		--line of sight
		--mammal?
	--mammal(? lizard?) mode:
		--ptero drops eggs which roll
		--eccentricly around and stop
		--you pick them up but ptero
		--dives at you if it has los
	--egg crack game mode
	--2p is palm tree and egg goals
		--at the same time
	--stego mode: push a boulder
		--into a tarpit
	--warp vertices of earth or player
		--based on impacts?
		--like squash and stretch?
	--mult is # in a row?
	--score increase in fibbonacci
	 --sequence in streak
	 --resets to 1 on death
	--score threshold to unlock
		--extra hard mode variant
		--(like meat boy hell world)
		--rex mode. and hyperex mode
		--crown appears on dino
		--roids lethal only in rex mode?
	--chipper sound on score needed
	--turn into a hypercube on win?
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
	--multiplier color coded
		--maybe only color?
	--can jump (volcano)
	--time scale?
	--slow time?
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
 --bronto stands to eat animation?
	--"super extinction challenge"?
	--'nautilus' is pretty nice for this

log=""

defaultchallenge=1
--challenges:
--1: brontosaurus
--2: oviraptor
--3: spinosaurus

rexgoals={350,100,20,}

--debug
sar=.05 --spino angle range
sdr=38  --spino distance range

function _init()

	cartdata("caseylabrack_superdino")
	
--	pal({[0]=0,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143},1)
	
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
	
	bronto,raptor,spino=1,2,3
	stage=0
	stara=0
	trexs={}
	trees={}
	vs={} -- volcanos
	ss={} -- explosions
	rs={} -- roids
	fs={} -- fishes
	fs⧗=0 -- fish timer
	parts={} -- particles
	--big one
	bo={x=-64,y=-64,r=0,c=6,enabled=true,
	fr=1,frames={bigonepts}}
	eggs={}
	ebirds={} --egg birds
	isrex=false
	scores={}
	
	--player
	p={x=64,y=29,r=0,state="idle",enabled=true,dx=0,dy=0,
		--angle, delta angle, mag, delta mag, grounded
	 a=.25,da=0,m=30,dm=0,
		--target mag, grounded
	 tm=30,gr=true,
		--speed, facing direction,
	 s=.004,d=1,c=15,
	 --last position
	 lpx,lpy=0,0,
	 --frame index, all frames
	 fr=1,frames={bronto_idle,bronto_run1,bronto_run2,}
	}
	
	pdead={x=0,y=-p.tm,r=0,c=p.c,⧗=0,enabled=false,fr=1,frames={}}
	
	e={x=0,y=0,a=0,r=0,s=.01,d=1,c=130,
		enabled=true,
		fr=1,frames={earthconts}}

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
--		isrex=true
--		cr.enabled=true
--		lethalroids=true
	end

	if contains({1},chal) then
		spawntrex()
		spawntree()	
	end
		
	if contains({2},chal) then
		spawnvolcano()
		spawnptero()
	end
	
	if contains({3},chal) then
--		p.frames={spino_idle,spino_lookup,spino_catch}
		p.frames={spino_idle,spino_catch,spino_walkin_down,spino_walkin_up,spino_walkout_down,spino_walkout_up,}
		p.dino="spino"
		p.cf={} --caught fish
		p.jaw=new_ent()
		addchild(p,p.jaw)
		p.jaw.x,p.jaw.y=0,-12
--		lethalroids=true

--		for i=1,10 do
--	 	local f=new_ent()
--	 	f.x,f.y,f.r,f.frames,f.scale=
--	 	p.x,p.y,rnd(),{fish_idle},.5
--			f.c=3
--			addchild(p.jaw,f)
--			f.x=4+8*rnd()
--			f.y=rnd()*3
--	 	add(p.cf,f)		
--		end
	end
	
--	g⧗=1
--	scores={5,10,17,8,10,19,4,2,6}
--	scores={5,17,19,4}

	music(0)
end

function _update()

	local note=stat"50"
	local patt=stat"54"
	--total game time (0..1)
	g⧗=(patt*32+note)/(13*32-16)
	--big one shake time when <0
	bo⧗=(12*32)-(patt*32+note)

	⧗+=1
	e.x,e.y=0,0

	stara+=.001

	if p.enabled then	mult+=1 end

	lmult2=mult2
	zpct=mid(.1,mid(1,mult,1000)/1000,1)
	zpct=zpct*zpct
--	zpct=mid(1,mult,1000)/1000
--	zpct=easeoutcubic(zpct)
	mult2=ceil(20*zpct)
			
	--big one approaches
	local pct=1-g⧗/1
	local impact=0--49
	local startdist=78
	local travel=startdist-impact
	local d=travel*pct+impact
	bo.x=cos(.375)*d
	bo.y=sin(.375)*d

	--dramatic shaking right before impact
	if bo⧗<0 then
		local pct=abs(bo⧗)/16
		local pct=pct*pct*pct
		local mx=12*pct
		local a=rnd()
		bo.x+=cos(a)*mx
		bo.y+=sin(a)*mx
	end	
	
	--gameover handle
	if g⧗==1 and not gameover then
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
		if chal==spino then score=#p.cf end

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

--	function fish()
		
	--spawn fish
	if chal==spino then fs⧗+=1 end
	if fs⧗>30 then
		fs⧗=-30+rnd()*-100
		spawnfish()
	end
	
	for fish in all(fs) do
		local a=atan2(fish.x,fish.y)
		fish.⧗+=1
		if fish.from=="spino" then
			if ⧗%6<2 then
				fish.enabled=false
			else
				fish.enabled=true
			end
		end

		if fish.state=="swim" then
			local d=fish.m
			fish.ph+=1
			--bobbing in the water
			d+=sin(fish.ph/25-.25)*6
			fish.da=fish.s*fish.d
			a+=fish.da
			
			fish.x=cos(a)*d fish.y=sin(a)*d
			fish.r=a+.25
			
			local pct=mid(fish.⧗/45,0,1)
			fish.scale=pct
			
			--ready to jump
			--wait for upward phase
			if fish.⧗>120 then
				if fish.ph%25==0 then
					fish.x,fish.y=gpos(fish)
					fish.parent=nil
					fish.state="jump"
					fish.⧗=0
					fish.dm=2
					fish.dr=rnd()*.1-.05
					fish.da=fish.d*rnd(.005)
				end
			end
		end
		if fish.state=="jump" then
			if fish.⧗>30 then fish.cable=true	end
			local a=atan2(fish.x,fish.y)
			local df=fish.from=="spino" and .5 or 1 --death factor
			
			fish.dm-=.075*df
			fish.m+=fish.dm*df
			a+=fish.da*df
			
--			fish.x=cos(a+fish.da)*fish.m
			fish.x=cos(a)*fish.m
--			fish.y=sin(a+fish.da)*fish.m
			fish.y=sin(a)*fish.m
			fish.r+=fish.dr
			if distot(fish)<30 then
--				fish.state="missed"
				del(fs,fish)
				for i=1,12 do
					local fp={}
					local a2=rnd()
					fp.x,fp.y=fish.x+cos(a2)*5,fish.y+sin(a2)*5
					local s=rndr(-.1,.1)
					addchild(e,fp)
					local a=atan2(fp.x,fp.y)
					fp.dx,fp.dy=cos(a+s)*3,sin(a+s)*3
					fp.type="point"
					fp.⧗=8 fp.c=12
--					fp.parent=e
					fp.f=.99
					fp.g=.75

					--fp.f=0
					add(parts,fp)				
				end
			end
		end
	end
	
	
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
	
	--function roids
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
			del(rs,roid)
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
				
				if abs(diff)<.05 then
					for fish in all(p.cf) do
						local f=new_ent()
						f.x,f.y=gpos(p.jaw)
						f.dx=cos(pa+.5)*5
						f.dy=sin(pa+.5)*5
						f.⧗=0
						f.from="spino"
						f.state="jump"
						f.dm=1.5+rnd()
						f.dr=rnd()*.1-.05
						f.da=rnd(.0025)*sgn(diff)
						f.m=distot(p)
						f.frames={fish_idle}
						f.c=3
						add(fs,f)
						del(p.cf,fish)
--						stop()
					end				
				end
				
				
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

	--	function player() end	
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

		if p.dino=="spino" then
			p.d=1
			--run state 2bit bitfield
			--0b01 running or still
			--0b10 mouth open or closed
			local rst=0
			
			if p.state=="run" then rst+=0b01 end
--			pa=atan2(p.x,p.y)
			pa=atan2(gpos(p))
			for fish in all(fs) do	
				if fish.state=="jump" then
--					fa=atan2(fish.x,fish.y)
--					local fposx,fposy=gpos(fish)
					fa=atan2(fish.x,fish.y)
					diff=sad(pa,fa)
					if abs(diff)<.25 then rst+=0b10 break end
				end
			end
			--run cycle frame
			local rframe=0
			if p.da>0 then 
				if ⧗%8<4 then
					rframe=0
				else 
					rframe=2
				end
			else 
				if ⧗%4<2 then
					rframe=0
				else 
					rframe=2
				end
			end
			--closed,still
			if rst==0 then p.fr=1 p.jaw.r=0 end
			--closed,run
			if rst==1 then p.fr=3+rframe	p.jaw.r=0 end
			--open,still 
			if rst==2 then p.fr=2 p.jaw.r=.15 end
			--open,run
			if rst==3 then p.fr=4+rframe p.jaw.r=.15 end			

			--catch fish
			for fish in all(fs) do
				local fa=atan2(gpos(fish))
				local pa=atan2(gpos(p))
				if fish.state=="jump" and
					fish.cable and
					distot(fish)<sdr and
				 abs(sad(fa,pa))<sar then
				 	del(fs,fish)
				 	local f=new_ent()
				 	f.x,f.y,f.r,f.frames,f.scale=
 				 	p.x,p.y,rnd(),{fish_idle},.5
						f.c=3
						addchild(p.jaw,f)
						f.x=4+8*rnd()
						f.y=0+rnd()*3
				 	add(p.cf,f)
				 	
				 	for particle in all(parts) do
				 		if particle.id=="fish" then
				 			del(parts,particle)
							end
						end
				 	
				 	--score popup
						tp={}
						tp.x,tp.y=gpos(fish)
						tp.⧗=30 tp.c=10
						local a=atan2(tp.x,tp.y)
--						tp.x+=cos(a)*
--						tp.y+=sin(a)*10
						tp.dx,tp.dy=cos(a)*2,sin(a)*2
						tp.f=.8
						tp.type="text"
						tp.id="fish"
						tp.label=""..#p.cf
						add(parts,tp)
     end								
			end			
		end--end spino
				
		--rising and falling
		if not p.gr then
			p.dm-=1 --gravity
			p.m+=p.dm
			if p.m<p.tm then
				p.gr=true
				p.m=p.tm
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
				p.x,p.y,p.da=0,-p.tm,0
				p.dx,p.dy,p.dm,p.gr=0,0,0,true
				p.m=p.tm
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

	
	--earth surface,fill
	if not gameover then
		circfill(e.x,e.y,29,0)	
		circ(e.x,e.y,29,e.c)
--		circ(e.x,e.y,29,12)
	end
	--	circ(0,0,3,11)--ctr ref
		
	--spino fish
	for f in all(p.cf) do
		render_ent(f)
	end

-- debug spino range
--	circ(0,0,sdr,10)
--
--	local pa=atan2(gpos(p))
--	line(0,0,cos(pa+sar)*38,sin(pa+sar)*38,10)
--	line(0,0,cos(pa-sar)*38,sin(pa-sar)*38,10)
		
	for fish in all(fs) do
		render_ent(fish)
	end
		
	for roid in all(rs) do
		render_ent(roid)
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
--	print("X",0,113,7)
	color(7)
	if lmult2~=mult2 then
		color(9)
	end
	if mult2==20 then
		if ⧗%4==0 then color(9) end
	end

--	print(" "..mult2,0,113)
--	print(" "..score,0,120,7)
	pal(split("129,130,14,132,133,134,135,136,137,138,139,140,141,142,143,0"),1)
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

--function gpos(e)
--	local p=e.parent
--	if p then
--		local a=atan2(e.x,e.y)+p.r
--		local d=disto(e.x,e.y)
--		return p.x+cos(a)*d,p.y+sin(a)*d
--	end
--	return e.x,e.y
--end
--function gpos(e)
--	local p=e.parent
--	local x,y,r=e.x,e.y,e.r
--	while p~=nil do
--		local a=atan2(p.x,p.y)
--		local d=disto(p.x,p.y)
--		x=p.x+cos(a)*d
--		y=p.y+sin(a)*d
--		r=p.r+r
--		p=p.parent
--	end
--	return x,y
--end
function gpos(e)
	local x,y=gposr(e)
	return x,y
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

function spawnfish()
	local f={x=0,y=0,c=3,s=.0075,
		m=30,dm=0,da=0,
		enabled=true,d=1,scale=.1,
		⧗=0,state="swim",
		--phase (bobbing),catchable
		ph=0,cable=false,
		fr=1,frames={fish_idle}}
	
	local a=rnd()
	f.x=cos(a)*24
	f.y=sin(a)*24
	f.r=a+.5
	f.parent=e
	f.d=rnd()>.5 and -1 or 1
	add(fs,f)
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

--new valid entity with defaults
function new_ent()
	local e={}
	e.x,e.y,e.r,e.d,e.fr,e.enabled=
	0,0,0,1,1,true
	e.dx,e.dy,e.dr=
	0,0,0
	return e
end
-->8
--sprites
bronto_idle=split("-4.3165,-4.0968,-8.3866,-3.0792,-2.2815,-10.2019,1.7886,-10.2019,3.8236,-20.377,7.8937,-20.377,7.8937,-17.3245,5.8587,-17.3245,4.8412,-9.1843,4.3324,-1.0442,2.8061,-1.2986,1.7886,-4.0968,-1.2639,-4.0968,-1.7727,-1.0442,-3.299,-0.7898")
bronto_run1=split("-4.3385,-3.7286,-8.6183,-3.7286,-2.1985,-10.1484,2.0814,-10.1484,6.3612,-16.5683,10.6411,-16.5683,10.6411,-13.3584,8.5012,-13.3584,5.2913,-9.0785,7.9662,-1.5887,6.3612,-0.7862,2.0814,-3.7286,-1.1285,-3.7286,-3.8035,-0.5187,-5.4084,-0.2512")
bronto_run2=split("-4.377,-3.6942,-8.698,-3.6942,-2.2166,-10.1757,2.1044,-10.1757,6.4254,-16.6572,10.7464,-16.6572,10.7464,-13.4164,8.5859,-13.4164,5.3452,-9.0955,3.7248,-0.4535,1.0242,-0.7236,2.1044,-3.6942,-1.1363,-3.6942,-0.5962,-0.4535,-3.2968,-0.1834")

spino_idle=split("10.2588,-12.4154,1.2287,-12.2932,-1.2379,-11.8621,-1.6886,-6.5319,-5.0059,-10.968,-7.9749,-11.0008,-8.2998,-8.1142,-10.767,-7.949,-8.9469,-3.9229,-13.9308,1.8989,-8.41,-1.9838,-6.0712,-0.0103,-5.5888,-3.0054,-2.0063,-3.2898,1.1567,-0.311,1.5067,-3.6278,0.9369,-6.6742,1.1741,-9.4058,11.4112,-11.1017")
spino_catch=split("-0.5308,-19.0072,-2.2412,-10.545,-1.676,-6.5319,-4.9932,-10.968,-7.9623,-11.0008,-8.2872,-8.1142,-10.7543,-7.949,-9.1527,-3.9229,-13.9182,1.8989,-8.3974,-1.9838,-6.0586,-0.0103,-5.5762,-3.0054,-1.9936,-3.2898,1.1693,-0.311,1.5193,-3.6278,0.9495,-6.6742,2.4222,-9.4058,3.7671,-18.8268,0.3436,-11.4471")
spino_walkin_down=split("10.2588,-12.4154,1.2287,-12.2932,-1.2379,-11.8621,-1.6886,-6.5319,-5.0059,-10.968,-7.9749,-11.0008,-8.2998,-8.1142,-10.767,-7.949,-8.9469,-3.9229,-13.9308,1.8989,-8.41,-1.9838,-4.218,-0.2419,-5.5888,-3.0054,-2.0063,-3.2898,-2.0092,-0.4655,1.5067,-3.6278,0.9369,-6.6742,1.1741,-9.4058,11.4112,-11.1017")
spino_walkin_up=split("-0.5308,-19.0072,-2.2412,-10.545,-1.676,-6.5319,-4.9932,-10.968,-7.9623,-11.0008,-8.2872,-8.1142,-10.7543,-7.949,-9.1527,-3.9229,-13.9182,1.8989,-8.3974,-1.9838,-4.2054,-0.2419,-5.5762,-3.0054,-1.9936,-3.2898,-1.9966,-0.4655,1.5193,-3.6278,0.9495,-6.6742,2.4222,-9.4058,3.7671,-18.8268,0.3436,-11.4471")
spino_walkout_down=split("10.2588,-12.4154,1.2287,-12.2932,-1.2379,-11.8621,-1.6886,-6.5319,-5.0059,-10.968,-7.9749,-11.0008,-8.2998,-8.1142,-10.767,-7.949,-8.9469,-3.9229,-13.9308,1.8989,-8.41,-1.9838,-7.77,0.2986,-5.5888,-3.0054,-2.0063,-3.2898,3.0871,-0.3882,1.5067,-3.6278,0.9369,-6.6742,1.1741,-9.4058,11.4112,-11.1017")
spino_walkout_up=split("-0.5308,-19.0072,-2.2412,-10.545,-1.676,-6.5319,-4.9932,-10.968,-7.9623,-11.0008,-8.2872,-8.1142,-10.7543,-7.949,-9.1527,-3.9229,-13.9182,1.8989,-8.3974,-1.9838,-7.7574,0.2986,-5.5762,-3.0054,-1.9936,-3.2898,3.0998,-0.3882,1.5193,-3.6278,0.9495,-6.6742,2.4222,-9.4058,3.7671,-18.8268,0.3436,-11.4471")


fish_idle=split("2.966,0.3563,0.3131,-1.9715,-2.4948,-0.1495,-4.4568,-1.4231,-3.639,2.1466,-2.3091,0.9423,0.0767,2.289")

--28x30
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
-->8
--painto-8 lite
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
0000000000000000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000mmm0m0m0mmm0000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000m00m0m0m000000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000m00mmm0mm00000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000m00m0m0m0000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000m00m0m0mmm00000000000000m0000000000000000000000000000000000000qq000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000m0000000000000000000000000000000000qq00q00000000000000000000000000000000000000000000000000000000
000000mmm0mmm00mm000000000000000m00000000000000000000000000000000000q000qqq00000000000000000000000000000000000000000000000000000
000000m0m00m00m000000000000000000m0000000000000000000000000000000000q00qq0q00000000000000000000000000000000000000000000000000000
000000mm000m00m000000000000000000m00000000000000000000000000000000000qq00qq00000000000000000000000000000000000000000000000000000
000000m0m00m00m0m0000000000000000m0000000000000000000000000000000000000000q00000000000000000000000000000000000000000000000000000
000000mmm0mmm0mmm000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000mm0mm00mmm000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000m0m0m0m0m00000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000m0m0m0m0mm0000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000m0m0m0m0m0000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000mm00m0m0mmm00000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000m000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000m0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
m0000000000000000000000000m00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0m0000000000000000000000mm000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00mm000000000000000000mm00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000mmm00000000000mmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000mm0000mmmmm00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000mmmm0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000iiiiiiiiiii0000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000iiii00000000000iiii000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000ii0000000000000000000ii0000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000ii00000000000000000000000ii00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000ii000000000000000000000000000ii000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000i0000000000000000000000000000000i00000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000ii000000000000000000000000000000000ii000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000i0000000000000000000000000000000000000i00000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000i000000000000000000000000000000000000000i0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000i00000000000000000000000000000000000000000i000000000000000000000000000000000000000000
000000000000000000000000000000000000000000i0000000000000000000000000000000000000000000i00000000000000000000000000000000000000000
00000000000000000000000000000000000000000i000000000000000000000000000000000000000000000i0000000000000000000000000000000000000000
00000000000000000000000000000000000000000i000000000000000000000000000000000000000000000i0000000000000000000000000000000000000000
0000000000000000000000000000000000000000i00000000000000000000000000000000000000000000000i000000000000000000000000000000000000000
000000000000000000000000000000000000000i0000000000000000000000000000000000000000000000000i00000000000000000000000000000000000000
000000000000000000000000000000000000000i0000000000000000000000000000000000000000000000000i00000000000000000000000000000000000000
00000000000000000000000000000000000000i000000000000000000000000000000000000000000000000000i0000000000000000000000000000000000000
00000000000000000000000000000000000000i000000000000000000000000000000000000000000000000000i0000000000000000000000000000000000000
0000000000000000000000000000000000000i0i000000000000000000000000000000000000000000000000000i000000000000000000000000000000000000
0000000000000000000000000000000000000ii0i00000000000000000000000000000000000000000000000000i000000000000000000000000000000000000
000000000000000000000000000000000000i0i00i00000000000000000000000000000000000000000000000000i00000000000000000000000000000000000
000000000000000000000000000000000000i0i000i0000000000000000000000000000000000000000000000000i00000000000000000000000000000000000
000000000000000000000000000000000000i00i000i000000000000000000000000000000000000000000000000i00000000000000000000000000000000000
000000000000000000000000000000000000i00i0000i00000000000000000000000000000000iiiiii000000000i00000000000000000000000000000000000
00000000000000000000000000000000000i000i0000i000000000000000000000000000iiiii000000i000000000i0000000000000000000000000000000000
00000000000000000000000000000000000i000i00000i000000000000000000000000ii000000000000i00000000i0000000000000000000000000000000000
00000000000000000000000000000000000i000i000000i00000000000000000000iii000000000000000i0000i00i0000000000000000000000000000000000
00000000000000000000000000000000000i000i0000000i0000iiiiiii0000iiii0000000000000000000ii00i00i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i0000000iiii0000000iiii0000000000000000000000000ii0i0i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i00000000000000000000000000000i00000000000000000000i0i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i0000000000000000000000000000i0ii000000000000000000i0i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i000000000000000000000iiiiiii000i00000000000000000i00i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i00000000000000000000i0000000000i00000000000000000i00i0000000000000000000000000000000000
00000000000000000000000000000000000i0000i00000000000000000000i0000000000i0000000000000000i000i0000000000000000000000000000000000
00000000000000000000000000000000000i00000i000000000000000000i0000000000i0000000000000000i0000i0000000000000000000000000000000000
000000000000000000000000000000000000i0000i000000000000000000i00000000000i000000000000000i000i00000000000000000000000000000000000
000000000000000000000000000000000000i0000i00000000000000000i000000000000i00000000000000i000vi00000000000000000000000000000000000
000000000000000000000000000000000000i00000i0000000000000000i000000000000i000000000i000i0000vi00000000000000000000000000000000000
000000000000000000000000000000000000i000000i00000000000000i0000000000000i000000000ii00i0000vv00000000000000000000000000000000000
0000000000000000000000000000000000000i00000i000000000000ii000000000000000i0000000i00ii0vv0viv00000000000000000000000000000000000
0000000000000000000000000000000000000i000000i000000000ii000000000000000000i00000i000000v0vviv00000000000000000000000000000000000
00000000000000000000000000000000000000i000000i000000ii000000000000000000000i00000ii000v000i00v0000000000000000000000000000000000
00000000000000000000000000000000000000i0000000i000ii000000000000000000000000i0000i00000v00i00v0000000000000000000000000000000000
000000000000000000000000000000000000000i000000i0ii00000000000000000000000000i000i0000000vi000v0000000000000000000000000000000000
000000000000000000000000000000000000000i0000000i0000000000000000000000000000i0ii00000000vi0000v000000000000000000000000000000000
0000000000000000000000000000000000000000i00000000000000000000000000000000000ii000000vv0vi00000v000000000000000000000000000000000
00000000000000000000000000000000000000000i00000000000000000000000000000000000000000v00vv000000v000000000000000000000000000000000
00000000000000000000000000000000000000000i000000000000000000000000000000000000000000v00i00000v0000000000000000000000000000000000
000000000000000000000000000000000000000000i000000000000000000000000000000000000000000vv000000v0000000000000000000000000000000000
0000000000000000000000000000000000000000000i00000000000000000000000000000000000000000i0v0000v00000000000000000000000000000000000
00000000000000000000000000000000000000000000i000000000000000000000000000000000000000i000v0000v0000000000000000000000000000000000
000000000000000000000000000000000000000000000i0000000000000000000000000000000000000i00000v0000v000000000000000000000000000000000
0000000000000000000000000000000000000000000000ii000000000000000000000000000000000ii0000000v0000v00000000000000000000000000000000
000000000000000000000000000000000000000000000000i0000000000000000000000000000000i0000000000vv000v0000000000000000000000000000000
0000000000000000000000000000000000000000000000000ii000000000000000000000000000ii0000000000000v000v000000000000000000000000000000
000000000000000000000000000000000000000000000000000ii00000000000000000000000ii0000000000000000v000v00000000000000000000000000000
00000000000000000000000000000000000000000000000000000ii0000000000000000000ii0000000000000000000v000v0000000000000000000000000000
0000000000000000000000000000000000000000000000000000000iiii00000000000iiii000000000000000000000v000v0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000iiiiiiiiiii000000000000000000000000v000v00000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000vv0v00000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000nnn0000000000000000000000000000000000000000q00000000000000000000000000000000000000000000000000000000000000000000000000000000
n0n000n000000000000000000000000000000000000000q0q0000000000000000000000000000000000000000000000000000000000000000000000000000000
0n00nnn000000000000000000000000000000000000000q0q0000000000000000000000000000000000000000000000000000000000000000000000000000000
0n00n0000000000000000000000000000000000000000qqq00000000000000000000000000000000000000000000000000000000000000000000000000000000
n0n0nnn000000000000000000000000000000000000000q000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000nnn0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000n0n0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000n0n0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000n0n0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000nnn0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
01100000281502015025150271501f15025150261501e15024150251501c15020150281502015025150271501f15025150261501e15024150251501c150201502c15020150251502a15021150251502d1501e150
01100000251502c15020150251502a1501e150251512a1501e15025150281501e15024151281501c15025150281502015025150271501f15025150261501e15024150251501c1502015028150201502515027150
011000001f15025150261501e15024150251501c150201502c15020150251502a15021150251502d1501e150251502c150201502515031150251502d1502f150261502d15032150261502c15031150251502d150
01100000361502d15033150341502c1503115032150291502f150311502a1502d15032150291502f150311502a1502d1502f150261502c1502d150251502a1502d150241502a1502c15025150281502a15021150
01100000271502815023150251502615021150251502d15021150251502715022150251502f15021150251502815023150271502f150231502715030150241502a150311502515028150341502c1503115033150
011000002b15031150321502a1503015031150281502c150341502c15031150331502b15031150321502a1503015031150281502c150341502c15031150331502b15031150321502a1503015031150281502c150
01100000381502c15031150361502d15031150391502a15031150381502c15031150361502a15031151361502a15031150341502a15030151341502815031150341502c15031150331502b15031150321502a150
011000003015031150281502c150381502c15031150361502d15031150391502a15031150381502c150311503b15032150381503915031150361503e150351503b1503c150361503915239142391323912239112
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3110000015611156111561115611156211562115621156310d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1700d1000d1000d1000d1000d1000d1000d1000d100
3110000000000000000000000000000000000000000000000962109621156211562121621216212d6213962101470014700147001470014700147001470014700147001470014700147001470014700147001470
011000001561115611156111561115621156211562115631216112161121611216112161121611216112161101170011700117001170011700117001170011700117001170011700117001170011700117001170
__music__
00 00414344
00 01424344
00 02424344
00 03424344
00 00414344
00 01424344
00 02424344
00 03424344
00 04424344
00 05424344
00 06424344
00 07424344
00 0b4b4344

