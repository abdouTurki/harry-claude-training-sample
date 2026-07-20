---
description: Recette d'une story — tests back + build front + parcours UI.
---
Recette la story : $ARGUMENTS

1. **Backend** : `pytest -q` (tout doit passer).
2. **Frontend** : `npm run build` (compile sans erreur).
3. **Parcours UI** (via MCP Playwright, cf. `.mcp.json`) : ouvre l'app, crée une tâche,
   coche-la, supprime-la ; vérifie chaque critère d'acceptation de la spec.
4. Sur échec : décris l'étape KO (attendu vs observé) et joins une capture.

Pour une recette UI autonome et répétable, déléguer à l'agent `tester`.
