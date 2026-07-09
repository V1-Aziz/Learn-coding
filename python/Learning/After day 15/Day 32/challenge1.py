# import smtplib


    

# import datetime as dt

# now = dt.datetime.now()

# year = now.year
# month = now.month
# day = now.day
# day_week = now.weekday()

# dob = dt.datetime(year = 2003, month=11, day=8, hour=12)
# print(dob)


import smtplib
import random
import datetime as dt
import os

with open("quotes.txt", "r") as file:
    #Random Lines from txt file
    lines = file.read().splitlines()
    random_line = random.choice(lines)
    print(random_line)
    #Specify a day
    now = dt.datetime.now()
    day = now.weekday()
    print(day)
    #Sending an email
    my_email = os.environ.get("EMAIL")
    my_pass = os.environ.get("PASSWORD")
    if day == 0:
        with smtplib.SMTP("smtp.gmail.com") as connection:
            connection.starttls()
            connection.login(user= my_email, password=my_pass)
            connection.sendmail(from_addr=my_email, to_addrs="viral4a2@gmail.com", msg=f"Subject:Today's quote \n\n {random_line}")