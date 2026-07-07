from art import logo

def add(n1, n2):
    return n1 + n2

def subtract(n1, n2):
    return n1 - n2

def multiply(n1, n2):
    return n1 * n2

def divide(n1, n2):
    return n1 / n2

operations = {
        "+":add,
        "-":subtract,
        "*":multiply,
        "/":divide
    }

def calculator():
    print(logo)
    should_accumulating = True
    first_number = float(input("Enter first number: "))

    while should_accumulating:
        for symbol in operations:
             print(symbol)
        operator_symbol = input("Pick and operation: ")
        second_second = float(input("Enter second number: "))
        answer = operations[operator_symbol](first_number, second_second)
        print(f"{first_number} {operator_symbol} {second_second} = {answer}")

        should_continue= input(f"Type 'y' to continue calculating with {answer}, or type 'n' to start new calculation")
        if should_continue == "y":
            first_number = answer
        else:
            should_accumulating = False
            print("\n"*20)
            calculator()
calculator()