import requests
import smtplib
import os
from datetime import datetime

MY_LAT = float(os.environ["MY_LAT"])   # Your latitude
MY_LONG = float(os.environ["MY_LONG"]) # Your longitude

EMAIL = os.environ["EMAIL"]
PASS = os.environ["EMAIL_PASS"]

response = requests.get(url="http://api.open-notify.org/iss-now.json")
response.raise_for_status()
data = response.json()

iss_latitude = float(data["iss_position"]["latitude"])
iss_longitude = float(data["iss_position"]["longitude"])

#Your position is within +5 or -5 degrees of the ISS position.
def is_iss_overhead():
    if MY_LAT+5 >= iss_latitude and MY_LAT-5 <=iss_latitude:
        if MY_LONG+5 >= iss_longitude and MY_LONG-5 <= iss_longitude:
            return True
        else: return False
    else:
        return False 

parameters = {
    "lat": MY_LAT,
    "lng": MY_LONG,
    "formatted": 0,
}

response = requests.get("https://api.sunrise-sunset.org/json", params=parameters)
response.raise_for_status()
data = response.json()
sunrise = int(data["results"]["sunrise"].split("T")[1].split(":")[0])
sunset = int(data["results"]["sunset"].split("T")[1].split(":")[0])

print(sunrise)
print(sunset)
time_now = datetime.now()
print(time_now)
#If the ISS is close to my current position DONE
# and it is currently dark
def is_it_dark():
        return time_now.hour >= sunset or time_now.hour < sunrise
if is_it_dark() and is_iss_overhead():
     with smtplib.SMTP("smtp.gmail.com") as connection:
            connection.starttls()
            connection.login(user= EMAIL, password=PASS)
            connection.sendmail(from_addr=EMAIL, to_addrs="your@email.com", msg=f"Subject:ISS OVERHEAD\n\n Internationa spaceship is above you, go outside and take a look")
# Then send me an email to tell me to look up.
# BONUS: run the code every 60 seconds.



