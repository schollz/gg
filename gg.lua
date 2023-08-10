-- gg

viewwave_=include("lib/viewwave")

function init()
  viewwave=viewwave_:new{path="/home/we/dust/code/gg/lib/vocals_bpm100.flac"}
  clock.run(function()
    while true do
      clock.sleep(1/10)
      redraw()
    end
  end)
end

function enc(k,d)
  viewwave:enc(k,d)
end

function key(k,z)
  viewwave:key(k,z)
end

function redraw()
  screen.clear()
  viewwave:redraw()


  screen.blend_mode(0)

  screen.level(10)
  screen.line_width(0.9)
  screen.move(5,0)
  screen.line_rel(10,24)
  screen.line_rel(20,-10)
  screen.stroke()
  screen.update()
end
