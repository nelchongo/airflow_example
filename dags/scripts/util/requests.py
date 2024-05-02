import requests
import time

class requests_class:
    main_url = ""

    def __init__(self, main_url:str):
        self.main_url = main_url

    def iter_get_response(self, df, field:str = ""):
        get_url = df[field]
        return self.get_response(get_url = get_url)

    def get_response(self, url:str = "", get_url = "", repetition = 0):
        if get_url == "":
            get_url = f"{self.main_url}{url}"

        print(f"Making get request to: {get_url}")
        r = requests.get(get_url)
        if r.status_code == 200:
            return r.json()
        else:
            if repetition == 4:
                print(f"Error making a request to: {get_url}, response code: {r.status_code} ----> Couldn't handle repetition")
                return 'error'
            else: 
                print(f"Error making a request to: {get_url}, response code: {r.status_code}")
                print("Retrying again...")
                time.sleep(5)
                return self.get_response(url = url, get_url = get_url, repetition = repetition + 1)