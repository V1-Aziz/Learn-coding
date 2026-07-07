from turtle import Turtle
START_POSITIONS = [(0,0), (-20,0), (-40,0)]
MOVE_DISTANCE = 20
UP = 90
DOWN = 270
LEFT = 180
RIGHT =0

class Snake:
    def __init__(self):
        self.segements= []
        self.create_snake()
        self.head = self.segements[0]

    #Create snake (Turtle)
    def create_snake(self):
        for position in START_POSITIONS:
            self.add_segment(position)

    #Snake move with head
    def move(self):
        for seg_num in range(len(self.segements)-1 ,0, -1):
            new_x = self.segements[seg_num-1].xcor()
            new_y = self.segements[seg_num-1].ycor()
            self.segements[seg_num].goto(new_x, new_y)
        self.segements[0].forward(MOVE_DISTANCE)

    def add_segment(self, position):
            new_segement = Turtle("square")
            new_segement.color("white")
            new_segement.penup()
            new_segement.goto(position)
            self.segements.append(new_segement)

    def extend(self):
        self.add_segment(self.segements[-1].position())

    def reset(self):
        for seg in self.segements:
            seg.goto(1000,1000)
        self.segements.clear()
        self.create_snake()
        self.head = self.segements[0]

    #Movement
    def up(self):
        if self.head.heading()!=DOWN:
            self.head.setheading(UP)

    def left(self):
        if self.head.heading()!=RIGHT:
            self.head.setheading(LEFT)

    def down(self):
        if self.head.heading()!=UP:
            self.head.setheading(DOWN)

    def right(self):
        if self.head.heading()!=LEFT:
            self.head.setheading(RIGHT)
