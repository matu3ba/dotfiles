# uv tool install beautifulsoup4
# python ./scr/extract_link.py
import requests
from bs4 import BeautifulSoup

url = 'https://matu3ba.github.io'
grab = requests.get(url)
soup = BeautifulSoup(grab.text, 'html.parser')

for link in soup.find_all("a"):
  data = link.get('href')
  if "#" not in data:
    urllink = url + data
    print(urllink)
