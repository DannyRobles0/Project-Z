--The following is the code to run the game proper.
debug = true
--sets whether player can shoot and how long between each shot
canShoot = true
canShootTimerMax = 0.5
canShootTimer = canShootTimerMax
--initializes the bullet image and sets the projectile speed
bulletImg = nil
bulletSpeed = 200
bullets = {}
--[[This version only has one weapon available, but this allows future versions
    to add more and modify each of their ammunition]]
currWeapon = nil
infAmmo = true
currAmmo = nil
--Initializes the player's life
emptyHeart = nil
halfHeart = nil
wholeHeart = nil
playerLife = 3
heart1 = nil
heart2 = nil
heart3 = nil

background = love.graphics.newImage('assets/background.png')
--sets maximum time between enemies appearing
createEnemyTimerMax = 1.0
createEnemyTimer = createEnemyTimerMax
--initializes the enemies and their movement speed
enemyImg = nil
enemies = {}
enemySpeed = 100
--[[This function checks whether two objects are overlapping when given the
    position of each of those objects]]
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end


isAlive = true
score = 0
--The following two functions scale the graphics to the current display
local function scaleX()
  return love.graphics.getWidth() / background:getWidth()
end

local function scaleY()
  return love.graphics.getHeight() / background:getHeight()
end



function love.update(dt)

--The following handles the events on exiting the game and movement
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left', 'a') then
    if player.x > (48.299480 * scaleX()) then
      player.x = player.x - (player.speed*dt)
    end
  elseif love.keyboard.isDown('right','d') then
    if player.x < ((love.graphics.getWidth()- (59.664064*scaleX()) - player.img:getWidth())) then
      player.x = player.x +(player.speed*dt)
    end
  end
  if love.keyboard.isDown('up','w') then
    if player.y > (85.500981*scaleY()) then
      player.y = player.y +-(player.speed*dt)
    end
  elseif love.keyboard.isDown('down','s') then
    if player.y < (love.graphics.getHeight() - (3.504138*scaleY()) - player.img:getHeight()) then
      player.y = player.y + (player.speed*dt)
    end
  end

  canShootTimer = canShootTimer - (1 * dt)
if canShootTimer < 0 then
  canShoot = true
end
--[[calculates the trajectory the players bullet should take at the time the
    mouse is pressed to fire]]
  if love.mouse.isDown(1) and canShoot then

      local startX = player.x + player.img:getWidth() / 2
  		local startY = player.y + player.img:getHeight() / 2
  		local mouseX = love.mouse.getX()
  		local mouseY = love.mouse.getY()

  		local angle = math.atan2((mouseY - startY), (mouseX - startX))

  		local bulletDx = bulletSpeed * math.cos(angle)
  		local bulletDy = bulletSpeed * math.sin(angle)

  		table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
      canShoot = false
	    canShootTimer = canShootTimerMax

  end
  --[[checks whether any of the bullets have collided with any of the enemies.
  removes both from the screen if so]]
  for i, enemy in ipairs(enemies) do
  	for j, bullet in ipairs(bullets) do
  		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bulletImg:getWidth(), bulletImg:getHeight()) then
  			table.remove(bullets, j)
  			table.remove(enemies, i)
  			score = score + 1
  		end
  	end
    --[[checks for collision between the enemies and the player. If so,
      removes that specific enemy and adjusts the players life accordingly]]
  	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
  	and isAlive then
  		table.remove(enemies, i)
      playerLife = playerLife - .5
      if playerLife == 2.5 then
        player.heart3 = halfHeart
      elseif playerLife == 2 then
        player.heart3 = emptyHeart
      elseif playerLife == 1.5 then
        player.heart2 = halfHeart
      elseif playerLife == 1 then
        player.heart2 = emptyHeart
      elseif playerLife == .5 then
        player.heart1 = halfHeart
      elseif playerLife == 0 then
        player.heart1 = emptyHeart
      end

      if playerLife <.5 then
  		  isAlive = false
      end
  	end
  end

