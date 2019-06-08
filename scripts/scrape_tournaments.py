import glob
from bs4 import BeautifulSoup
import json

with open("data/tournaments.json", "w") as tournaments_file:
    for file in glob.glob("data/raw/tournaments/*.html"):
        print(file)
        short_name = file.split("/")[-1].replace(".html", "")
        tournament_json = {"shortName": short_name, "year": int(short_name[-4:]), "teams": []}

        with open(file, "r") as fh:
            soup = BeautifulSoup(fh.read(), "html.parser")
            for team in soup.select("div#qualifiedteamscontainer li a"):
                print(team)
                tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
        tournaments_file.write(f"{json.dumps(tournament_json)}\n")
