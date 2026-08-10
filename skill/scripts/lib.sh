#!/usr/bin/env bash
# Shared helpers for the first-site scripts. Sourced, never run directly.

CONFIG_DIR="${SHIP_CONFIG_DIR:-$HOME/.config/shipwhatyoubuilt}"

# Colour, but only when talking to a terminal.
if [ -t 2 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
  C_DIM=$'\033[2m';  C_BLD=$'\033[1m';  C_OFF=$'\033[0m'
else
  C_RED=''; C_GRN=''; C_YEL=''; C_DIM=''; C_BLD=''; C_OFF=''
fi

# All human-facing chatter goes to stderr so stdout stays pipeable.
say()  { printf '%s\n' "$*" >&2; }
ok()   { printf '%s✓%s %s\n' "$C_GRN" "$C_OFF" "$*" >&2; }
warn() { printf '%s!%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
bad()  { printf '%s✗%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_OFF" >&2; }
head1(){ printf '\n%s%s%s\n' "$C_BLD" "$*" "$C_OFF" >&2; }
die()  { bad "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Name a project after its directory, sanitised for use as a filename.
project_slug() {
  basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g; s/--*/-/g; s/^-//; s/-$//'
}

config_path() { printf '%s/%s.conf\n' "$CONFIG_DIR" "$(project_slug)"; }

# Load saved config for this project, if any. Never fatal.
load_config() {
  local f; f="$(config_path)"
  [ -f "$f" ] || return 1
  # shellcheck disable=SC1090
  . "$f"
  return 0
}

# save_config KEY VALUE — idempotent upsert into the project's config file.
save_config() {
  local key="$1" val="$2" f tmp
  f="$(config_path)"
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR" 2>/dev/null || true
  touch "$f"
  tmp="$(mktemp)"
  grep -v "^${key}=" "$f" > "$tmp" 2>/dev/null || true
  # %q-quoted: load_config SOURCES this file, so an unquoted value containing
  # a backtick or semicolon would execute on the next run.
  printf '%s=%s\n' "$key" "$(printf '%q' "$val")" >> "$tmp"
  sort -o "$tmp" "$tmp"
  mv "$tmp" "$f"
  chmod 600 "$f" 2>/dev/null || true
}

# Read a top-level string field out of package.json without needing jq.
# pkg_field <file> <path.to.key>
pkg_field() {
  local file="$1" key="$2"
  [ -f "$file" ] || return 1
  if have jq; then
    jq -r --arg k "$key" 'getpath($k | split(".")) // empty' "$file" 2>/dev/null
  else
    # Good enough for "scripts"."build" and "name" in a normally-formatted file.
    local leaf="${key##*.}"
    sed -n "s/.*\"${leaf}\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -1
  fi
}

# True if package.json mentions this dependency name at all.
pkg_has() {
  [ -f package.json ] || return 1
  grep -q "\"$1\"[[:space:]]*:" package.json 2>/dev/null
}

confirm() {
  local prompt="$1"
  if [ ! -t 0 ]; then
    warn "Not a terminal — assuming no for: $prompt"
    return 1
  fi
  printf '%s [y/N] ' "$prompt" >&2
  local reply; read -r reply
  case "$reply" in [yY]*) return 0 ;; *) return 1 ;; esac
}
