pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
#include ../super-extinction-event.p8:1
#include ../super-extinction-event.p8:3

bs={} --brontos
⧗=0
state="start"

reds={}
blus={}
gres={}

function _init()

--	for i=0,2 do
--		local	b={x=0,y=64,r=0,state="idle",enabled=true,dx=0,dy=0,
--			--angle, delta angle, mag, delta mag, grounded
--		 a=.25,s=.004,d=1,c=2^i,id=i,
--		 --frame index, all frames
--		 fr=1,frames={bronto_idle,bronto_run1,bronto_run2,}
--		}
--		add(bs,b)
--	end
	
end

function _update()

	⧗+=1
	
	if ⧗<100 and ⧗%10==0 then
		local b=newbronto()
		b.c=1 b.⧗=0
		add(reds,b)
		add(bs,b)
	end
	
	if ⧗>100 and ⧗<200 and ⧗%10==0 then
		local b=newbronto()
		b.c=2 b.⧗=0
		add(blus,b)
		add(bs,b)
	end

	for b in all(bs) do
		b.⧗+=1
		local pct=b.⧗/60
		if pct>1 then
			b.x=64
		else
			b.x=64*pct
		end
	end

--	for b in all(bs) do
--		b.x+=b.dx
--		if b.x>64 then b.x=64 end
--	end

--	if state=="start" then
--		idx=ceil(⧗/99)
--		pct=(⧗%100)/99
--		bs[idx].x=pct*64
--	end

--	for b in all(bs) do
--		local a=b.id/3+⧗/100
--		d=cos(⧗/200)*4
--		b.x,b.y=64+cos(a)*d,64+sin(a)*d
--	end
end

function _draw()
		
	cls()
	for r in all(reds) do
		render_ent(r)
	end 
 memcpy(0x8000, 0x6000, 0x2000)

 cls()
	for b in all(blus) do
		render_ent(b)
	end 
 memcpy(0xA000, 0x6000, 0x2000)

 cls()
--	render_ent(bs[3])
 for addr = 0x6000, 0x7FFF, 4 do
  poke4(addr, $addr | $(addr + 0x2000) | $(addr + 0x4000))
 end

	pal(1,8,1) --red color 1
	pal(2,-4,1) --blue color 2
	pal(4,11,1) --green color 3
	
	pal(3,14,1) --red+blue=pink
	pal(6,12,1) --blue+green=lblue
	pal(5,10,1) --red+green=yellow	
	
	
end

function newbronto()
	return {x=0,y=64,r=0,state="idle",enabled=true,dx=0,dy=0,
			--angle, delta angle, mag, delta mag, grounded
		 a=.25,s=.004,d=1,c=1,
		 --frame index, all frames
		 fr=1,frames={bronto_idle,bronto_run1,bronto_run2,}
		}
end
-->8
--xtra thick line
function xline(x1,y1,x2,y2,w) 
	for i=-w,w do
		for j=-w,w do
			line(x1+i,y1+j,x2+i,y2+j)
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
