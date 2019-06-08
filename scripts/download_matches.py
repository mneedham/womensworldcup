import glob
import json
import os
import requests
from bs4 import BeautifulSoup

for dir in os.listdir("data/raw/tournaments"):
    if os.path.isdir(f"data/raw/tournaments/{dir}"):
        print(dir)
        with open(f"data/raw/tournaments/{dir}/matches.html", "r") as fh:
            soup = BeautifulSoup(fh.read(), "html.parser")
            for match in soup.select("div.result"):
                match_id = match["data-id"]
                print(match_id)
                match_file = f"data/raw/matches/{match_id}.json"
                if not os.path.exists(match_file):
                    response = requests.get(f"https://api.fifa.com/api/v1/live/football/103/278513/278527/{match_id}")
                    if response.json():
                        with open(match_file, "w") as match_file_handle:
                            match_file_handle.write(json.dumps(response.json()))
