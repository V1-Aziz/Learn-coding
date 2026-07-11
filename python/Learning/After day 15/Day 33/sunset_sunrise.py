import requests
import os

MY_LAT = float(os.environ["MY_LAT"])   # Your latitude
MY_LONG = float(os.environ["MY_LONG"]) # Your longitude

parametter ={
    "lat":MY_LAT,
    "lng":MY_LONG,
    "formatted":0,
    "tzid":"Asia/Riyadh"
}

response = requests.get(url="https://api.sunrise-sunset.org/json", params=parametter)
response.raise_for_status()
data = response.json()
sunrise = data["results"]["sunrise"].split("T")
sunset = data["results"]["sunset"].split("T")

print(sunrise)
print(sunset)

import datetime

print(datetime.datetime.now())
