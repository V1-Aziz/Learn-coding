from turtle import Turtle, Screen
import random

def random_color():
    r = random.randint(0, 255)
    g = random.randint(0, 255)
    b = random.randint(0, 255)
    random_color = (r, g, b)
    return random_color

#Object Name
tim = Turtle()
screen = Screen()
screen.colormode(255)

#Color and Shape
# color = ["brown", "tan", "spring green", "beige", "olive drab", "red", "indigo", "lime green", "medium blue", "dark gray", "dark cyan"]
# tim.color("green")
tim.pensize(10)


#movement
directions = [0, 90, 180, 270]
tim.speed(0)
for _ in range(100):
    tim.color(random_color())
    tim.setheading(random.choice(directions))
    tim.forward(50)

screen.exitonclick()