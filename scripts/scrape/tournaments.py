import glob
from bs4 import BeautifulSoup
import json

with open("data/tournaments.json", "w") as tournaments_file:
    for file in glob.glob("data/raw/tournaments/*.html"):
        print(file)
        short_name = file.split("/")[-1].replace(".html", "")
        tournament_json = {"shortName": short_name, "year": int(short_name[-4:]), "teams": []}
        if "france2019" in file:
            with open(file, "r") as fh:
                soup = BeautifulSoup(fh.read(), "html.parser")
                name = list(soup.select("h1")[0].children)[0].replace("FIFA Women's World Cup ", "").replace("\u2122", "")
                tournament_json["name"] = name
                for team in soup.select("div.fi-teams-list a.fi-team-card"):
                    tournament_json["teams"].append({"team": team.select("div.fi-team-card__name")[0].text.strip(), "id": team["data-team"]})
            tournaments_file.write(f"{json.dumps(tournament_json)}\n")
        else:
            with open(file, "r") as fh:
                soup = BeautifulSoup(fh.read(), "html.parser")
                name = list(soup.select("h1 a")[0].children)[0].replace("FIFA Women's World Cup ", "").replace("\u00e2\u0084\u00a2", "")
                tournament_json["name"] = name
                for team in soup.select("div#qualifiedteamscontainer li a"):
                    tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
            tournaments_file.write(f"{json.dumps(tournament_json)}\n")
