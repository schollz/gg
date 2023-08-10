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
  screen.update()
end
