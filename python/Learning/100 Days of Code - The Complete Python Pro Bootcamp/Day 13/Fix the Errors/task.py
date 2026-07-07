try:
    age = int(input("How old are you?"))
except ValueError:
    print("You have enter invalid number, please make sure to write in number")
    age = int(input("How old are you?"))


if age >= 18:
    print(f"You can drive at age {age}.")
