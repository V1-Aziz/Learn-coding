# '''First challenage'''
# list_of_strings = ['9', '0', '32', '8', '2', '8', '64', '29', '42', '99']
# numbers = [int(n) for n in list_of_strings]
# result = [n for n in numbers if n%2 == 0]
# print(result)

# '''Second challenge'''
# with open("file1.txt") as file1:
#     with open("file2.txt") as file2:
        
#         file1 = [n.strip() for n in file1]
#         str_to_int1 = [int(n) for n in file1]
#         print(str_to_int1)
#         file2 = [n.strip() for n in file2]
#         str_to_int2 = [int(n) for n in file2]
#         print(str_to_int2)


# result = [n for n in str_to_int1 if n in str_to_int2]
# print(result)
# '''This is third challenage'''
# import random

# names = ["Alex", "Beth", "Caroline", "Dave", "Eleanor", "Freddie"]

# students_score = {student:random.randint(1, 100) for student in names}
# # passed_student = {student:students_score[student] for student in names if (students_score[student]) >= 60}
# passed_students =  {student:score for (student, score) in students_score.items()if score >= 60}
# print(passed_students)

# sentence = "What is the Airspeed Velocity of an Unladen Swallow?"
# words = sentence.split()
# result = {words:len(words) for words in words}
# print(result)
# '''This is forth challnege'''
# weather_c = {"Monday": 12, "Tuesday": 14, "Wednesday": 15, "Thursday": 14, "Friday": 21, "Saturday": 22, "Sunday": 24}

# weather_f = {day:(temp * 9/5)+ 32 for (day, temp) in weather_c.items()}

# print(weather_f)
#
# """This is pandas task"""

# student_dict = {
#     "student": ["Angela", "James", "Lily"],
#     "score":[56, 67, 98]
# }

# for (key, value) in student_dict.items():
#     print(value)

# import pandas

# #Looping through dict
# student_data_frame = pandas.DataFrame(student_dict)
# print(student_data_frame)

# # #Loop through a data frame

# # for (key, value) in student_dict.items():
# #     print(value)

# for (index, row) in student_data_frame.iterrows():
#     if row.student == "Angela":
#         print(row.score)

# """Capstone"""

