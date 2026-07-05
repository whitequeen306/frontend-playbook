# Installs prerequisite skills for opencode-frontend-toolkit.
# Run this after cloning the repo. Requires Node.js / npm.
# This toolkit itself (frontend-playbook + design-md) is already in this folder;
# this script only installs the skills the playbook hands off to.

$ErrorActionPreference = "Continue"
Write-Host "==> Installing prerequisite skills for opencode-frontend-toolkit..." -ForegroundColor Cyan

# frontend-design + webapp-testing (Anthropic)
Write-Host "  - frontend-design (anthropics/skills)" -ForegroundColor Gray
npx -y skills add anthropics/skills@frontend-design -g -y
Write-Host "  - webapp-testing (anthropics/skills)" -ForegroundColor Gray
npx -y skills add anthropics/skills@webapp-testing -g -y

# gsap skills (all variants; the agent picks the right one per stack at Stage 3)
Write-Host "  - gsap skills (greensock/gsap-skills)" -ForegroundColor Gray
npx -y skills add https://github.com/greensock/gsap-skills -g -y

Write-Host ""
Write-Host "==> Done." -ForegroundColor Green
Write-Host "Note: 'performance-optimization' is OPTIONAL (cortexloop distribution)." -ForegroundColor Yellow
Write-Host "      Stage 4 degrades to Playwright-based metrics (CLS/LCP/long-tasks) if absent."
Write-Host "Restart opencode so the skill scanner picks up everything." -ForegroundColor Yellow
