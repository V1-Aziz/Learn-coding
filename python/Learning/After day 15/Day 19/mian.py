from turtle import Turtle, Screen

tim = Turtle()
screen = Screen()

def move_forward():
    tim.fd(10)
def move_backward():
    tim.bk(10)
def turn_right():
    new_heading = tim.heading()-10
    tim.setheading(new_heading)
def turn_left():
    new_heading = tim.heading()+10
    tim.setheading(new_heading)
def clear():
    tim.home()
    tim.penup()
    tim.clear()
    tim.pendown()

screen.listen()
screen.onkey(fun= lambda: move_forward(),key= "w")
screen.onkey(fun=lambda: move_backward(), key="s")
screen.onkey(fun=lambda: turn_left(), key="a")
screen.onkey(fun= lambda: turn_right(), key="d")
screen.onkey(fun= lambda: clear(), key="c")

screen.exitonclick()