---
description: Spec fonctionnelle + plan technique + invariants d'une story. Ne code pas.
---
Produis la spec de la story : $ARGUMENTS

1. **Critères d'acceptation** (Given / When / Then).
2. **Plan d'implémentation** :
   - Backend : respect de la skill `python-api` (controller mince, Pydantic, test pytest).
   - Frontend : respect de la skill `react-ui` (appel via `src/api.js`, état local, a11y).
3. **Invariants vérifiables sur un diff** (checklist que l'agent `reviewer` appliquera) :
   ex. « aucun secret en clair », « endpoint couvert par un test », « pas de fetch direct hors api.js ».

NE CODE PAS. Écris la spec sous `docs/features/<slug>.md`.
