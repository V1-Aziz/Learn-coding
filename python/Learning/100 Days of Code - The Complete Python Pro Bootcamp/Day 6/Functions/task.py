def turn_left():
    print()
def turnRight():
    turn_left()
    turn_left()
    turn_left()

def front_is_clear():
    print()
def move():
    print()
def wall_on_right():
    print()
def wall_in_front():
    print()
def at_goal():
    print()
def navigate():
    while front_is_clear():
        move()
    while wall_on_right():
        move()
    if wall_in_front():
        if wall_on_right():
            turn_left()
        turnRight()


while not at_goal():
    navigate()