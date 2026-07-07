print("Welcome to the tip calculator!")
bill = float(input("What was the total bill? $"))
tip = int(input("What percentage tip would you like to give? 10 12 15 "))
people = int(input("How many people to split the bill? "))

tipPercentage = tip /100
totalTipAmount = tipPercentage * bill
fullAmount = bill + totalTipAmount
billPerPerson = fullAmount/people
finalAmount = round(billPerPerson, 2)
print(f"The bill split into {people} which is: ${finalAmount}")
print("Thank you please come again!")
