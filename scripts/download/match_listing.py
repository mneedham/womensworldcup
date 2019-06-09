import requests
import os

tournaments = [
    "canada2015",
    "germany2011",
    "china2007",
    "usa2003",
    "usa1999",
    "sweden1995",
    "chinapr1991",
]

for tournament in tournaments:
    location = f"data/raw/tournaments/{tournament}/matches.html"
    if not os.path.exists(location):
        response = requests.get(f"https://www.fifa.com/womensworldcup/archive/{tournament}/matches/index.html")
        with open(location, "w") as tournament_file:
            tournament_file.write(response.text)

with open("data/raw/tournaments/france2019/matches.html", "w") as tournament_file:
    response = requests.get("https://www.fifa.com/womensworldcup/matches/")
    tournament_file.write(response.text)
