# Feature — Filtre des tâches (Toutes / Actives / Terminées)

> Produit par `/scope` puis `/spec`. Story : `TODO-1`.

## /scope — mini-PRD

- **Problème** : quand la liste grossit, l'utilisateur ne voit plus vite ce qui reste à faire.
- **Périmètre inclus** : filtrer la liste par état (toutes / actives / terminées).
- **Exclu** : recherche texte, tri, pagination (hors sujet ici).
- **Stories** : `TODO-1` — filtrer les tâches (back : filtre API ; front : 3 boutons).

## /spec — critères d'acceptation

- **CA1** : `GET /todos` sans paramètre renvoie toutes les tâches (comportement inchangé).
- **CA2** : `GET /todos?done=false` renvoie uniquement les tâches non terminées.
- **CA3** : `GET /todos?done=true` renvoie uniquement les tâches terminées.
- **CA4** : l'UI affiche 3 boutons « Toutes / Actives / Terminées » ; cliquer un bouton
  recharge la liste filtrée via l'API ; le bouton actif est visuellement distinct.

## Plan d'implémentation

- **Backend** (`app/routers/todos.py`) : `list_todos(done: bool | None = None)` en query param ;
  filtrer la requête SQL si `done` est fourni. Respect skill `python-api` (controller mince).
- **Frontend** (`src/api.js`, `src/App.jsx`) : `listTodos(done)` passe `?done=` ; état `filter`
  dans `App` + 3 boutons ; appel API au changement de filtre. Respect skill `react-ui`
  (fetch centralisé dans `api.js`).
- **Test** (`backend/tests/test_todos.py`) : un test couvrant CA2 (filtre actives).

## Invariants (checklist reviewer)

- [ ] `GET /todos` sans param reste non filtré (pas de régression).
- [ ] Le filtre est appliqué en SQL/param, pas par un tri fragile.
- [ ] Aucun `fetch` direct hors `src/api.js`.
- [ ] Nouveau comportement couvert par au moins un test pytest.
- [ ] Aucun secret introduit ; pas de `console.log` de données.
