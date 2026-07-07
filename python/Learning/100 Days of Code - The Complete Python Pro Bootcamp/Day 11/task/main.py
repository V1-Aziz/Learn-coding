from art import logo
import random

def deal_card ():
    cards = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
    card = random.choice(cards)
    return card

def calculate_score (cards):
    if sum(cards) == 21 and len(cards)==2:
        return 0

    if 11 in cards and sum(cards)==21:
        cards.remove(11)
        cards.append(1)

    return sum(cards)

def compare(p_score, c_score):
    if p_score == c_score:
        return "Draw!"
    elif p_score == 0:
        return "Player Won!, BlackJack"
    elif c_score == 0:
        return "dealer won!, BlackJack"
    elif p_score > 21:
        return "Over 21, you lose!"
    elif c_score > 21:
        return "dealer went over 21, you won!"
    elif p_score > c_score:
        return "You Won!"
    else:
        return "You Lose!"

def game():
    print(logo)
    player_cards = []
    computer_cards = []
    computer_score = -1
    player_score = -1
    game_over = False
    for _ in range(2):
        player_cards.append(deal_card())
        computer_cards.append(deal_card())

    while not game_over:
        player_score = calculate_score(player_cards)
        computer_score = calculate_score(computer_cards)
        print(f"Your cards is {player_cards}, and score is {player_score}")
        print(f"Computer first cards is {computer_cards}")
        if player_score == 0 or computer_score == 0 or player_score > 21:
            game_over = True
        else:
            player_should_deal = input("Type 'y' to get another card, type 'n' to pass: ")
            if player_should_deal == "y":
                player_cards.append(deal_card())
            else:
                game_over = True
    while computer_score != 0 and computer_score < 17:
        computer_cards.append(deal_card())
        computer_score = calculate_score(computer_cards)

    print(f"your final hand is {player_cards}, and score is {player_score}")
    print(f"computer first cards is {computer_cards}, final hand is {computer_score}")
    print(compare(player_score, computer_score))

while input("Do you want to play blackjack press y or n?")== "y":
    print("\n"*20)
    game()