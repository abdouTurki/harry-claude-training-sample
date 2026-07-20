# CLAUDE.md — Todo app (support de formation Claude Code)

> Repo **pédagogique** : une petite app todo (React + FastAPI, Docker, GitHub Actions) dont le
> vrai sujet est le dossier [`.claude/`](.claude/) — un exemple **complet et runnable** de harness
> Claude Code cité par la fiche « Prise en main de Claude ».

## Architecture

- **backend/** — API FastAPI (Python 3.12), persistance SQLite. Endpoints CRUD `/todos`, `/health`.
- **frontend/** — SPA React (Vite), servie par nginx. Appels API centralisés dans `src/api.js`.
- **docker-compose.yml** — lance front (:8080) + back (:8000).
- **.github/workflows/** — `ci.yml` (tests+build sur PR) · `deploy.yml` (build→GHCR→VM, **illustratif**).

## Conventions (voir les skills)

- Backend → [`.claude/skills/python-api`](.claude/skills/python-api/SKILL.md) : controller mince,
  DTO Pydantic, erreurs via `HTTPException`, tout endpoint testé (`pytest -q`).
- Frontend → [`.claude/skills/react-ui`](.claude/skills/react-ui/SKILL.md) : `fetch` uniquement dans
  `src/api.js`, URL via `VITE_API_URL`, a11y.
- Déploiement → [`.claude/skills/docker-deploy`](.claude/skills/docker-deploy/SKILL.md).

## Cycle de travail

`/scope <idée>` → `/spec <story>` → `/implement` → `/test` → agent `reviewer` → agent `deployer`.
Recette UI autonome : agent `tester` (via MCP Playwright).

## Garde-fous

- **Secrets** : jamais en clair, jamais loggés ; via variables d'env / GitHub Secrets.
- **Branches protégées** : un hook `PreToolUse` ([`.claude/hooks/block-protected-branch.sh`](.claude/hooks/block-protected-branch.sh))
  **bloque** tout `git push` vers `main`/`master`/`production`. On passe par une PR.
- **Commits** : Conventional Commits. Ne pas modifier l'auth ni les workflows sans demande explicite.

## Lancer en local

```bash
docker compose up --build      # front http://localhost:8080 · API http://localhost:8000/docs
cd backend && pip install -r requirements.txt && pytest -q
cd frontend && npm install && npm run dev
```
