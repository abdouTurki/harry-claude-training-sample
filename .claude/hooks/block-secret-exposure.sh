#!/bin/bash
# PreToolUse hook — bloque les commandes qui exposeraient des secrets dans le contexte de Claude.
# Bonne pratique Harington (repris du talenteo-brain). S'applique à : Bash, Read, Grep.
# Convention de blocage : exit 2 + message sur stderr → Claude ne peut PAS exécuter l'action.
#
# Bypass ponctuel : `touch ~/.claude-allow-secrets` (puis `rm` quand terminé).
if [ -f "$HOME/.claude-allow-secrets" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Extensions / noms de fichiers sensibles
SENSITIVE_EXT='\.(env|env\.[a-zA-Z0-9]+|netrc|pem|key|secret|keystore|jks|p12|pfx)$'
SENSITIVE_NAME='(credentials|secrets|passwords|\.netrc|settings\.xml|\.pgpass)'

# ============================================================
# BASH
# ============================================================
if [ "$TOOL" = "Bash" ] && [ -n "$COMMAND" ]; then

  # 1. kubectl exec env / printenv (dump toutes les variables, secrets inclus)
  if echo "$COMMAND" | grep -qE 'kubectl.*exec.*\benv\b|kubectl.*exec.*printenv'; then
    if ! echo "$COMMAND" | grep -qE '>>\s*[~/.]|>\s*[~/.]'; then
      echo "BLOCKED: kubectl exec env/printenv peut exposer des secrets. Redirige vers un fichier (> /tmp/env.txt)." >&2
      exit 2
    fi
  fi

  # 2. kubectl get secret -o (décode les secrets)
  if echo "$COMMAND" | grep -qE 'kubectl.*get\s+secret.*-o\s*(jsonpath|json|yaml)'; then
    echo "BLOCKED: kubectl get secret -o peut exposer des secrets. Redirige vers un fichier." >&2
    exit 2
  fi

  # 3. Commandes qui lisent/affichent des fichiers sensibles
  SENSITIVE_FILE_PATTERN='\S*\.(env|env\.[a-zA-Z0-9]+|netrc|pem|key|secret|keystore|jks|p12|pfx)\b'
  SENSITIVE_NAME_PATTERN='\S*(credentials|secrets|passwords|\.netrc|\.pgpass)\b'
  FILE_READERS='(cat|head|tail|less|more|bat|sed|awk|sort|uniq|nl|strings|xxd|od|hexdump|diff|comm|paste|cut|tee|cp|mv|nano|vi|vim|open|xdg-open)'
  BLOCKED_3A=false
  while IFS= read -r segment; do
    if echo "$segment" | grep -qE "${FILE_READERS}\s+.*${SENSITIVE_FILE_PATTERN}"; then BLOCKED_3A=true; break; fi
    if echo "$segment" | grep -qE "${FILE_READERS}\s+.*${SENSITIVE_NAME_PATTERN}"; then BLOCKED_3A=true; break; fi
  done <<< "$(echo "$COMMAND" | sed 's/[|;]/\n/g; s/&&/\n/g; s/||/\n/g')"
  if $BLOCKED_3A; then
    echo "BLOCKED: la commande lit un fichier sensible (secrets potentiels)." >&2
    exit 2
  fi

  # 3c. python/node/ruby/perl lisant un fichier sensible
  if echo "$COMMAND" | grep -qE '(python|python3|node|ruby|perl).*\S*\.(env|env\.[a-zA-Z0-9]+|netrc|pem|key|secret)\b'; then
    echo "BLOCKED: script référençant un fichier sensible." >&2
    exit 2
  fi

  # 3d. curl file://
  if echo "$COMMAND" | grep -qiE 'curl\s+.*file://'; then
    echo "BLOCKED: curl file:// peut lire des fichiers sensibles locaux." >&2
    exit 2
  fi

  # 3e. find/xargs vers un lecteur de fichier sur des chemins sensibles
  if echo "$COMMAND" | grep -qE '(find|xargs).*\.(env|netrc|pem|key|secret)'; then
    if echo "$COMMAND" | grep -qE '(-exec|xargs)\s*(cat|head|tail|less|more|sed|awk|strings)'; then
      echo "BLOCKED: find/xargs lisant des fichiers sensibles." >&2
      exit 2
    fi
  fi

  # 4. Impression de variables contenant un secret (echo/printf…)
  SECRET_VAR_PATTERN='\$\{?[A-Za-z0-9_.]*_?(password|passwd|pwd|secret|token|api_key|credential|private_key|access_key|client_key|pgpassword)[A-Za-z0-9_]*\}?'
  PRINT_COMMANDS='(echo|printf|print|cat\s*<<)'
  if echo "$COMMAND" | grep -qiE "${PRINT_COMMANDS}\s+.*${SECRET_VAR_PATTERN}"; then
    if ! echo "$COMMAND" | grep -qE '>>\s*[~/.]|>\s*[~/.]'; then
      echo "BLOCKED: la commande imprime une variable contenant un secret. Redirige vers un fichier." >&2
      exit 2
    fi
  fi

  # 5. env/printenv/set qui dumpent tout
  if echo "$COMMAND" | grep -qE '^\s*(env|printenv|set)\s*$|^\s*(env|printenv|set)\s*\|'; then
    if ! echo "$COMMAND" | grep -qE '>\s*/'; then
      echo "BLOCKED: dump de toutes les variables d'env (secrets potentiels). Redirige vers un fichier." >&2
      exit 2
    fi
  fi

  # 6. Secret inline : password=xxx, token=xxx (autorisé si c'est une variable $VAR)
  if echo "$COMMAND" | grep -qiE '(password|secret|token|api_key|client_secret|private_key|access_key)=[^\$\s]'; then
    if ! echo "$COMMAND" | grep -qE '^\s*(grep|rg|ag|ack|find)\b'; then
      echo "BLOCKED: valeur secrète en clair dans la commande. Utilise une variable d'env ou un .env." >&2
      exit 2
    fi
  fi

  # 7. PGPASSWORD= inline
  if echo "$COMMAND" | grep -qiE 'PGPASSWORD=\S'; then
    echo "BLOCKED: PGPASSWORD inline expose le mot de passe DB. Utilise ~/.pgpass ou PGPASSFILE." >&2
    exit 2
  fi

  # 8. base64 -d de secrets kubectl
  if echo "$COMMAND" | grep -qE 'base64.*(-d|--decode).*secret|kubectl.*secret.*base64'; then
    echo "BLOCKED: décodage de secrets. Redirige vers un fichier." >&2
    exit 2
  fi

fi

# ============================================================
# READ
# ============================================================
if [ "$TOOL" = "Read" ] && [ -n "$FILE_PATH" ]; then
  if echo "$FILE_PATH" | grep -qE "$SENSITIVE_EXT"; then
    echo "BLOCKED: lecture d'un fichier sensible ($FILE_PATH) — secrets potentiels." >&2
    exit 2
  fi
  if echo "$FILE_PATH" | grep -qiE "$SENSITIVE_NAME"; then
    echo "BLOCKED: lecture d'un fichier de credentials ($FILE_PATH)." >&2
    exit 2
  fi
fi

# ============================================================
# GREP
# ============================================================
GREP_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
GREP_GLOB=$(echo "$INPUT" | jq -r '.tool_input.glob // empty')
if [ "$TOOL" = "Grep" ]; then
  if [ -n "$GREP_PATH" ] && echo "$GREP_PATH" | grep -qE "$SENSITIVE_EXT"; then
    echo "BLOCKED: grep sur un fichier sensible ($GREP_PATH)." >&2
    exit 2
  fi
  if [ -n "$GREP_PATH" ] && echo "$GREP_PATH" | grep -qiE "$SENSITIVE_NAME"; then
    echo "BLOCKED: grep sur un fichier de credentials ($GREP_PATH)." >&2
    exit 2
  fi
  if [ -n "$GREP_GLOB" ] && echo "$GREP_GLOB" | grep -qE '\*\.env|\*\.pem|\*\.key|\*\.secret|\*\.netrc'; then
    echo "BLOCKED: glob grep ciblant des fichiers sensibles ($GREP_GLOB)." >&2
    exit 2
  fi
fi

exit 0
