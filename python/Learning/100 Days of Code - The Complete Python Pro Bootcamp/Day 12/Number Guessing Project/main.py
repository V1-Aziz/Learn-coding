from art import logo
import random

#Starting the game

def game ():
    attempts = 0
    game_off = False
    number_to_guess = random.randint(1, 100)
    print(logo)
    print("Welcome to number guessing game")
    print("I'm think of a number between 1 and 100")
    p_choice = input("Choose difficulty. Type 'Easy' or 'Hard': ").lower()
    if p_choice == "easy":
        attempts = 10
    else:
        attempts = 5
    while not game_off:
        if attempts == 0:
            print("Game Over! Attempts Wasted ")
            break
        print(f"You have {attempts} attempts remaining. Don't waste it")
        p_guess = int(input("Make a guess: "))
        if p_guess == number_to_guess:
            print(f"correct the guessing number is {number_to_guess}")
            game_on = True
        elif p_guess > number_to_guess:
            print("Too high")
        elif p_guess < number_to_guess:
            print("Too low")


        attempts -= 1
game()