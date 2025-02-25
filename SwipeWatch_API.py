import requests
import json

# Remplace par ta propre clé API
API_KEY = "b56548a8df08a342516316ebd40198ef"
BASE_URL = "https://api.themoviedb.org/3"


def fetch_movies():
    endpoint = f"{BASE_URL}/movie/popular"
    params = {"api_key": API_KEY, "language": "fr-FR", "page": 1}
    response = requests.get(endpoint, params=params)

    if response.status_code == 200:
        data = response.json()
        with open("swipewatch/assets/movies_dataset.json", "w", encoding="utf-8") as f:
            json.dump(data["results"], f, ensure_ascii=False, indent=4)
        print("Dataset enregistré dans 'movies_dataset.json'")
    else:
        print(f"Erreur : {response.status_code}, {response.text}")


if __name__ == "__main__":
    fetch_movies()
