import glob
from bs4 import BeautifulSoup
import json

tournaments = {
    "canada2015": "266030",
    "germany2011": "251475",
    "china2007": "10232",
    "usa2003": "6929",
    "usa1999": "4644",
    "sweden1995": "4654",
    "chinapr1991": "3373",
    "france2019": "278513"
}

combined_tournaments = []
with open("data/tournaments.json", "w") as tournaments_file:
    for file in glob.glob("data/raw/tournaments/*.html"):
        print(file)
        short_name = file.split("/")[-1].replace(".html", "")
        tournament_json = {"id": tournaments[short_name], "shortName": short_name, "year": int(short_name[-4:]), "teams": []}
        if "france2019" in file:
            with open(file, "r") as fh:
                soup = BeautifulSoup(fh.read(), "html.parser")
                name = list(soup.select("h1")[0].children)[0].replace("FIFA Women's World Cup ", "").replace("\u2122", "")
                tournament_json["name"] = name
                for team in soup.select("div.fi-teams-list a.fi-team-card"):
                    tournament_json["teams"].append({"team": team.select("div.fi-team-card__name")[0].text.strip(), "id": team["data-team"]})
            combined_tournaments.append(tournament_json)
        else:
            with open(file, "r") as fh:
                soup = BeautifulSoup(fh.read(), "html.parser")
                name = list(soup.select("h1 a")[0].children)[0].replace("FIFA Women's World Cup ", "").replace("\u00e2\u0084\u00a2", "")
                tournament_json["name"] = name
                for team in soup.select("div#qualifiedteamscontainer li a"):
                    tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
            combined_tournaments.append(tournament_json)
    tournaments_file.write(f"{json.dumps(combined_tournaments)}")