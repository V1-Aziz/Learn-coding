import turtle 
import pandas

name = turtle.Turtle()
screen = turtle.Screen()
screen.title("US states game")
image = "blank_states_img.gif"
turtle.addshape(image)
turtle.shape(image)

game_on = True

name.hideturtle()
name.penup()

data = pandas.read_csv("50_states.csv")
state_list = data["state"].to_list()
missing = []

guessed_answers = []
while game_on:
    answer = screen.textinput(title=f"{len(guessed_answers)}/50 states correct", prompt="Write U.S. state's names").title()
    
    if answer in guessed_answers:
        continue
    elif answer in state_list:
        guessed_answers.append(answer)
        x = data[data["state"] == answer]["x"].item()
        y  = data[data["state"] == answer]["y"].item()
        name.goto(x, y)
        name.write(answer)
    elif answer == "Exit":
        game_on = False
        missing = [state for state in state_list if state not in guessed_answers]
        save_answers = pandas.DataFrame(missing)
        save_answers.to_csv("states_to_learn.csv", index=False)        
        
    if len(guessed_answers) == 50:
        game_on = False
    
screen.mainloop()
