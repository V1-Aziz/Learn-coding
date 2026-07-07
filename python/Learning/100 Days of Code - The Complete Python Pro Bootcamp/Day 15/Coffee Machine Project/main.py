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
machine_on = True
drink_selected = False
while machine_on:
    user_choice = input("What would you like?")
    #This is espresso
    if user_choice == "espresso":
        ingredients = MENU["espresso"]["ingredients"]
        cost = MENU["espresso"]["cost"]
        #Resource check
        if ingredients["water"] > resources["water"]:
            print("Sorry, there's not enough water")
            continue
        if ingredients["coffee"] > resources["coffee"]:
            print("Sorry, there's not enough coffee")
            continue
        drink_selected = True
    #This is latte
    elif user_choice == "latte":
        ingredients = MENU["latte"]["ingredients"]
        cost = MENU["latte"]["cost"]
        #Resource
        if ingredients["water"] > resources["water"]:
            print("Sorry, there's not enough water")
            continue
        if ingredients["coffee"] > resources["coffee"]:
            print("Sorry, there's not enough coffee")
            continue
        if ingredients["milk"] > resources["milk"]:
            print("Sorry, there's not enough milk")
            continue
        drink_selected = True
    #this is cappuccino
    elif user_choice == "cappuccino":
        ingredients = MENU["cappuccino"]["ingredients"]
        cost = MENU["cappuccino"]["cost"]
        #Resource check
        if ingredients["water"] > resources["water"]:
            print("Sorry, there's not enough water")
            continue
        if ingredients["coffee"] > resources["coffee"]:
            print("Sorry, there's not enough coffee")
            continue
        if ingredients["milk"] > resources["milk"]:
            print("Sorry, there's not enough milk")
            continue
        drink_selected = True
    elif user_choice == "off":
        machine_on = False
    elif user_choice == "report":
        milk = resources["milk"]
        water = resources["water"]
        coffee = resources["coffee"]
        money = resources["money"]
        print(f"Milk: {milk}ml")
        print(f"Water: {water}ml")
        print(f"Coffee: {coffee}g")
        print(f"Money: ${money}")

    if drink_selected:
        quarter = int(input("Quarter:"))
        dime = int(input("Dime:"))
        nickel = int(input("Nickel:"))
        penny = int(input("Penny:"))
        total = quarter*0.25 + dime*0.10 + nickel*0.05 + penny*0.01
        change = round(total - cost, 2)
        drink_selected = False
        if total == cost:
            print(f"Here's your {user_choice}!")
            resources["money"] += cost
            resources["water"] -= ingredients["water"]
            resources["coffee"] -= ingredients["coffee"]
            if "milk" in ingredients:
                resources["milk"] -= ingredients["milk"]
            continue
        elif total > cost:
            print(f"here's your {user_choice}!")
            print(f"Here is ${change} dollars in change")
            resources["money"] += cost
            resources["water"] -= ingredients["water"]
            resources["coffee"] -= ingredients["coffee"]
            if "milk" in ingredients:
                resources["milk"] -= ingredients["milk"]
            continue
        else:
            print("Sorry that's not enough money. Money refunded")
            continue