from turtle import Screen
from padel import Padel
from ball import Ball
from scoreboard import Scoreboard
import time

screen = Screen()
screen.setup(width=800, height=600)
screen.bgcolor("black")
screen.title("Pong Game")
screen.tracer(0)

#Game mode selection
mode = screen.textinput("Pong", "Type 1 for single player or 2 for two players:")
single_player = (mode == "1")

#Declear objects
left_padel = Padel((-380, 0))
right_padel = Padel((380, 0))
ball = Ball()
scoreboard = Scoreboard()

#Movements
screen.listen()
screen.onkey(left_padel.up, "Up")
screen.onkey(left_padel.down, "Down")
if not single_player:
    screen.onkey(right_padel.up, "w")
    screen.onkey(right_padel.down, "s")


game_on = True
#Loop to make continue
while game_on:
    time.sleep(ball.move_speed)
    screen.update()
    ball.move()

    if single_player and ball.move_x > 0:
        right_padel.auto_move(ball.ycor())

    if ball.ycor() <= -280 or ball.ycor() >=280:
        ball.bounce_y()

    if ball.distance(right_padel) < 50 and ball.xcor() > 320:
        ball.bounce_x()
        ball.increase_speed()
    elif ball.distance(left_padel) < 50 and ball.xcor() < -320:
        ball.bounce_x()
        ball.increase_speed()

    if ball.xcor() > 395:
        scoreboard.l_point()
        ball.reset_position()
    elif ball.xcor() < -395:
        scoreboard.r_point()
        ball.reset_position()
screen.exitonclick()