---
name: python-api
description: Conventions FastAPI de ce repo. À charger pour créer/modifier un endpoint ou l'agent reviewer.
---
# Conventions API (FastAPI)

1. **Controller mince** : le router (`app/routers/`) ne contient pas de logique métier
   complexe ; il valide, appelle la base, mappe le résultat.
2. **Contrat via Pydantic** : toute entrée/sortie passe par un modèle de `app/models.py`.
   Ne jamais renvoyer directement une `Row` SQLite.
3. **Accès données** : passer par `app/database.py` (`get_conn()` en context manager,
   commit auto). Pas de connexion SQLite ouverte à la main dans un router.
4. **Erreurs** : lever `HTTPException(status_code=..., detail=...)` — pas de try/except
   qui avale l'erreur.
5. **Codes HTTP** : 201 à la création, 204 à la suppression, 404 si ressource absente.
6. **Tests** : tout endpoint est couvert par un test dans `backend/tests/` (TestClient +
   base SQLite jetable). `pytest -q` doit passer.
7. **Secrets** : jamais en clair, jamais loggés. Config via variables d'environnement.
