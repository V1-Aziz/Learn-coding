import requests
import csv

API_KEY = "STEAM_API"
STEAM_ID = "STEAM_ID"

url = "https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/"
params = {
    "key": API_KEY,
    "steamid": STEAM_ID,
    "include_appinfo": True,
    "include_played_free_games": True,
    "format": "json"
}

data = requests.get(url, params=params).json()
games = data["response"]["games"]

with open("V1_steam_backlog.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Name", "AppID", "Playtime (hrs)", "Status"])
    for g in sorted(games, key=lambda x: x["name"].lower()):
        hours = round(g["playtime_forever"] / 60, 1)
        status = "Unplayed" if hours == 0 else "Played"
        writer.writerow([g["name"], g["appid"], hours, status])

print(f"Exported {len(games)} games to steam_backlog.csv")