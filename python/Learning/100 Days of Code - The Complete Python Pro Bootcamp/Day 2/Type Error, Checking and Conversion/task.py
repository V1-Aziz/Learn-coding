#Fixing Len function
from typing import LiteralString

print(len("12345"))

#Type Checking
name = "aziz"
num = 123
num2=1.23
married= False
print(type(name),type(num),type(num2),type(married))

print("Number of letters in your name: " + str(len(input("Enter your name"))))