#!/usr/bin/env bash
set -Eeuo pipefail

on_error() {
  echo "ERROR: backup failed (line $1)" >&2
  exit 1
}
trap 'on_error $LINENO' ERR

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -p, --prefix PREFIX     Backup filename prefix (default: dst)
  -d, --dir DIR           Backup output directory (default: <project_parent>/backup)
  -y, --yes               Assume yes; skip confirmation
  -h, --help              Show this help message
EOF
}

# ---------- defaults ----------
PREFIX="dst"
ASSUME_YES=false
CUSTOM_BACKUP_DIR=""

# ---------- argument parsing ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prefix)
      [[ $# -ge 2 ]] || { echo "ERROR: --prefix requires an argument"; exit 1; }
      PREFIX="$2"
      shift 2
      ;;
    -d|--dir)
      [[ $# -ge 2 ]] || { echo "ERROR: --dir requires an argument"; exit 1; }
      CUSTOM_BACKUP_DIR="$2"
      shift 2
      ;;
    -y|--yes)
      ASSUME_YES=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# ---------- path resolution ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_NAME="$(basename "${PROJECT_DIR}")"
PROJECT_PARENT_DIR="$(dirname "${PROJECT_DIR}")"

DEFAULT_BACKUP_DIR="${PROJECT_PARENT_DIR}/backup"

# ---------- backup directory selection ----------
if [[ -n "${CUSTOM_BACKUP_DIR}" ]]; then
  BACKUP_DIR="$(cd "$(dirname "${CUSTOM_BACKUP_DIR}")" && pwd)/$(basename "${CUSTOM_BACKUP_DIR}")"
else
  BACKUP_DIR="${DEFAULT_BACKUP_DIR}"
fi

# ---------- timestamp ----------
DATETIME="$(date +"%y%m%dT%H%M")"
BACKUP_FILE="${BACKUP_DIR}/${PREFIX}_${DATETIME}.tar.gz"

# ---------- print plan ----------
echo "Backup plan:"
echo "  Project        : ${PROJECT_NAME}"
echo "  Project path   : ${PROJECT_DIR}"
echo "  Output dir     : ${BACKUP_DIR}"
echo "  Archive        : $(basename "${BACKUP_FILE}")"
echo

# ---------- confirmation ----------
if [[ "${ASSUME_YES}" = false ]]; then
  read -r -p "Proceed with backup? [Y]/n " answer
  case "${answer}" in
    ""|Y|y) ;;
    *) echo "Aborted"; exit 0 ;;
  esac
fi

# ---------- prepare ----------
mkdir -p "${BACKUP_DIR}"

if [[ -e "${BACKUP_FILE}" ]]; then
  echo "ERROR: backup file already exists: ${BACKUP_FILE}" >&2
  exit 1
fi

# ---------- backup ----------
echo "Creating backup: ${BACKUP_FILE}"

tar -czf "${BACKUP_FILE}" \
    --exclude="${PROJECT_PARENT_DIR}/backup" \
    -C "${PROJECT_PARENT_DIR}" \
    "${PROJECT_NAME}"

# ---------- verify ----------
if [[ ! -s "${BACKUP_FILE}" ]]; then
  echo "ERROR: backup file not created or empty" >&2
  exit 1
fi

echo "Backup completed successfully"
