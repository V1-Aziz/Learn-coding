# enemies = 1
#
#
# def increase_enemies():
#     enemies = 2
#     print(f"enemies inside function: {enemies}")
#
#
# increase_enemies()
# print(f"enemies outside function: {enemies}")
#
#

#global scope

player_hp = 10
def game ():
    def drink_potion():
        potion_strength = 2
        print(potion_strength)
        print(player_hp)
    drink_potion()
print(player_hp)