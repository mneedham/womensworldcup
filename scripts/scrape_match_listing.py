import glob
from bs4 import BeautifulSoup
import json
import os
import requests

with open("data/matches.json", "w") as tournaments_file:
    for dir in os.listdir("data/raw/tournaments"):
        if os.path.isdir(f"data/raw/tournaments/{dir}"):
            print(dir)
            with open(f"data/raw/tournaments/{dir}/matches.html", "r") as fh:
                soup = BeautifulSoup(fh.read(), "html.parser")
                for match in soup.select("div.result"):
                    match_id = match["data-id"]
                    print(match_id)
                    response = requests.get(f"https://api.fifa.com/api/v1/live/football/103/278513/278527/{match_id}")
                    if response.json():
                        tournaments_file.write(f"{json.dumps(response.json())}\n")
