from tkinter import *
import pandas
import random
BACKGROUND_COLOR = "#B1DDC6"
# ---------------------------- UI SETUP ------------------------------- #
window = Tk()

window.title("Flashy")
window.config(padx=50, pady=50, bg=BACKGROUND_COLOR)

# ---------------------------- PANDAS ------------------------------- #
try:
    data = pandas.read_csv("data/words_to_learn.csv")
except FileNotFoundError:
    data = pandas.read_csv("data/french_words.csv")
to_learn = data.to_dict(orient="records")
current_card = random.choice(to_learn)
text = current_card["French"]
# ------------------------- IMAGES ---------------------------- #
back_img = PhotoImage(file="images/card_back.png")
front_img = PhotoImage(file="images/card_front.png")
right_img = PhotoImage(file="images/right.png")
wrong_img = PhotoImage(file="images/wrong.png")
# ------------------------- CANVAS ---------------------------- #
canvas = Canvas(height=526, width=800, highlightthickness=0, )
front_image = canvas.create_image(400,263, image = front_img)
canvas.grid(row=0, column=0,columnspan=2)

card_title = canvas.create_text(400, 150, fill="black",font=("Ariel", 40, "italic"),  text="French")
card_word = canvas.create_text(400, 263, fill="black",font=("Ariel", 60, "bold"), text=text)

def flip_card():
    canvas.itemconfig(front_image, image=back_img)
    canvas.itemconfig(card_title, fill="white", text="English" )
    canvas.itemconfig(card_word, fill="white", text=current_card["English"])

def next_card():
    global current_card, flip_timer
    window.after_cancel(flip_timer)
    current_card = random.choice(to_learn)
    canvas.itemconfig(front_image, image=front_img)
    canvas.itemconfig(card_title, text="French", fill = "black")
    canvas.itemconfig(card_word, text=current_card["French"], fill = "black")
    flip_timer = window.after(3000, flip_card)

def i_know():
    to_learn.remove(current_card)
    pandas.DataFrame(to_learn).to_csv("data/words_to_learn.csv", index=False)
    next_card()

flip_timer = window.after(3000, flip_card)

right_button = Button(image=right_img, highlightthickness=0, command=i_know)
right_button.grid(row=1, column=1)
wrong_button = Button(image=wrong_img, highlightthickness=0, command=next_card)
wrong_button.grid(row=1, column=0)
# ------------------------ EXECUTING --------------------------- #
window.mainloop()