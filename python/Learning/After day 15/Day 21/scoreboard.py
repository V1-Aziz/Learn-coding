from turtle import Turtle

class Scoreboard(Turtle):
        def __init__(self):
            super().__init__()
            self.score = 0
            with open("data.txt") as score:
                self.high_score = int(score.read())
            self.penup()
            self.hideturtle()
            self.color("white")
            self.goto(0, 270)
            self.update_score()

            
            
        def update_score(self):
            self.clear()
            self.write(f"Score: {self.score} High Score: {self.high_score}", align="center", font=("Courier", 24, "bold"))

        # def game_over(self):
        #     self.goto(0, 0)
        #     self.clear()
        #     self.write(f"Game over", align="center", font=("Courier", 24, "bold"))
        
        def reset(self):
            if self.score > self.high_score:
                self.save_score()
                self.high_score = self.score
            self.score = 0
            self.update_score()
        
        def save_score (self):
            with open("data.txt", "w") as score:
                score.write(str(self.score))

        def increase_score(self):
            self.score+=1
            self.update_score()
        

