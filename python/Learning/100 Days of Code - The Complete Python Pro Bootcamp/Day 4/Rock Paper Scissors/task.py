import random
rock = '''
    _______
---'   ____)
      (_____)
      (_____)
      (____)
---.__(___)
'''

paper = '''
    _______
---'   ____)____
          ______)
          _______)
         _______)
---.__________)
'''

scissors = '''
    _______
---'   ____)____
          ______)
       __________)
      (____)
---.__(___)
'''

ListRockPaperScissor = [rock, paper, scissors]

User_choice = int(input("What will you choose (Rock, Paper, Scissors)?"))
print(ListRockPaperScissor[User_choice])
print("Computer: ")
ComputerChoice = random.randint(0,2)
print(ListRockPaperScissor[ComputerChoice])

if ListRockPaperScissor[User_choice]>ListRockPaperScissor[ComputerChoice]:
    print("You Won!")
elif ListRockPaperScissor[ComputerChoice] > ListRockPaperScissor[User_choice]:
    print("You Lost!")
elif User_choice == 0 and ComputerChoice == 2:
    print("You Won!")
elif ComputerChoice == 0 and User_choice == 2:
    print("You lose!")
else:
    print("DRAW!")
