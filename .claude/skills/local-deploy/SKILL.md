---
name: local-deploy
description: Déploiement LOCAL sur le même host via docker compose (build + up + health + rollback). À charger par l'agent deployer pour tout tester en local, sans VM.
---
# Déploiement local (docker compose, même host)

> Variante « tout-en-local » de `docker-deploy` : aucune VM, aucun registre distant.
> On construit et on lance la stack sur la machine courante. Idéal pour la formation
> et pour recetter une feature de bout en bout avant un vrai déploiement.

## Déployer (ou redéployer) en local

```bash
# Depuis la racine du repo
docker compose up -d --build          # build les images + (re)lance en arrière-plan
docker compose ps                     # front sur :8080, backend sur :8000
```

Le `--build` reconstruit les images modifiées ; `up -d` remplace les conteneurs en place
(redéploiement sans downtime perceptible sur une app de cette taille).

## Vérifier la santé

```bash
curl -fs http://localhost:8000/health           # attendu : {"status":"ok"}
curl -fs -o /dev/null -w "%{http_code}" http://localhost:8080   # attendu : 200 (front servi)
```

Si l'un échoue : `docker compose logs --tail=50 backend` / `frontend` pour diagnostiquer.

## Rollback local

Le tag précédent est toujours dans le cache d'images Docker :

```bash
docker image ls '*/todo-backend' '*/todo-frontend'   # repérer le tag précédent
git checkout <commit-précédent> -- .                 # revenir au code précédent
docker compose up -d --build                         # relancer dessus
```

## Arrêter

```bash
docker compose down                 # stoppe et retire les conteneurs (garde le volume de données)
docker compose down -v              # + supprime le volume SQLite (reset complet)
```

## Garde-fous
- Ne jamais committer de secret : la config passe par variables d'env / `.env` (git-ignoré).
- Vérifier `/health` après chaque déploiement avant de rendre la main.
