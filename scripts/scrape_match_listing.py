import glob
from bs4 import BeautifulSoup
import json
import os
import requests

with open("data/matches.json", "w") as tournaments_file:
    for file in glob.glob("data/raw/matches/*.json"):
        with open(file, "r") as json_file:
            response = json_file.read()
            tournaments_file.write(f"{response}\n")
