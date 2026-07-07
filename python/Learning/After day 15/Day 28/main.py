# ---------------------------- Imports ------------------------------- #
from tkinter import *
import math
# ---------------------------- CONSTANTS ------------------------------- #
PINK = "#e2979c"
RED = "#e7305b"
GREEN = "#9bdeac"
YELLOW = "#f7f5dd"
FONT_NAME = "Courier"
WORK_MIN = 25   
SHORT_BREAK_MIN = 5
LONG_BREAK_MIN = 20
rep = 0
timer = None
# ---------------------------- TIMER RESET ------------------------------- # 
def reset_timer():
    global timer, rep
    window.after_cancel(timer)
    canvas.itemconfig(timer_text,text="00:00")
    timer_label.config(text="Timer", fg=GREEN)
    check_mark.config(text="")
    rep =0
# ---------------------------- TIMER MECHANISM ------------------------------- # 
def start_timer():
    global rep
    work_sec = WORK_MIN*60
    short_break_sec = SHORT_BREAK_MIN*60
    long_break_sec= LONG_BREAK_MIN*60
    rep+=1
    if rep%8 ==0:
        count_down(10)
        timer_label.config(text="long Break", fg=RED)
    elif rep%2 == 0:
        count_down(2)
        timer_label.config(text="Break", fg=PINK)
    else:
        count_down(5)
        timer_label.config(text="Work", fg=GREEN)
    

    
# ---------------------------- COUNTDOWN MECHANISM ------------------------------- # 
def count_down(count):
    global timer
    global rep
    count_min = math.floor(count/60)
    count_sec = count%60
    if count_sec < 10:
        count_sec=f"0{count_sec}"

    canvas.itemconfig(timer_text, text=f"{count_min}:{count_sec}")
    if count>0:
        timer = window.after(1000, count_down, count-1)
    else:
        start_timer()
        mark = ""
        work_session = math.floor(rep/2)
        for _ in range(work_session):
            mark += "✔"
        check_mark.config(text=mark)

# ---------------------------- UI SETUP ------------------------------- #
window = Tk()
window.title("Pomodoro")

window.config(padx=100, pady=50, bg=YELLOW)

timer_label = Label(text="Timer",font=(FONT_NAME, 40), bg=YELLOW, fg=GREEN)
timer_label.grid(row=0, column=1)

canvas = Canvas(width=200, height=224, bg=YELLOW, highlightthickness=0)
tomato = PhotoImage(file="tomato.png") 
canvas.create_image(100,112, image=tomato, )

timer_text = canvas.create_text(103,125, text="00:00", font=(FONT_NAME, 25))
canvas.grid(row=1, column=1)

start_button = Button(text="Start",  borderwidth=0, command=start_timer)
reset_button = Button(text="Reset", command= reset_timer)
start_button.grid(row=2, column=0)
reset_button.grid(row=2, column=2)

check_mark = Label(text="", fg=GREEN, bg=YELLOW)
check_mark.grid(row=3, column=1)

window.mainloop()