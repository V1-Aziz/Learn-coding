from turtle import Turtle, Screen
import random

is_race_on = False

screen = Screen()
screen.setup(width=500, height= 500)
user_bet = screen.textinput(title="Bet?", prompt="Which turtle will win the race? Enter a color: ")
color = ["red", "orange", "yellow", "green", "blue", "purple"]
all_turtles = []

y_current=-100

print(user_bet)
for i in range(0,6):
    new_turtle = Turtle(shape="turtle")
    new_turtle.color(color[i])
    new_turtle.penup()
    new_turtle.goto(x = -230, y = y_current)
    y_current += 50
    all_turtles.append(new_turtle)

if user_bet:
    is_race_on = True

while is_race_on:
    for turtle in all_turtles:
        if turtle.xcor() >230:
            is_race_on = False
            winning_color = turtle.pencolor()
            if winning_color == user_bet:
                print(f"You've won!, The {winning_color} turtle is the winner!")
            else:
                print(f"You've lost!, The {winning_color} turtle is the winner!")
        random_distance = random.randint(0, 10)
        turtle.forward(random_distance)

screen.exitonclick()