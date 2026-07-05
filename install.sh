#!/usr/bin/env bash
# Thin wrapper -> real logic in frontend-playbook/scripts/ensure-prereqs.sh
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$dir/frontend-playbook/scripts/ensure-prereqs.sh" "$@"
