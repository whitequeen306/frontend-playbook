#!/usr/bin/env bash
# ensure-prereqs.sh — detect & auto-install prerequisite skills for frontend-playbook.
# Idempotent; safe to re-run. Auto-pull goes through opencode's bash permission gate.
set -u
ROOTS=("$HOME/.config/opencode/skills" "$HOME/.opencode/skills" "$HOME/.claude/skills" "$HOME/.agents/skills")

find_skill() {
  local name="$1"
  for r in "${ROOTS[@]}"; do
    [ -d "$r" ] || continue
    local hit
    hit=$(find "$r" -name SKILL.md -path "*/$name/SKILL.md" 2>/dev/null | head -n1)
    [ -n "$hit" ] && { echo "$hit"; return 0; }
  done
  return 1
}

echo "==> Checking prerequisite skills for frontend-playbook..."
need_anthropic=0
for s in frontend-design webapp-testing; do
  if p=$(find_skill "$s"); then echo "  [present] $s -> $p"
  else echo "  [missing] $s"; need_anthropic=1; fi
done
if [ "$need_anthropic" -eq 1 ]; then
  echo "  -> pulling anthropics/skills (provides frontend-design + webapp-testing + docs skills)..."
  npx -y skills add https://github.com/anthropics/skills -g -y
fi

if p=$(find_skill gsap-core); then echo "  [present] gsap-core -> $p"
else echo "  [missing] gsap-core -> pulling greensock/gsap-skills..."; npx -y skills add https://github.com/greensock/gsap-skills -g -y; fi

if p=$(find_skill performance-optimization); then echo "  [present] performance-optimization -> $p"
else echo "  [optional, skipped] performance-optimization (cortexloop; Stage 4 degrades to Playwright metrics)"; fi

echo "==> Done. Restart opencode if anything was installed."
