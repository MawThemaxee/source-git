#!/bin/bash
# ============================================================
# git-sync.sh - Synchronisation du dépôt GitHub
# Utilisé par l'egg Pterodactyl Garry's Mod
# Placé dans /home/container/git-sync.sh
# ============================================================

if [ "$GIT_AUTO_UPDATE" != "1" ] || [ -z "$GIT_REPO" ]; then
    echo "[git-sync] Désactivé ou aucun dépôt configuré, démarrage direct du serveur..."
    exit 0
fi

GIT_REPO_PATH="/home/container/git-repo"

# Construire l'URL avec le token si fourni
GIT_URL="$GIT_REPO"
if [ -n "$GIT_TOKEN" ]; then
    GIT_URL="https://${GIT_TOKEN}@${GIT_REPO##*//}"
fi

# Cloner ou mettre à jour le dépôt
if [ -d "$GIT_REPO_PATH/.git" ]; then
    echo "[git-sync] Mise à jour du dépôt depuis la branche $GIT_BRANCH..."
    cd "$GIT_REPO_PATH"
    git fetch origin
    git checkout "$GIT_BRANCH"
    git reset --hard "origin/$GIT_BRANCH"
else
    echo "[git-sync] Clonage du dépôt depuis $GIT_REPO (branche: $GIT_BRANCH)..."
    rm -rf "$GIT_REPO_PATH"
    git clone --branch "$GIT_BRANCH" "$GIT_URL" "$GIT_REPO_PATH"
fi

# Copier les dossiers présents dans le repo vers le serveur
echo "[git-sync] Copie des fichiers vers le serveur..."

copy_if_exists() {
    local src="$GIT_REPO_PATH/$1"
    local dst="/home/container/$1"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -rf "$src/"* "$dst/" 2>/dev/null || true
        echo "[git-sync] ✓ $1 copié"
    fi
}

copy_if_exists "garrysmod/addons"
copy_if_exists "garrysmod/gamemodes"
copy_if_exists "garrysmod/lua"
copy_if_exists "garrysmod/maps"
copy_if_exists "garrysmod/materials"
copy_if_exists "garrysmod/models"
copy_if_exists "garrysmod/sound"
copy_if_exists "garrysmod/resource"
copy_if_exists "garrysmod/cfg"

echo "[git-sync] Synchronisation terminée !"
