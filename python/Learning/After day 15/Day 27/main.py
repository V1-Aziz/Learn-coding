from tkinter import *

def button_clicked():
    print("I Got Clicked!")
    new_text = input.get()
    my_lable["text"] = new_text

window = Tk()

window.title("Tkinter first program")
window.minsize(width=500, height=300)
window.config(padx=100, pady=200)

my_lable = Label(text="I'm lable", font = ("arial", 24, "italic"))

my_lable["text"] = "New Text"
my_lable.config(text="New Text")

my_lable.grid(column=0,row=0)

button = Button(text="Click me", command=button_clicked)
button.grid(column=1, row=1)

button1 = Button(text="Another button")
button1.grid(column=2, row=0)

input = Entry(width=10)
input.grid(column=3, row=3)

window.mainloop()
