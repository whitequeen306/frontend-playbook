#!/usr/bin/env bash
# Installs prerequisite skills for opencode-frontend-toolkit.
# Run this after cloning the repo. Requires Node.js / npm.
# This toolkit itself (frontend-playbook + design-md) is already in this folder;
# this script only installs the skills the playbook hands off to.

set -e
echo "==> Installing prerequisite skills for opencode-frontend-toolkit..."

# frontend-design + webapp-testing (Anthropic)
echo "  - frontend-design (anthropics/skills)"
npx -y skills add anthropics/skills@frontend-design -g -y
echo "  - webapp-testing (anthropics/skills)"
npx -y skills add anthropics/skills@webapp-testing -g -y

# gsap skills (all variants; the agent picks the right one per stack at Stage 3)
echo "  - gsap skills (greensock/gsap-skills)"
npx -y skills add https://github.com/greensock/gsap-skills -g -y

echo ""
echo "==> Done."
echo "Note: 'performance-optimization' is OPTIONAL (cortexloop distribution)."
echo "      Stage 4 degrades to Playwright-based metrics (CLS/LCP/long-tasks) if absent."
echo "Restart opencode so the skill scanner picks up everything."
