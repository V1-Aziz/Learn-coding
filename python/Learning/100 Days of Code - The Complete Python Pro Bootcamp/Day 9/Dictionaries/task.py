programming_dictionary = {"Bug": "An error in a program that prevents the program from running as expected.",
                          "Function": "A piece of code that you can easily call over and over again.",}
# print(programming_dictionary["Bug"])
programming_dictionary["Loop"] = "The action of doing something over and over again"
# # print(programming_dictionary["Loop"])
# # print(programming_dictionary)
# #
# programming_dictionary["Bug"] = "Something is bad"
# print(programming_dictionary["Bug"])

for thing in programming_dictionary:
    print(thing)
    print(programming_dictionary[thing])