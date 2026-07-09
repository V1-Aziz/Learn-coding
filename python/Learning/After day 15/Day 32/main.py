##################### Extra Hard Starting Project ######################
import datetime as dt
import pandas
import random
import smtplib
import os

EMAIL = os.environ.get("EMAIL")
PASSWORD = os.environ.get("PASSWORD")
# 1. Update the birthdays.csv
#--------------------- DATE FILE ---------------------#
data = pandas.read_csv("birthdays.csv")

person = { (row.month, row.day):(row["name"], row["email"], row["month"], row["day"]) for (index, row) in data.iterrows()}
#--------------------- DATE ---------------------#
now = dt.datetime.now()
month = now.month
day = now.day
today = (month, day)


# 2. Check if today matches a birthday in the birthdays.csv
if today in person:
    birthday_person = person[today]
    person_email = birthday_person[1]
# 3. If step 2 is true, pick a random letter from letter templates and replace the [NAME] with the person's actual name from birthdays.csv
    num = random.randint(1,3)
    with open(f"letter_templates/letter_{num}.txt", "r", encoding="UTF-8") as file:
        msg = file.read().replace("[NAME]", birthday_person[0])
        with smtplib.SMTP("smtp.gmail.com") as connection:
            connection.starttls()
            connection.login(user= EMAIL, password=PASSWORD)
            connection.sendmail(from_addr=EMAIL, to_addrs=person_email, msg=f"Subject:Happy Birthday!! \n\n {msg}")
else:
    print("No one in the file has birthday today")
# 4. Send the letter generated in step 3 to that person's email address.

