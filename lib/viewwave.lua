local ViewWave={}

function ViewWave:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function ViewWave:init()
  if self.path==nil then
    print("[viewwave] error: no path!")
    do return end
  end
  self.pathname,self.filename,self.ext=string.match(self.path,"(.-)([^\\/]-%.?([^%.\\/]*))$")
  self.ch,self.samples,self.samplerate=audio.file_info(self.path)
  if self.samples<10 or self.samples==nil then
    print("[viewwave] no samples")
    do return end
  end
  self.duration=self.samples/self.samplerate
  self.view={0,self.duration}
  self.cursors={self.duration*0.4,self.duration*0.6}
  self.ci=1
  self.height=48
  self.width=126
  self.debounce_zoom=0
  self.dat_path="/home/we/dust/data/gg/"..self.path:gsub("/","_")..".dat"
  self.dat_path=string.gsub(self.dat_path,"%s+","")
  self.waveform_file=string.gsub(self.filename,"%s+","")
  if not util.file_exists(self.dat_path) then
    os.execute(string.format("audiowaveform -q -i %s -o %s -z 2 -b 8",self.path,self.dat_path))
  end
  self:render()
end

function ViewWave:do_zoom(d)
  self.debounce_zoom=(d>0 and 1 or-1)
end

function ViewWave:do_move(d)
  if self.cursors[self.ci]<self.view[1] then
    self.cursors[self.ci]=self.view[1]
  end
  if self.cursors[self.ci]>self.view[2] then
    self.cursors[self.ci]=self.view[2]
  end
  self.cursors[self.ci]=util.clamp(self.cursors[self.ci]+d*((self.view[2]-self.view[1])/128),0,self.duration)
  if self.cursors[1]>self.cursors[2] then
    self.cursors[2],self.cursors[1]=self.cursors[1],self.cursors[2]
  end
end

function ViewWave:enc(k,d)
  if k==1 and d~=0 then
    self:do_zoom(d)
  elseif k==2 then
    self.ci=1
    self:do_move(d)
  elseif k==3 then
    self.ci=2
    self:do_move(d)
  end
end

function ViewWave:key(k,z)
  if z==0 then
    do return end
  end
  if k==2 then
    self:sel_cursor(3-self.ci)
  elseif k==3 then
  end
end

function ViewWave:sel_cursor(ci)
  self.ci=ci
end

function ViewWave:zoom(zoom_in)
  local zoom_amount=1.4
  local view_duration=(self.view[2]-self.view[1])
  local view_duration_new=zoom_in and view_duration/zoom_amount or view_duration*zoom_amount
  local cursors=self.cursors
  local cursor_center=(cursors[1]+cursors[2])/2
  local view_new={0,0}
  view_new[1]=util.clamp(cursor_center-view_duration_new/2,0,self.duration)
  view_new[2]=util.clamp(cursor_center+view_duration_new/2,0,self.duration)
  if (view_new[2]-view_new[1])<0.005 then
    do return end
  end
  self.view={view_new[1],view_new[2]}
  self:render()
end

function ViewWave:render()
  os.execute(string.format("audiowaveform -q -i %s -o /dev/shm/%s.png -s %2.4f -e %2.4f -w %2.0f -h %2.0f --background-color 000000 --waveform-color 555555 --no-axis-labels --compression 0",self.dat_path,self.waveform_file,self.view[1],self.view[2],self.width,self.height))
end

function ViewWave:redraw(x,y,show_cursor)
  screen.blend_mode(14)
  if show_cursor==nil then
    show_cursor=true
  end
  if self.waveform_file==nil or not util.file_exists("/dev/shm/"..self.waveform_file..".png") then
    do return "NOTHING LOADED" end
  end
  if self.debounce_zoom~=0 then
    if self.debounce_zoom<0 then
      self.debounce_zoom=self.debounce_zoom+1
      if self.debounce_zoom==0 then
        self:zoom(false)
      end
    else
      self.debounce_zoom=self.debounce_zoom-1
      if self.debounce_zoom==0 then
        self:zoom(true)
      end
    end
  end
  local x=1
  local y=22
  screen.display_png("/dev/shm/"..self.waveform_file..".png",x,y)
  screen.rect(1,26,127,38)
  screen.level(15)
  screen.stroke()
  screen.update()
  if show_cursor then
    local cursors=self.cursors
    for i=1,2 do
      local cursor=cursors[i]
      if cursor>=self.view[1] and cursor<=self.view[2] then
        local pos=util.linlin(self.view[1],self.view[2],x+1,self.width+1,cursor)
        screen.level(15)
        screen.move(pos,27)
        screen.line(pos,62)
        screen.stroke()
      end
    end
  end

  local v1=util.linlin(self.view[1],self.view[2],x+1,self.width+1,self.cursors[1])
  local v2=util.linlin(self.view[1],self.view[2],x+1,self.width+1,self.cursors[2])
  screen.blend_mode(9)
  screen.level(5)
  screen.rect(v1,27,v2-v1,62-27)
  screen.fill()

  screen.move(5,5)
  screen.text(string.format("%2.3f [%2.3f]",self.cursors[1],self.cursors[2]-self.cursors[1]))
end

return ViewWave
