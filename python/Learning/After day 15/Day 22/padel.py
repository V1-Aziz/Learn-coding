from turtle import Turtle

class Padel(Turtle):
    def __init__(self, position):
        super().__init__()
        self.shape("square")
        self.shapesize(stretch_wid=3.5, stretch_len=0.75)
        self.goto(position)
        self.color("white")
        self.penup()
    
    def up(self):
        new_y = self.ycor()+20
        self.goto(self.xcor(),new_y)
    
    def down(self):
        new_y = self.ycor()-20
        self.goto(self.xcor(),new_y)

    def auto_move(self, target_y):
        if self.ycor() < target_y - 40:
            self.up()
        elif self.ycor() > target_y + 40:
            self.down()