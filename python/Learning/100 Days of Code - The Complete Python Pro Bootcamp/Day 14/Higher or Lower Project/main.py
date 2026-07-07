from random import choice
from game_data import data
from art import logo, vs
def format_data(account):
    name = account['name']
    description = account['description']
    country = account['country']
    return f"{name}, a {description}, from {country}"

account_a = choice(data)
account_b = choice(data)
game_on = True
score = 0
print(logo)
while game_on:
    print(f"Compare A: {format_data(account_a)}")
    print(vs)
    print(f"Against B: {format_data(account_b)}")

    guess = input("Who has more followers? type 'A' or 'B' ").lower()

    if account_a["follower_count"] > account_b["follower_count"]:
        correct_answer = "a"

    else:
        correct_answer = "b"
    if guess == correct_answer:
        print("You're right!")
        print("\n" * 50)
        score += 1
        account_a = account_b
        account_b = choice(data)
    else:
        print("Nope try again!")
        print(f"Your final score is: {score}")
        game_on = False