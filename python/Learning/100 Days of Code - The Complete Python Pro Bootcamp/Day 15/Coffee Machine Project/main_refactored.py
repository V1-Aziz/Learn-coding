MENU = {
    "espresso": {
        "ingredients": {
            "water": 50,
            "coffee": 18,
        },
        "cost": 1.5,
    },
    "latte": {
        "ingredients": {
            "water": 200,
            "milk": 150,
            "coffee": 24,
        },
        "cost": 2.5,
    },
    "cappuccino": {
        "ingredients": {
            "water": 250,
            "milk": 100,
            "coffee": 24,
        },
        "cost": 3.0,
    }
}

resources = {
    "water": 300,
    "milk": 200,
    "coffee": 100,
    "money": 0
}


def print_report():
    print(f"Water: {resources['water']}ml")
    print(f"Milk: {resources['milk']}ml")
    print(f"Coffee: {resources['coffee']}g")
    print(f"Money: ${resources['money']}")


def check_resources(ingredients):
    if ingredients["water"] > resources["water"]:
        print("Sorry there is not enough water.")
        return False
    if ingredients["coffee"] > resources["coffee"]:
        print("Sorry there is not enough coffee.")
        return False
    if "milk" in ingredients and ingredients["milk"] > resources["milk"]:
        print("Sorry there is not enough milk.")
        return False
    return True


def process_coins():
    print("Please insert coins.")
    quarter = int(input("How many quarters?: "))
    dime = int(input("How many dimes?: "))
    nickel = int(input("How many nickels?: "))
    penny = int(input("How many pennies?: "))
    return quarter * 0.25 + dime * 0.10 + nickel * 0.05 + penny * 0.01


def check_transaction(total, cost):
    if total < cost:
        print("Sorry that's not enough money. Money refunded.")
        return False
    if total > cost:
        change = round(total - cost, 2)
        print(f"Here is ${change} dollars in change.")
    return True


def make_coffee(drink, ingredients, cost):
    resources["water"] -= ingredients["water"]
    resources["coffee"] -= ingredients["coffee"]
    if "milk" in ingredients:
        resources["milk"] -= ingredients["milk"]
    resources["money"] += cost
    print(f"Here is your {drink}. Enjoy!")


machine_on = True
while machine_on:
    user_choice = input("What would you like? (espresso/latte/cappuccino): ")

    if user_choice == "off":
        machine_on = False
    elif user_choice == "report":
        print_report()
    elif user_choice in MENU:
        drink = MENU[user_choice]
        ingredients = drink["ingredients"]
        cost = drink["cost"]
        if check_resources(ingredients):
            total = process_coins()
            if check_transaction(total, cost):
                make_coffee(user_choice, ingredients, cost)
