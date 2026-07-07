from turtle import Turtle, Screen
import random

#object
timmy_the_tutrle = Turtle() 

#shape, color, 
color = ["brown", "tan", "spring green", "beige", "olive drab"]
timmy_the_tutrle.color("indianRed")

#movement
# for _ in range(5):
#     timmy_the_tutrle.left(72)
#     timmy_the_tutrle.forward(100)



def draw_shapes(sides):
    rotaion = 360/sides
    for _ in range(sides):
        timmy_the_tutrle.right(rotaion)
        timmy_the_tutrle.forward(100)
for sides in range(4,10):
    timmy_the_tutrle.color(random.choice(color))
    draw_shapes(sides)
#results
screen = Screen()

screen.exitonclick()