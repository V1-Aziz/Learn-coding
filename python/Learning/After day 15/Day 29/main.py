# ---------------------------- IMPORTS ------------------------------- #
from tkinter import *
from tkinter import messagebox
import random
import pyperclip
import json
# ---------------------------- PASSWORD GENERATOR ------------------------------- #
def password_generator():
    password_input.delete(0, END)
    letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    symbols = ['!', '#', '$', '%', '&', '(', ')', '*', '+']
    
    nr_letters = random.randint(8, 10)
    nr_symbols = random.randint(2, 4)
    nr_numbers = random.randint(2, 4)

    letter_list = [random.choice(letters) for _ in range(nr_letters)]
    num_list = [random.choice(numbers) for _ in range(nr_numbers)]
    sym_list = [random.choice(symbols) for _ in range(nr_symbols)]

    password_list = letter_list + num_list + sym_list

    random.shuffle(password_list)

    password = ""
    for char in password_list:
        password += char
    password_input.insert(0,password)
# ---------------------------- FIND PASSWORD------------------------------- #    
def find_password():
    try:
        with open("data.json", "r") as data_file:
            data = json.load(data_file)
            website = website_input.get()
            if website in data:
                email = data[website]["email"]
                password = data[website]["password"]
                messagebox.showinfo(title="Found", message=f"{email} \n {password}")
            else:
                messagebox.showinfo(title="Not found", message=f"No details for the {website} exists")
    except FileNotFoundError:
        messagebox.showinfo(title="File Error", message="No Data File Found")

# ---------------------------- SAVE PASSWORD ------------------------------- #
def save():
    website = website_input.get()
    email = email_input.get()
    password = password_input.get()

    new_data = {
        website:{
            "email":email,
            "password":password
        }
    }
    
    if not website or not email or not password:
        messagebox.showerror(title="Fill the boxes", message="field is empty, fill it")
    else:
        try:
            with open("data.json", "r") as data_file:
                data = json.load(data_file)
                data.update(new_data)
        except (FileNotFoundError, json.JSONDecodeError):
            data = new_data

        with open("data.json", "w") as data_file:
            #Saving updated data
            json.dump(data, data_file, indent=1)

            website_input.delete(0,END)
            email_input.delete(0,END)
            password_input.delete(0,END)
# ---------------------------- UI SETUP ------------------------------- #

window = Tk()

window.title("Password Manager")
window.config(padx=20,pady=20)

canvas = Canvas(height=200, width=200, highlightthickness=0)
image = PhotoImage(file="logo.png")
canvas.create_image(100,100,image=image)
canvas.grid(row=0, column=1)

website_lable = Label(text="Website: ", padx=10, highlightthickness=0)
website_lable.grid(row=1,column=0)
website_input = Entry(width=21, highlightthickness=0)
website_input.grid(row=1, column=1,)
website_input.focus()
    
search_button = Button(text="Search", command=find_password)
search_button.grid(row=1, column=2)

email_username_lable = Label(text="Email/Username : ", padx=10, highlightthickness=0)
email_username_lable.grid(row=2,column=0)
email_input = Entry(width=36, highlightthickness=0)
email_input.grid(row=2, column=1, columnspan=2)

password_lable = Label(text="Password : ", highlightthickness=0, padx=10)
password_lable.grid(row=3,column=0)
password_input = Entry(width=21, highlightthickness=0)
password_input.grid(row=3, column=1,)

generate_button = Button(text="Generate Password", command=password_generator)
generate_button.grid(column=2, row=3)
3
add_button = Button(text="Add", width=36, command=save)
add_button.grid(row=4, column=1, columnspan=2)

window.mainloop()