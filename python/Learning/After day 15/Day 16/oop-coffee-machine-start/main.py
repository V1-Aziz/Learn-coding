from menu import Menu
from coffee_maker import CoffeeMaker
from money_machine import MoneyMachine

menu = Menu()
coffee_maker = CoffeeMaker()
money_machine = MoneyMachine()

machine_on = True

while machine_on:
    print(menu.get_items())
    user_choice = input("What would you like?").lower()

    if user_choice == "report":
        coffee_maker.report()
        print("<---------------->")
        money_machine.report()
    elif user_choice == "off":
        machine_on = False
    elif menu.find_drink(user_choice):
        drink = menu.find_drink(user_choice)
        if coffee_maker.is_resource_sufficient(drink):
            is_paid = money_machine.make_payment(drink.cost)
            if is_paid:
                coffee_maker.make_coffee(drink)

