function clear()
  love.draw = nil
  love.keypressed = nil
  love.keyreleased = nil
  love.mousepressed = nil
  love.mousereleased = nil
  love.update = nil
end

function Run(name)
  run = {}
  local path = "run/" .. name
  require(path .. "/main")
  load()
end

function load()
end

function love.load()
  --love.window.setFullscreen(true, "desktop")

  Run("menu")
end

function love.draw()
end
