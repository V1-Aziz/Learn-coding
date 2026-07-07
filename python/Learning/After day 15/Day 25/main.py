# import pandas 

# data = pandas.read_csv("weather_data.csv")
# # print(type(data))
# # print(type(data["temp"]))

# # data_dict = data.to_dict()
# # print(data_dict)
# # temp_list = data["temp"].to_list()

# # print(data["temp"].mean())
# # print(data["temp"].max())

# # print(data["condition"])
# # print(data.condition)

# # print(data[data.day == "Monday"])

# # print(data[data.temp == data.temp.max()])

# # day = data[data.day == "Monday"]
# # day_temp = day.temp[0]
# # temp_from_c_to_f = (day_temp * 9/5) + 32
# # print(temp_from_c_to_f)

# #Create data frame from scratch

# data_dict = {
#     "studants": ["Amy", "James","Angela"],
#     "scores": [76, 56, 65]
# }

# data = pandas.DataFrame(data_dict)
# data.to_csv("data.csv")


import pandas

data = pandas.read_csv("2018_Central_Park_Squirrel_Census_-_Squirrel_Data.csv")


#claude code solution (Successful)

# count = data["Primary Fur Color"].value_counts()

# print(data["Primary Fur Color"].unique())
# print(data["Primary Fur Color"].value_counts())

#course solution
#use len method to know the count for each color.
gray_squirrels_count = len(data[data["Primary Fur Color"] == "Gray"])
cinnamon_squirrels_count = len(data[data["Primary Fur Color"] == "Cinnamon"])
Black_squirrels_count = len(data[data["Primary Fur Color"] == "Black"])

data = {
    "Fur Color": ["Gray", "Cinnamon", "Black"],
    "Count": [gray_squirrels_count, cinnamon_squirrels_count, Black_squirrels_count]
}

data = pandas.DataFrame(data)

print(data)

data.to_csv("new_data.csv")