import glob
from bs4 import BeautifulSoup
import json
import os

with open("data/squads.json", "w") as squads_file:
    for dir in os.listdir("data/raw/tournaments"):
        if os.path.isdir(f"data/raw/tournaments/{dir}"):
            print(dir)
            for file in glob.glob(f"data/raw/tournaments/{dir}/*.html"):
                print(file)
                team_id = file.split("/")[-1].replace(".html", "")
                squad_json = {"shortName": dir, "year": int(dir[-4:]), "teamId": team_id, "players": []}
                with open(file, "r") as fh:
                    soup = BeautifulSoup(fh.read(), "html.parser")
                    for player in soup.select("div.p-list div.p-i-no"):
                        player_id = player["data-player-id"]
                        name = player["data-player-name"]
                        role = player.get("data-player-role", "")

                        dob = player.select("div.p-ag span")[0].get("data-birthdate", "")

                        print(player_id, name, role, dob)
                        squad_json["players"].append({"id": player_id, "name": name, "role": role, "dob": dob})
                        # tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
                squads_file.write(f"{json.dumps(squad_json)}\n")
