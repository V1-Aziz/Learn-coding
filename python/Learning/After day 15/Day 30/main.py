# try:
#     file = open("a.txt")
#     dict = {"key": "value"}
#     print(dict["dsad"])
# except FileNotFoundError:
#     file = open("a.txt", "w")
#     file.write("Something")
# except KeyError as error_message:
#     print(f"The key {error_message} does not exist")
# else:
#     content = file.read()
#     print(content)
# finally:
#     file.close()
#     print("File was closed.")

# height = float(input("What is your height"))
# weight = int(input("Weight"))

# if height>3:
#     raise ValueError("Human height should not be over 3 meters.")

# bmi = weight/height**2
# print(bmi)

facebook_posts = [
    {'Likes': 21, 'Comments': 2},
    {'Likes': 13, 'Comments': 2, 'Shares': 1},
    {'Likes': 33, 'Comments': 8, 'Shares': 3},
    {'Comments': 4, 'Shares': 2},
    {'Comments': 1, 'Shares': 1},
    {'Likes': 19, 'Comments': 3}
]

def count_likes(posts):
    total_likes = 0
    for post in posts:
        try:
            total_likes = total_likes + post['Likes']
        except KeyError:
            pass
    return total_likes

print(count_likes(facebook_posts))
