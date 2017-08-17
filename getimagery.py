import os
import sys
import requests
from threading import Timer
import urllib

api_key = ""
if "PLANET_API_KEY" in os.environ:
	api_key = os.environ['PLANET_API_KEY']
else:
	api_key = "3e452f7b18c74bf98bab80fe667ff4cf"

asset_type = "analytic"
item_type = "PSOrthoTile"
item_id = ("671677_1153019_2017-08-06_1009", "671677_1153018_2017-08-06_1009", "671677_1153119_2017-08-06_1009", "671677_1153118_2017-08-06_1009")

# setup auth
session = requests.Session()
session.auth = (api_key, '')

url = "https://api.planet.com/data/v1/item-types/" + ("{}/items/{}/assets/").format(item_type, item_id)

def activate():
	# request an item
	item = session.get(url)

	# extract the activation url
	item_activation_url = item.json()[asset_type]["_links"]["activate"]

	# request activation
	response = session.post(item_activation_url)

	if response.ok:
		print("Requested activation.")
	else:
		print("Error with activation.")
		sys.exit(1)

def check_activation():
	item = session.get(url)
	response = item.json()[asset_type]
	status = response["status"]
	
	if status == "active":
		print("Activated.")
		img_url = response["location"]
		download(img_url)
	else:
		print("Waiting for activation.")
		Timer(20.0, check_activation).start()
	
def download(img_url):
	filename = item_id + ".tiff"
	urllib.request.urlretrieve(img_url, filename)
	print("Downloaded data.")
	
activate()
check_activation()
