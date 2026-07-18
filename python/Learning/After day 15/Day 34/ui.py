from  tkinter import *
from quiz_brain import QuizBrain
THEME_COLOR = "#375362"

class QuizInterFace:
    def __init__(self, quiz_brain: QuizBrain):
        #Initialize tkinter window 
        self.quiz = quiz_brain
        
        self.window = Tk()
        self.window.title("Quizzler")
        self.window.config(padx=20, pady=20, bg=THEME_COLOR)

        #image
        self.true_image = PhotoImage(file="images/true.png")
        self.false_image = PhotoImage(file="images/false.png")
        #Canvas
        self.canvas = Canvas(width=300, height=250, highlightthickness=0, background="white")
        self.canvas.grid(row=1, column=0, columnspan=2)
        self.question_text = self.canvas.create_text(150,125, fill=THEME_COLOR, text="Question", font=("Arial", 20, "italic"), width=290)        
        self.s_text = Label(text=f"Score: 0", font=("Arial", 10), bg=THEME_COLOR, fg="White", padx=20, pady=20)
        self.s_text.grid(row=0, column = 1)

        #buttons
        self.true_button = Button(image=self.true_image, highlightthickness=0, borderwidth=0, command=self.true)

        self.false_button = Button(image=self.false_image, highlightthickness=0, borderwidth=0, command=self.false)

        self.true_button.grid(row=2,column=0, padx=20, pady=20 ,)
        self.false_button.grid(row=2,column=1, padx=20, pady=20 ,)

        self.get_next_question()

        #final
        self.window.mainloop()
    def get_next_question(self):
            self.canvas.config(bg="white")
            self.q_text = self.quiz.next_question()
            self.s_text.config(text=f"score: {self.quiz.score}")
            self.canvas.itemconfig(self.question_text, text=self.q_text)

    def true(self):
        i_true = self.quiz.check_answer("true")
        self.give_feedback(i_true)

    def false(self):
        i_false = self.quiz.check_answer("false")
        self.give_feedback(i_false)

    def give_feedback(self, is_right):
        if is_right:
             self.canvas.config(bg="green")
        else:
             self.canvas.config(bg="red")
        self.window.after(1000, self.get_next_question)