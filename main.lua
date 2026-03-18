-- ChickenGameProject
-- Created by: Kevin Dowd
-- Created on: March 18, 2026

function love.load()
    math.randomseed(os.time())

    player = {
        x = 300,
        y = 550,
        speed = 300,
        scale = 0.5,
        sprite = love.graphics.newImage("player.png")
    }

    chickenSprites = {
        love.graphics.newImage("chicken1.png"),
        love.graphics.newImage("chicken2.png"),
        love.graphics.newImage("chicken3.png")
    }

    chicken = {
        x = math.random(50, 750),
        y = 0,
        speed = 150,
        scale = 0.3,
        sprite = chickenSprites[math.random(1, #chickenSprites)]
    }

    -- Speed-up power-up
    powerUp = {
        x = 0,
        y = 0,
        active = true,
        scale = 0.3,
        sprite = love.graphics.newImage("powerup.png"),
        timer = 0,
        respawnTime = 2
    }

    -- Slow-down power-up
    slowPowerUp = {
        x = 0,
        y = 0,
        active = true,
        scale = 0.3,
        sprite = love.graphics.newImage("slowpowerup.png"),
        timer = 0,
        respawnTime = 3
    }

    score = 0
    lives = 3
    gameOver = false

    spawnPowerUp()
    spawnSlowPowerUp()
end

function spawnChicken()
    chicken.x = math.random(50, 750)
    chicken.y = 0
    chicken.sprite = chickenSprites[math.random(1, #chickenSprites)]
end

function spawnPowerUp()
    powerUp.x = math.random(50, 750)
    powerUp.y = math.random(150, 400)
    powerUp.active = true
end

function spawnSlowPowerUp()
    slowPowerUp.x = math.random(50, 750)
    slowPowerUp.y = math.random(150, 400)
    slowPowerUp.active = true
end

function getWidth(obj)
    return obj.sprite:getWidth() * obj.scale
end

function getHeight(obj)
    return obj.sprite:getHeight() * obj.scale
end

function checkCollision(a, b)
    return a.x < b.x + getWidth(b) and
           b.x < a.x + getWidth(a) and
           a.y < b.y + getHeight(b) and
           b.y < a.y + getHeight(a)
end

function love.update(dt)
    if gameOver then
        return
    end

    -- Player movement
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end

    -- Keep player on screen
    if player.x < 0 then
        player.x = 0
    end
    if player.x + getWidth(player) > love.graphics.getWidth() then
        player.x = love.graphics.getWidth() - getWidth(player)
    end

    -- Chicken falling
    chicken.y = chicken.y + chicken.speed * dt

    -- Chicken hits speed-up power-up
    if powerUp.active and checkCollision(chicken, powerUp) then
        powerUp.active = false
        powerUp.timer = powerUp.respawnTime
        chicken.speed = chicken.speed + 100
    end

    -- Respawn speed-up power-up
    if not powerUp.active then
        powerUp.timer = powerUp.timer - dt
        if powerUp.timer <= 0 then
            spawnPowerUp()
        end
    end

    -- Chicken hits slow-down power-up
    if slowPowerUp.active and checkCollision(chicken, slowPowerUp) then
        slowPowerUp.active = false
        slowPowerUp.timer = slowPowerUp.respawnTime
        chicken.speed = chicken.speed - 100

        -- Prevent speed from going too low
        if chicken.speed < 50 then
            chicken.speed = 50
        end
    end

    -- Respawn slow-down power-up
    if not slowPowerUp.active then
        slowPowerUp.timer = slowPowerUp.timer - dt
        if slowPowerUp.timer <= 0 then
            spawnSlowPowerUp()
        end
    end

    -- Catch chicken
    if checkCollision(player, chicken) then
        score = score + 1
        spawnChicken()
    end

    -- Miss chicken
    if chicken.y > love.graphics.getHeight() then
        lives = lives - 1
        spawnChicken()
    end

    if lives <= 0 then
        gameOver = true
    end
end

function love.draw()
    love.graphics.draw(player.sprite, player.x, player.y, 0, player.scale, player.scale)
    love.graphics.draw(chicken.sprite, chicken.x, chicken.y, 0, chicken.scale, chicken.scale)

    if powerUp.active then
        love.graphics.draw(powerUp.sprite, powerUp.x, powerUp.y, 0, powerUp.scale, powerUp.scale)
    end

    if slowPowerUp.active then
        love.graphics.draw(slowPowerUp.sprite, slowPowerUp.x, slowPowerUp.y, 0, slowPowerUp.scale, slowPowerUp.scale)
    end

    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Lives: " .. lives, 10, 30)
    love.graphics.print("Chicken Speed: " .. chicken.speed, 10, 50)

    if gameOver then
        love.graphics.print("GAME OVER", 350, 300)
    end
end