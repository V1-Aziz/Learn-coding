from turtle import Turtle, Screen
import random

def random_color():
    r = random.randint(0, 255)
    g = random.randint(0, 255)
    b = random.randint(0, 255)
    random_color = (r, g, b)
    return random_color
#Create Objects
tim = Turtle()
screen = Screen()
screen.colormode(255)

#Shape, Color, Speed

tim.speed(0)
def draw_spirograph(gap_size):
    for _ in range(int(360/gap_size)):
        tim.circle(100)
        tim.color(random_color())
        tim.setheading(tim.heading()+gap_size)
draw_spirograph(1)

screen.exitonclick()