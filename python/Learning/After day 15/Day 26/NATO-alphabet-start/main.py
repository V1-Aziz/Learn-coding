student_dict = {
    "student": ["Angela", "James", "Lily"], 
    "score": [56, 76, 98]
}

#Looping through dictionaries:
for (key, value) in student_dict.items():
    #Access key and value
    pass

import pandas
student_data_frame = pandas.DataFrame(student_dict)

#Loop through rows of a data frame
for (index, row) in student_data_frame.iterrows():
    #Access index and row
    #Access row.student or row.score
    pass

# Keyword Method with iterrows()
# {new_key:new_value for (index, row) in df.iterrows()}

#TODO 1. Create a dictionary in this format:
letter_code = pandas.read_csv("nato_phonetic_alphabet.csv")

{"A": "Alfa", "B": "Bravo"}

l_c_dict = {row.letter:row.code for (index,row) in letter_code.iterrows()}
print(l_c_dict)
#TODO 2. Create a list of the phonetic code words from a word that the user inputs.
user_input = input("User name: ")

name_letter_code = [l_c_dict[letter.upper()] for letter in user_input]

print(name_letter_code)