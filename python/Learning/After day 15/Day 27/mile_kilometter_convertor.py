from tkinter import *

def convert_mile_kilometer():
    mile = int(mile_input.get())
    convert = mile * 1.609
    converted_label["text"] = convert

window = Tk()

window.title("Mile to Km Conventer")
window.minsize(width=350, height=100)
window.config(padx=50, pady=25)

#First row
mile_input = Entry(width=10)
mile_input.grid(row=0, column=1)

mile_label = Label(text="Miles", font=("arial", 15))
mile_label.grid(row=0, column=2)

#Second row
equal_label = Label(text="is equal to")
equal_label.grid(row=1, column=0)

#Here not the variable to be like this so it can be changable 
converted_label = Label()
converted_label["text"] = 0
converted_label.grid(row=1, column=1)

km_label = Label(text="Km")
km_label.grid(row=1, column=2)

#Third row
convert_button = Button(text="Calculate", command=convert_mile_kilometer)
convert_button.grid(row=2, column=1)

window.mainloop()