--[[This controls the appearance of enemies. It first selects a wall for an
    enemy to appear, then selects a point on that wall for the enemy to come
    from]]
  createEnemyTimer = createEnemyTimer - (1*dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax
    --1=left 2=top 3=right 4 = bottom
    randomSide = math.random(1,4)
    if randomSide == 1 then
        randomNumber = math.random((85.500981 * scaleY()), love.graphics.getHeight() - (3.504138*scaleY()))
        newEnemy = { x = (48.299480*scaleX()), y = randomNumber, img = enemyImg}
    elseif randomSide == 2 then
      randomNumber = math.random((48.299480 * scaleX()), love.graphics.getWidth() - (59.66464*scaleX()))
      newEnemy = { x = randomNumber, y = (85.500981*scaleY()), img = enemyImg}
    elseif randomSide == 3 then
      randomNumber = math.random((85.500981 * scaleY()), love.graphics.getHeight() - (3.504138*scaleY()))
      newEnemy = { x = love.graphics.getWidth() - (59.66464*scaleX())-enemyImg:getWidth(), y = randomNumber, img = enemyImg}
    elseif randomSide == 4 then
      randomNumber = math.random(48.299480 * scaleX(), love.graphics.getWidth() - 59.66464*scaleX())
      newEnemy = { x = randomNumber, y = love.graphics.getHeight() - (3.504138*scaleY())-enemyImg:getHeight(), img = enemyImg}
    end
    table.insert(enemies, newEnemy)
  end
--This controls the path of the enemies. They always move toward the player
  for i, enemy in ipairs(enemies) do
    local enemyDx = player.x - enemy.x
    local enemyDy = player.y - enemy.y
    distance = math.sqrt(enemyDx*enemyDx+enemyDy*enemyDy)
    enemy.y = enemy.y + (enemyDy/distance * enemySpeed *dt)
    enemy.x = enemy.x + (enemyDx/distance * enemySpeed *dt)



  end


--this updates the position of each bullet along its trajectory
  for i,v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
	end
--[[this handles restarting the game after a player dies and selects to
 play again]]
  if not isAlive and love.keyboard.isDown('r') then
    bullets = {}
    enemies = {}

    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    player.x = love.graphics.getWidth()/2
    player.y = (love.graphics.getHeight()/2)

    score = 0
    playerLife = 3
    player.heart1 = wholeHeart
    player.heart2 = wholeHeart
    player.heart3 = wholeHeart
    isAlive = true
  end
end

player = { x = love.graphics.getWidth()/2, y = (love.graphics.getHeight()/2), speed = 150, img = nil, heart1 = nil, heart2 = nil, heart3 = nil}


--Loads and initializes all the assests and components of the game
function load(arg)
  love.window.setFullscreen(false, "desktop")
  player.img = love.graphics.newImage('assets/player.png')
  bulletImg = love.graphics.newImage('assets/fireball.png')
  enemyImg = love.graphics.newImage('assets/skull.png')
  currWeapon = love.graphics.newImage('assets/fireball.png')
  infSymbol = love.graphics.newImage('assets/inf.png')
  emptyHeart = love.graphics.newImage('assets/emptyHeart.png')
  halfHeart = love.graphics.newImage('assets/halfHeart.png')
  wholeHeart = love.graphics.newImage('assets/wholeHeart.png')
  player.heart1 = wholeHeart
  player.heart2 = wholeHeart
  player.heart3 = wholeHeart
  local sx = love.graphics.getWidth() / background:getWidth()
  local sy = love.graphics.getHeight() / background:getHeight()
  love.graphics.draw(background,0,0,0,sx,sy)
  love.graphics.draw(currWeapon,450*scaleX(),30*scaleY(),0,sx,sy)

  if isAlive then
    love.graphics.draw(player.img,player.x,player.y)
    love.graphics.draw(player.heart1, 50*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart2, 90*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart3, 130*scaleX(), 35*scaleY(),0,sx,sy)
  else
    love.graphics.draw(player.heart1, 50*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart2, 90*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart3, 130*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.setColor(0,0,0)
    love.graphics.setNewFont('assets/computer.ttf', (20*scaleY()))
    love.graphics.print("FINAL SCORE: " .. tostring(score), love.graphics:getWidth()/2-100*scaleX(), love.graphics:getHeight()/2-10*scaleY())
    love.graphics.print("Press 'r' to restart", love.graphics:getWidth()/2-100*scaleX(), love.graphics:getHeight()/2+10*scaleY())
    enemies = {}
    bullets = {}
    createEnemyTimer = 0
  end
end
--displays all the assests on screen
function love.draw(dt)
  local sx = love.graphics.getWidth() / background:getWidth()
  local sy = love.graphics.getHeight() / background:getHeight()
  love.graphics.draw(background,0,0,0,sx,sy)
  love.graphics.draw(currWeapon,450*scaleX(),30*scaleY(),0,sx,sy)

  if isAlive then
    love.graphics.draw(player.img,player.x,player.y)
    love.graphics.draw(player.heart1, 50*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart2, 90*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart3, 130*scaleX(), 35*scaleY(),0,sx,sy)
  else
    love.graphics.draw(player.heart1, 50*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart2, 90*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.draw(player.heart3, 130*scaleX(), 35*scaleY(),0,sx,sy)
    love.graphics.setColor(255,255,255)
    love.graphics.setNewFont('assets/computer.ttf', (20*scaleY()))
    love.graphics.print("FINAL SCORE: " .. tostring(score), love.graphics:getWidth()/2-100*scaleX(), love.graphics:getHeight()/2-10*scaleY())
    love.graphics.print("Press 'r' to restart", love.graphics:getWidth()/2-100*scaleX(), love.graphics:getHeight()/2+10*scaleY())
    enemies = {}
    bullets = {}
    createEnemyTimer = 0
  end

  for i,v in ipairs(bullets) do
		love.graphics.draw(bulletImg, v.x, v.y, 3)
	end

  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
  love.graphics.setColor(255,255,255)
  love.graphics.setNewFont('assets/computer.ttf', (20*scaleY()))
  love.graphics.print("SCORE: " .. tostring(score), 800*scaleX(), 10*scaleY())
  love.graphics.setNewFont('assets/computer.ttf', (16*scaleY()))
  love.graphics.print("WEAPON", 430*scaleX(), 10*scaleY())
  love.graphics.print("AMMO", 540*scaleX(), 10*scaleY())
  if infAmmo then
    love.graphics.draw(infSymbol,550*scaleX(), 30*scaleY(),0,sx,sy)
  end
  love.graphics.setColor(255,255,255)
end
