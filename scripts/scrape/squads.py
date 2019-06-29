import glob
from bs4 import BeautifulSoup
import json
import os

combined_squads = []

with open("data/squads.json", "w") as squads_file:
    for dir in os.listdir("data/raw/tournaments"):
        if os.path.isdir(f"data/raw/tournaments/{dir}"):
            print(dir)
            for file in glob.glob(f"data/raw/tournaments/{dir}/squads/*.html"):
                print(file)
                team_id = file.split("/")[-1].replace(".html", "")
                squad_json = {"shortName": dir, "year": int(dir[-4:]), "teamId": team_id, "players": []}
                if "france2019" in file:
                    with open(file, "r") as fh:
                        soup = BeautifulSoup(fh.read(), "html.parser")
                        for player in soup.select("div.fi-team__members div.fi-p"):
                            player_element = player.select("div.fi-p__n a")[0]
                            player_id = player_element["href"].split("/")[-2].strip()
                            name = player_element["title"].title()
                            role = "0" if "coach" in player_element["href"] else player["data-member-pos"]
                            dob = ""
                            print(player_id, name, role, dob)
                            squad_json["players"].append({"id": player_id, "name": name, "role": role, "dob": dob})
                            # tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
                    combined_squads.append(squad_json)

                else:
                    with open(file, "r") as fh:
                        soup = BeautifulSoup(fh.read(), "html.parser")
                        for player in soup.select("div.p-list div.p-i-no"):
                            player_id = player["data-player-id"]
                            name = player["data-player-name"].title()
                            role = player.get("data-player-role", "")

                            dob = player.select("div.p-ag span")[0].get("data-birthdate", "")

                            print(player_id, name, role, dob)
                            squad_json["players"].append({"id": player_id, "name": name, "role": role, "dob": dob})
                            # tournament_json["teams"].append({"team": team.text, "id": team["href"].split("/")[-2].replace("team=", "")})
                    combined_squads.append(squad_json)
    squads_file.write(f"{json.dumps(combined_squads)}")