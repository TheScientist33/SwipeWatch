import requests
import pandas as pd
from termcolor import colored

# Votre clé API TMDb
API_KEY = "b56548a8df08a342516316ebd40198ef"
BASE_URL = "https://api.themoviedb.org/3"

# Fonction pour rechercher des films ou séries
def search_tmdb(query, content_type="movie"):
    """
    Recherche un film ou une série sur TMDb.
    :param query: Titre recherché
    :param content_type: "movie" pour films ou "tv" pour séries
    :return: Liste des résultats
    """
    endpoint = f"{BASE_URL}/search/{content_type}"
    params = {"api_key": API_KEY, "query": query}
    response = requests.get(endpoint, params=params)

    if response.status_code == 200:
        data = response.json()
        return data.get("results", [])
    else:
        print(colored("Erreur lors de la connexion à l'API TMDb.", "red"))
        return []

# Fonction pour afficher les détails d'un contenu
def get_details(content_id, content_type="movie"):
    """
    Récupère les détails d'un film ou d'une série.
    :param content_id: ID TMDb du contenu
    :param content_type: "movie" pour films ou "tv" pour séries
    :return: Détails du contenu
    """
    endpoint = f"{BASE_URL}/{content_type}/{content_id}"
    params = {"api_key": API_KEY}
    response = requests.get(endpoint, params=params)

    if response.status_code == 200:
        return response.json()
    else:
        print(colored("Impossible de récupérer les détails.", "red"))
        return {}

# Fonction principale pour le moteur de recommandation
def swipe_watch():
    print(colored("Bienvenue dans SwipeWatch !", "green"))
    query = input("Recherchez un film ou une série : ")
    results = search_tmdb(query)

    if results:
        print(colored(f"Résultats pour '{query}' :", "cyan"))
        for idx, item in enumerate(results[:5], 1):
            title = item.get("title") or item.get("name")
            overview = item.get("overview", "Pas de description disponible.")
            print(f"{idx}. {title} : {overview[:100]}...")

        choice = input("Entrez le numéro d'un contenu pour voir les détails ou appuyez sur Entrée pour quitter : ")
        if choice.isdigit() and 1 <= int(choice) <= len(results[:5]):
            content_id = results[int(choice) - 1]["id"]
            content_type = "movie" if "title" in results[int(choice) - 1] else "tv"
            details = get_details(content_id, content_type)

            print(colored("Détails :", "yellow"))
            print(f"Titre : {details.get('title') or details.get('name')}")
            print(f"Date de sortie : {details.get('release_date') or details.get('first_air_date')}")
            print(f"Note moyenne : {details.get('vote_average')}/10")
            print(f"Résumé : {details.get('overview')}")
        else:
            print(colored("Merci d'avoir utilisé SwipeWatch !", "green"))
    else:
        print(colored("Aucun résultat trouvé.", "red"))

# Lancer le programme
if __name__ == "__main__":
    swipe_watch()
