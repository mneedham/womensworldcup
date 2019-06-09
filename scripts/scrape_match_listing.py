import glob
from bs4 import BeautifulSoup
import json
from dateutil import parser

def extract_goals(soup, top_level_selector):
    goals = []
    for item in soup.select(f"{top_level_selector} ul.mh-l-scorers li.mh-scorer"):
        player_id = item.select("div.p-i-no")[0]["data-player-id"]
        for goal_element in item.select("span.ml-scorer-evmin span"):
            if not "OG" in goal_element.text:
                minute = goal_element.text.replace("PEN", "").strip()
                goals.append({"IdPlayer": player_id, "Minute": minute})
    return goals

def extract_json(file):
    document = {"SeasonShortName": [{"Description": "China 2007"}]}
    with open(file, "r") as html_file:
        soup = BeautifulSoup(html_file.read(), "html.parser")
        document["IdMatch"] = soup.select("div.mh.result")[0]["data-id"]
        document["StageName"] = [{"Description": soup.select("div.mh-i-round")[0].text}]
        document["Date"] = parser.parse(soup.select("table.match-data td")[0].text).strftime("%Y-%m-%d")
        document["HomeTeam"] = {
            "IdTeam": soup.select("div.home")[0]["data-team-id"],
            "Score": int(soup.select("div.s-score span.s-scoreText")[0].text.split("-")[0]),
            "Goals": extract_goals(soup, "div.t-scorer.home"),
            "Players": [ {"IdPlayer": item["data-player-id"], "Status": 1 } for item in soup.select("table.fielded td.home div.p-i-no")]
        }
        document["AwayTeam"] = {
            "IdTeam": soup.select("div.away")[0]["data-team-id"],
            "Score": int(soup.select("div.s-score span.s-scoreText")[0].text.split("-")[1]),
            "Goals": extract_goals(soup, "div.t-scorer.away"),
            "Players": [ {"IdPlayer": item["data-player-id"], "Status": 1 } for item in soup.select("table.fielded td.away div.p-i-no")]
        }
    return document

with open("data/matches.json", "w") as tournaments_file:
    for file in glob.glob("data/raw/matches/*.json"):
        with open(file, "r") as json_file:
            response = json_file.read()
            tournaments_file.write(f"{response}\n")

    for file in glob.glob("data/raw/matches/*.html"):
        print(file)
        document = extract_json(file)
        tournaments_file.write(f"{json.dumps(document)}\n")
