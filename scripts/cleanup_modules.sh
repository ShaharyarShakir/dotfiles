#!/usr/bin/env bash
# ============================================================
#  cleandev.sh — Dev artifact cleaner
#
#  Covers:
#    JS/TS  — node_modules, dist-*, .next, .nuxt, .svelte-kit …
#    Python — venv, .venv, __pycache__, uv, pixi
#    Rust   — target/ (per-project) + ~/.cargo/registry cache
#    Go     — per-project bin/ + ~/.cache/go-build + ~/go/pkg/mod
#    Flutter/Dart — build/, .dart_tool, pub-cache
#    Mobile — ios/Pods, android .gradle/build, .expo
#
#  Usage:
#    ./cleandev.sh                        # dry-run (safe, no deletion)
#    ./cleandev.sh --delete               # actually delete
#    ./cleandev.sh --delete --path ~/dev  # scope to a folder
# ============================================================

set -euo pipefail

# ── colours ──────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── defaults ─────────────────────────────────────────────────
DRY_RUN=true
SEARCH_ROOT="${HOME}"
TOTAL_BYTES=0
FOUND_COUNT=0
DELETED_BYTES=0
DELETED_COUNT=0
declare -A CATEGORY_BYTES
declare -A CATEGORY_COUNT

# ── argument parsing ─────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
  --delete | -d) DRY_RUN=false ;;
  --path | -p)
    SEARCH_ROOT="$2"
    shift
    ;;
  --help | -h)
    echo "Usage: $0 [--delete] [--path <dir>]"
    echo "  Default: dry-run from \$HOME"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

# ── helpers ───────────────────────────────────────────────────
bytes_to_human() {
  local b=$1
  if ((b >= 1073741824)); then
    printf "%.2f GB" "$(echo "scale=2; $b/1073741824" | bc)"
  elif ((b >= 1048576)); then
    printf "%.2f MB" "$(echo "scale=2; $b/1048576" | bc)"
  elif ((b >= 1024)); then
    printf "%.2f KB" "$(echo "scale=2; $b/1024" | bc)"
  else printf "%d B" "$b"; fi
}

dir_bytes() {
  # macOS uses -k, Linux uses --block-size=1 or -b
  if du --version &>/dev/null 2>&1; then
    du -sb "$1" 2>/dev/null | awk '{print $1}'
  else
    du -sk "$1" 2>/dev/null | awk '{print $1 * 1024}'
  fi
}

handle_target() {
  local category="$1"
  local target="$2"

  [[ ! -d "$target" && ! -f "$target" ]] && return

  local size
  size=$(dir_bytes "$target")
  ((size == 0)) && size=0

  TOTAL_BYTES=$((TOTAL_BYTES + size))
  FOUND_COUNT=$((FOUND_COUNT + 1))
  CATEGORY_BYTES[$category]=$((${CATEGORY_BYTES[$category]:-0} + size))
  CATEGORY_COUNT[$category]=$((${CATEGORY_COUNT[$category]:-0} + 1))

  local human
  human=$(bytes_to_human "$size")

  if $DRY_RUN; then
    printf "  ${DIM}[dry-run]${NC} ${YELLOW}%-14s${NC}  %8s  %s\n" "$category" "$human" "$target"
  else
    printf "  ${RED}[DELETE]${NC}  ${YELLOW}%-14s${NC}  %8s  %s\n" "$category" "$human" "$target"
    # Go mod cache & some Rust registry files are chmod 0444 by their toolchain.
    # Restore write permission first, otherwise rm -rf silently fails on those files.
    chmod -R u+w "$target" 2>/dev/null || true
    if rm -rf "$target" 2>/dev/null; then
      DELETED_BYTES=$((DELETED_BYTES + size))
      DELETED_COUNT=$((DELETED_COUNT + 1))
    else
      printf "  ${YELLOW}[WARN]${NC}    %-14s  could not fully remove: %s\n" "$category" "$target"
    fi
  fi
}

