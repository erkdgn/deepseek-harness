#!/usr/bin/env bash
# Install the dsh review profile on a durable machine, for consulting dsh by hand.
#
# CI does not run this: scripts/bootstrap-dsh-profile.sh is what the workflows
# call, because a GitHub-hosted runner keeps no state between jobs. This wrapper
# reads the provider key from the repository .env when the environment has none,
# so a workstation does not have to export one per shell.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
key_env="${DSH_PROVIDER_KEY_ENV:-DSH_PROVIDER_API_KEY}"

if [ -z "${!key_env:-}" ] && [ -f "$root/.env" ]; then
  value="$(sed -n "s/^[[:space:]]*${key_env}[[:space:]]*=[[:space:]]*//p" "$root/.env" | tail -n1 | sed "s/^['\"]//;s/['\"]\$//")"
  [ -n "$value" ] && export "$key_env=$value"
fi

if [ -z "${!key_env:-}" ]; then
  echo "setup-review-profile: \$$key_env is not set and $root/.env does not define it." >&2
  exit 1
fi

"$root/scripts/bootstrap-dsh-profile.sh"

cat <<'NEXT'

Consult dsh from the repository root, one self-contained task per call:

  dsh --profile headless "<question, with the code pasted in full>"

dsh keeps no history between calls. Paste the code itself; a reference to
"the function above" reaches a session that has never seen it.
NEXT
