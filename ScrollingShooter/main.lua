debug = true

bg = { x = 0, y = 0 }

player = { x = 200, y = 710, speed = 200, img = nil }

pizdec = {}

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.5
canShootTimer = canShootTimerMax

-- Image Storage
bulletImg = love.graphics.newImage('assets/bullet_2_blue.png')

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated

-- More Timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- Upgrade weapon
createUpgradeTimerMax = 15
createUpgradeTimer = createUpgradeTimerMax

upgradeImg = love.graphics.newImage('assets/upgrade.png')
upgrades = {}

-- More images
enemyImg = love.graphics.newImage('assets/enemy.png')

-- More storage
enemies = {}

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

isAlive = true
score = 0


function love.load(arg)
  bg.img = love.graphics.newImage('assets/Background.jpg')
  player.img = love.graphics.newImage('assets/plane.png')
  pizdec.img = love.graphics.newImage('assets/pizdec.png')
  -- we now have an asset ready to be used inside love

  sound = love.audio.newSource('assets/pew.mp3', 'static')
  music = love.audio.newSource('assets/bg.mp3', 'stream')
  music:play()
end

--

function love.update(dt) -- dt is deltaTime
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left', 'a') then
    if player.x > 0 then
      player.x = player.x - (player.speed*dt)
    end
  elseif love.keyboard.isDown('right', 'd') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed*dt)
    end
  end

  if love.keyboard.isDown('up', 'w') then
    if player.y > (love.graphics.getHeight()/2) then
      player.y = player.y - (player.speed * dt)
    end
  elseif love.keyboard.isDown('down', 's') then
    if player.y < (love.graphics.getHeight() - 55) then
      player.y = player.y + (player.speed*dt)
    end
  end

  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  if love.keyboard.isDown('space', 'rctrl', 'lctrl') and canShoot then
    -- Create some bullets
    if isAlive then
      sound:play()
      newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg}
      table.insert(bullets, newBullet)
      canShoot = false
      canShootTimer = canShootTimerMax
    end
  end

  -- update the positions of bullets
  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)

    if bullet.y < 0 then -- remove bullets when they pass of the screen
      table.remove(bullets, i)
    end
  end

  -- Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    randomNumber = math.random(10, love.graphics.getWidth() - 80)
    newEnemy = { x = randomNumber, y = -10, img = enemyImg }
    table.insert(enemies, newEnemy)
  end

  -- update enemies positions
  for i, enemy in ipairs(enemies) do
    if score < 20 then
      enemy.y = enemy.y + (200 * dt)
    elseif score < 50 then
      enemy.y = enemy.y + (300 * dt)
    else
      enemy.y = enemy.y + (400 * dt)
    end

    if enemy.y > 850 then
      table.remove(enemies,i)
    end
  end

  ------------------------------

  createUpgradeTimer = createUpgradeTimer - (1 * dt)
  if createUpgradeTimer < 9 then
    createUpgradeTimer = createUpgradeTimerMax

    randomNumber = math.random(10, love.graphics.getWidth() - 80)
    newUpgrade = { x = randomNumber, y = -10, img = upgradeImg }
    table.insert(upgrades, newUpgrade)
  end

  for z, upgrade in ipairs(upgrades) do
    upgrade.y = upgrade.y + (150 * dt)
    if upgrade.y > 850 then
      table.remove(upgrades, z)
    end
  end

  for z, upgrade in ipairs(upgrades) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(upgrade.x, upgrade.y, upgrade.img:getWidth(), upgrade.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(upgrades, z)
        bulletImg = love.graphics.newImage('assets/bullet_2_orange.png')
      end
    end
  end

  -----------------------------

  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        score = score + 1
      end
    end

    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
    and isAlive then
      table.remove(enemies, i)
      isAlive = false
    end
  end

  if not isAlive and love.keyboard.isDown('r') then
    bullets = {}
    enemies = {}

    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    player.x = 50
    player.y = 710

    score = 0
    isAlive = true
  end


end

--

function love.draw(dt)
  love.graphics.draw(bg.img, bg.x, bg.y)

  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end

  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end

  for z, upgrade in ipairs(upgrades) do
    love.graphics.draw(upgrade.img, upgrade.x, upgrade.y)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.print("SCORE: " .. tostring(score), 400, 10)


end
