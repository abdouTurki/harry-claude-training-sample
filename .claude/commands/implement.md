---
description: Dérouler le plan de la spec, en buildant/testant à chaque étape.
---
Implémente la story cadrée dans la dernière spec (`docs/features/*.md`).

Règles :
- Avance **step by step** ; après chaque étape backend, lance `pytest -q`.
- Après une étape frontend, lance `npm run build` pour vérifier que ça compile.
- Respecte les skills `python-api` et `react-ui`.
- Ne touche PAS à l'auth ni aux workflows CI/CD sans demande explicite.
- Commit par étape (Conventional Commits), jamais sur `main` (le hook le bloque de toute façon).

À la fin : résume les fichiers touchés et l'état des tests.
