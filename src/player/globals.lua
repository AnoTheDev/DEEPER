MOVE_SPEED = 150
BULLET_SPEED = 25
BULLET_LIFE = 20
SHOT_DELAY = 0.4
DEPTH = 0

Event.on("buff_move_speed" , function (speed)
    MOVE_SPEED = MOVE_SPEED + speed
    print(MOVE_SPEED)
end)

Event.on("buff_bullet_speed" , function (speed)
    BULLET_SPEED = math.max(5 , BULLET_SPEED + speed)
    print(BULLET_SPEED)
end)

Event.on("buff_bullet_life" , function (life)
    BULLET_LIFE = BULLET_LIFE + life
    print(BULLET_LIFE)
end)

Event.on("buff_shot_delay" , function (delay)
    SHOT_DELAY = SHOT_DELAY + delay
    print(SHOT_DELAY)
end)