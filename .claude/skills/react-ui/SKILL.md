---
name: react-ui
description: Conventions React de ce repo. À charger pour toucher le front ou l'agent reviewer.
---
# Conventions UI (React + Vite)

1. **Appels API centralisés** : tout accès réseau passe par `src/api.js`.
   Aucun `fetch` en dur dans un composant.
2. **URL d'API** : lue via `import.meta.env.VITE_API_URL` (injectée au build).
   Jamais d'URL de prod codée en dur dans un composant.
3. **État** : `useState` / `useEffect` locaux pour ce périmètre ; pas de lib d'état globale
   pour une app de cette taille (pas de sur-ingénierie).
4. **Accessibilité** : `aria-label` sur les champs sans label visible ; boutons avec texte
   ou libellé.
5. **Erreurs réseau** : afficher un message à l'utilisateur (pas de `console.error` muet).
6. **Build** : `npm run build` doit compiler sans warning bloquant avant toute PR.