scan_targets() {
  local root="$1"

  # ── 1. JavaScript / TypeScript ──────────────────────────────
  # node_modules  (React, Next.js, SvelteKit, Nuxt, Vue CLI, Angular,
  #               NestJS, Hono, Express, Remix, Astro, Solid, Qwik …)
  while IFS= read -r -d '' dir; do
    # skip nested node_modules (inside another node_modules)
    [[ "$dir" == */node_modules/*/node_modules ]] && continue
    # skip node_modules that live inside Go module cache or Cargo registry —
    # those are read-only source trees, not project deps we own
    [[ "$dir" == */go/pkg/mod/* ]] && continue
    [[ "$dir" == */.cargo/registry/* ]] && continue
    [[ "$dir" == */.cargo/git/* ]] && continue
    handle_target "node_modules" "$dir"
  done < <(find "$root" \
    \( -name ".git" -o -name ".cache" \) -prune -o \
    -type d -name "node_modules" -print0 2>/dev/null)

  # JS build artefacts — exact names + dist-* / build-* / out-* globs
  # Exact framework dirs
  for build_dir in ".next" ".nuxt" ".svelte-kit" ".output" ".vercel"; do
    while IFS= read -r -d '' dir; do
      local parent
      parent=$(dirname "$dir")
      if [[ -f "$parent/package.json" || -f "$parent/next.config.js" ||
        -f "$parent/next.config.ts" || -f "$parent/nuxt.config.ts" ||
        -f "$parent/svelte.config.js" || -f "$parent/angular.json" ]]; then
        handle_target "js-build" "$dir"
      fi
    done < <(find "$root" \
      -path "*/node_modules" -prune -o \
      -type d -name "$build_dir" -print0 2>/dev/null)
  done

  # Glob patterns: dist[-_]*, build[-_]*, out[-_]*, and plain dist/build/out
  # Covers: dist-react, dist-electron, dist-cjs, build-prod, out-ssr, etc.
  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    local bname
    bname=$(basename "$dir")

    # Skip dirs that live inside node_modules
    [[ "$dir" == */node_modules/* ]] && continue

    # Must sit next to a recognisable project file
    if [[ -f "$parent/package.json" || -f "$parent/next.config.js" ||
      -f "$parent/next.config.ts" || -f "$parent/next.config.mjs" ||
      -f "$parent/nuxt.config.ts" || -f "$parent/nuxt.config.js" ||
      -f "$parent/svelte.config.js" || -f "$parent/svelte.config.ts" ||
      -f "$parent/angular.json" || -f "$parent/vite.config.ts" ||
      -f "$parent/vite.config.js" || -f "$parent/webpack.config.js" ||
      -f "$parent/electron-builder.yml" || -f "$parent/electron-builder.json" ||
      -f "$parent/forge.config.js" || -f "$parent/rollup.config.js" ||
      -f "$parent/tsup.config.ts" || -f "$parent/esbuild.config.js" ]]; then
      handle_target "js-build" "$dir"
    fi
  done < <(find "$root" \
    -path "*/node_modules" -prune -o \
    -type d \( \
    -name "dist" -o \
    -name "dist-*" -o \
    -name "dist_*" -o \
    -name "build" -o \
    -name "build-*" -o \
    -name "build_*" -o \
    -name "out" -o \
    -name "out-*" -o \
    -name "out_*" -o \
    -name "release" -o \
    -name "release-*" -o \
    -name "bundle" -o \
    -name "bundle-*" -o \
    -name "storybook-static" \
    \) -print0 2>/dev/null)

  # Bun cache
  while IFS= read -r -d '' dir; do
    handle_target "bun-cache" "$dir"
  done < <(find "$root" -type d -name ".bun" -print0 2>/dev/null)

  # pnpm store (local .pnpm-store)
  while IFS= read -r -d '' dir; do
    handle_target "pnpm-store" "$dir"
  done < <(find "$root" -type d -name ".pnpm-store" -print0 2>/dev/null)

  # yarn cache inside projects
  while IFS= read -r -d '' dir; do
    handle_target "yarn-cache" "$dir"
  done < <(find "$root" -type d -name ".yarn" -print0 2>/dev/null)

  # ── 2. Python ───────────────────────────────────────────────
  # venv / .venv / env / virtualenv
  for venv_name in "venv" ".venv" "env" ".env" "virtualenv" ".virtualenv"; do
    while IFS= read -r -d '' dir; do
      # confirm it looks like a real venv
      if [[ -f "$dir/pyvenv.cfg" || -d "$dir/bin" || -d "$dir/Scripts" ]]; then
        handle_target "python-venv" "$dir"
      fi
    done < <(find "$root" -type d -name "$venv_name" -print0 2>/dev/null)
  done

  # uv cache
  while IFS= read -r -d '' dir; do
    handle_target "uv-cache" "$dir"
  done < <(find "$root" -type d -name ".uv" -print0 2>/dev/null)

  # pixi envs
  while IFS= read -r -d '' dir; do
    handle_target "pixi-env" "$dir"
  done < <(find "$root" -type d -name ".pixi" -print0 2>/dev/null)

  # __pycache__ & *.pyc
  while IFS= read -r -d '' dir; do
    handle_target "py-cache" "$dir"
  done < <(find "$root" -type d -name "__pycache__" -print0 2>/dev/null)

  # ── 3. Flutter / Dart ───────────────────────────────────────
  # .dart_tool, build/  inside flutter projects
  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    if [[ -f "$parent/pubspec.yaml" ]]; then
      handle_target "flutter-build" "$dir"
    fi
  done < <(find "$root" -type d \( -name ".dart_tool" -o -name ".flutter-plugins" \) -print0 2>/dev/null)

  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    if [[ -f "$parent/pubspec.yaml" ]]; then
      handle_target "flutter-build" "$dir"
    fi
  done < <(find "$root" -type d -name "build" -print0 2>/dev/null)

  # pub cache inside project
  while IFS= read -r -d '' dir; do
    handle_target "pub-cache" "$dir"
  done < <(find "$root" -type d -name ".pub-cache" -print0 2>/dev/null)

  # ── 4. React Native / Expo ──────────────────────────────────
  # ios/Pods
  while IFS= read -r -d '' dir; do
    handle_target "ios-pods" "$dir"
  done < <(find "$root" -type d -name "Pods" -print0 2>/dev/null)

  # android/.gradle, android/build, android/app/build
  while IFS= read -r -d '' dir; do
    handle_target "android-gradle" "$dir"
  done < <(find "$root" -type d -name ".gradle" -print0 2>/dev/null)

  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    # must be inside an android/ folder
    if [[ "$parent" == */android || "$parent" == */android/app ]]; then
      handle_target "android-build" "$dir"
    fi
  done < <(find "$root" -type d -name "build" -print0 2>/dev/null)

  # Expo .expo cache
  while IFS= read -r -d '' dir; do
    handle_target "expo-cache" "$dir"
  done < <(find "$root" -type d -name ".expo" -print0 2>/dev/null)

  # ── 5. Rust ─────────────────────────────────────────────────
  # Per-project target/ dirs — only when Cargo.toml is a sibling.
  # debug + release builds easily hit 10-20 GB per project.
  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    [[ "$dir" == */target/*/target ]] && continue # skip nested
    if [[ -f "$parent/Cargo.toml" || -f "$parent/Cargo.lock" ]]; then
      handle_target "rust-target" "$dir"
    fi
  done < <(find "$root" \
    -path "*/.git" -prune -o \
    -type d -name "target" -print0 2>/dev/null)

  # ~/.cargo/registry + ~/.cargo/git — downloaded crate sources & index.
  # Safe to wipe; cargo re-fetches on next build.
  for cargo_dir in \
    "${CARGO_HOME:-$HOME/.cargo}/registry" \
    "${CARGO_HOME:-$HOME/.cargo}/git"; do
    [[ -d "$cargo_dir" ]] && handle_target "cargo-cache" "$cargo_dir"
  done

  # ── 6. Go ───────────────────────────────────────────────────
  # Per-project bin/ next to go.mod (compiled output binaries)
  # Exclude bin/ dirs inside the Go module cache — already handled by go-mod-cache.
  while IFS= read -r -d '' dir; do
    local parent
    parent=$(dirname "$dir")
    [[ "$dir" == */go/pkg/mod/* ]] && continue
    if [[ -f "$parent/go.mod" ]]; then
      handle_target "go-bin" "$dir"
    fi
  done < <(find "$root" \
    -path "*/.git" -prune -o \
    -path "*/go/pkg/mod" -prune -o \
    -type d -name "bin" -print0 2>/dev/null)

  # Go build cache  (~/.cache/go-build or $GOCACHE)
  local go_build_cache="${GOCACHE:-}"
  if [[ -z "$go_build_cache" ]] && command -v go &>/dev/null; then
    go_build_cache="$(go env GOCACHE 2>/dev/null || true)"
  fi
  if [[ -z "$go_build_cache" ]]; then
    if [[ -d "${HOME}/.cache/go-build" ]]; then
      go_build_cache="${HOME}/.cache/go-build"
    elif [[ -d "${LOCALAPPDATA:-}/go-build" ]]; then
      go_build_cache="${LOCALAPPDATA}/go-build"
    fi
  fi
  [[ -n "$go_build_cache" && -d "$go_build_cache" ]] &&
    handle_target "go-build-cache" "$go_build_cache"

  # Go module cache  (~/go/pkg/mod or $GOPATH/pkg/mod)
  # Go intentionally chmod 0444s module files to prevent accidental edits.
  # `go clean -modcache` is the official way to remove it; it handles the
  # permissions itself. We fall back to handle_target (which does chmod -R u+w
  # before rm -rf) only when the `go` binary is not on PATH.
  local gopath="${GOPATH:-$HOME/go}"
  local go_mod_cache="${gopath}/pkg/mod"
  if [[ -d "$go_mod_cache" ]]; then
    local size
    size=$(dir_bytes "$go_mod_cache")
    ((size == 0)) && size=0
    TOTAL_BYTES=$((TOTAL_BYTES + size))
    FOUND_COUNT=$((FOUND_COUNT + 1))
    CATEGORY_BYTES[go-mod-cache]=$((${CATEGORY_BYTES[go-mod-cache]:-0} + size))
    CATEGORY_COUNT[go-mod-cache]=$((${CATEGORY_COUNT[go-mod-cache]:-0} + 1))
    local human
    human=$(bytes_to_human "$size")
    if $DRY_RUN; then
      printf "  ${DIM}[dry-run]${NC} ${YELLOW}%-14s${NC}  %8s  %s\n" "go-mod-cache" "$human" "$go_mod_cache"
    else
      printf "  ${RED}[DELETE]${NC}  ${YELLOW}%-14s${NC}  %8s  %s\n" "go-mod-cache" "$human" "$go_mod_cache"
      if command -v go &>/dev/null; then
        # Official method — handles read-only permissions internally
        if go clean -modcache 2>/dev/null; then
          DELETED_BYTES=$((DELETED_BYTES + size))
          DELETED_COUNT=$((DELETED_COUNT + 1))
        else
          chmod -R u+w "$go_mod_cache" 2>/dev/null || true
          if rm -rf "$go_mod_cache" 2>/dev/null; then
            DELETED_BYTES=$((DELETED_BYTES + size))
            DELETED_COUNT=$((DELETED_COUNT + 1))
          fi
        fi
      else
        chmod -R u+w "$go_mod_cache" 2>/dev/null || true
        if rm -rf "$go_mod_cache" 2>/dev/null; then
          DELETED_BYTES=$((DELETED_BYTES + size))
          DELETED_COUNT=$((DELETED_COUNT + 1))
        fi
      fi
    fi
  fi

  # Compiled Go tool binaries in $GOPATH/bin — uncomment to enable:
  # [[ -d "${gopath}/bin" ]] && handle_target "go-gopath-bin" "${gopath}/bin"
}

# ── banner ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
if $DRY_RUN; then
  echo -e "${BOLD}${CYAN}║         cleandev  —  DRY RUN (no changes)        ║${NC}"
else
  echo -e "${BOLD}${RED}║         cleandev  —  LIVE DELETE MODE            ║${NC}"
fi
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo -e "  ${DIM}Search root : ${SEARCH_ROOT}${NC}"
echo -e "  ${DIM}Mode        : $(${DRY_RUN} && echo 'Dry-run' || echo 'DELETE')${NC}"
echo ""
echo -e "  ${BOLD}Category        Size      Path${NC}"
echo -e "  $(printf '─%.0s' {1..70})"

# ── run ───────────────────────────────────────────────────────
scan_targets "$SEARCH_ROOT"

# ── summary ───────────────────────────────────────────────────
echo ""
echo -e "  $(printf '─%.0s' {1..70})"
echo -e "  ${BOLD}Summary by category:${NC}"
echo ""

for cat in "${!CATEGORY_BYTES[@]}"; do
  printf "    ${GREEN}%-18s${NC}  %6d item(s)   %s\n" \
    "$cat" \
    "${CATEGORY_COUNT[$cat]}" \
    "$(bytes_to_human "${CATEGORY_BYTES[$cat]}")"
done | sort

echo ""
if $DRY_RUN; then
  echo -e "  ${BOLD}Total items found : ${FOUND_COUNT}${NC}"
  echo -e "  ${BOLD}${GREEN}Space reclaimable : $(bytes_to_human "$TOTAL_BYTES")${NC}"
  echo ""
  echo -e "  ${YELLOW}⚠  This was a DRY RUN — nothing was deleted.${NC}"
  echo -e "  ${YELLOW}   Re-run with ${BOLD}--delete${NC}${YELLOW} to free the space above.${NC}"
  echo -e "  ${DIM}   Example: $0 --delete --path \"${SEARCH_ROOT}\"${NC}"
else
  echo -e "  ${BOLD}Targeted          : ${FOUND_COUNT} item(s)  $(bytes_to_human "$TOTAL_BYTES")${NC}"
  echo -e "  ${BOLD}${GREEN}Actually freed    : ${DELETED_COUNT} item(s)  $(bytes_to_human "$DELETED_BYTES")${NC}"
  if ((FOUND_COUNT > DELETED_COUNT)); then
    local _skipped=$((FOUND_COUNT - DELETED_COUNT))
    echo -e "  ${YELLOW}Skipped / failed  : ${_skipped} item(s)  — see [WARN] lines above${NC}"
  fi
  echo ""
  echo -e "  ${GREEN}✓  Done. $(bytes_to_human "$DELETED_BYTES") freed.${NC}"
fi
echo ""
