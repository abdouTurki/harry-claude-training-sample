#!/usr/bin/env bash
# Hook PreToolUse — garde-fou "on ne PEUT PAS pousser sur une branche protégée".
# Reçoit l'appel de tool en JSON sur stdin ; renvoie une décision en JSON sur stdout.
# Illustre la leçon : gouverner par mécanisme, pas par instruction.
set -euo pipefail

input="$(cat)"

# Extrait la commande bash (jq si dispo, sinon grep de secours).
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
else
  cmd="$input"
fi

# Bloque tout push vers main/master/production.
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push.*(main|master|production)'; then
  cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Push direct sur une branche protégée interdit. Passe par une PR."
  }
}
JSON
  exit 0
fi

# Sinon : ne rien imposer (laisser le flux de permission normal décider).
exit 0
