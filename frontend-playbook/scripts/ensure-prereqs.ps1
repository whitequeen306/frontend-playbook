# ensure-prereqs.ps1 — detect & auto-install prerequisite skills for frontend-playbook.
# Idempotent; safe to re-run. Auto-pull goes through opencode's bash permission gate.
$ErrorActionPreference = "Continue"
$roots = @("$env:USERPROFILE\.config\opencode\skills","$env:USERPROFILE\.opencode\skills","$env:USERPROFILE\.claude\skills","$env:USERPROFILE\.agents\skills") | Where-Object { Test-Path $_ }

function Find-Skill([string]$name) {
  foreach($r in $roots){
    $hit = Get-ChildItem $r -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match "\\$name\\SKILL\.md$" }
    if($hit){ return $hit.FullName }
  }
  return $null
}

Write-Host "==> Checking prerequisite skills for frontend-playbook..." -ForegroundColor Cyan

$needAnthropic = $false
foreach($s in @('frontend-design','webapp-testing')){
  $p = Find-Skill $s
  if($p){ Write-Host "  [present] $s -> $p" -ForegroundColor Green }
  else { Write-Host "  [missing] $s" -ForegroundColor Yellow; $needAnthropic = $true }
}
if($needAnthropic){
  Write-Host "  -> pulling anthropics/skills (provides frontend-design + webapp-testing + docs skills)..." -ForegroundColor Cyan
  npx -y skills add https://github.com/anthropics/skills -g -y
}

$p = Find-Skill 'gsap-core'
if($p){ Write-Host "  [present] gsap-core -> $p" -ForegroundColor Green }
else { Write-Host "  [missing] gsap-core -> pulling greensock/gsap-skills..." -ForegroundColor Yellow; npx -y skills add https://github.com/greensock/gsap-skills -g -y }

$p = Find-Skill 'performance-optimization'
if($p){ Write-Host "  [present] performance-optimization -> $p" -ForegroundColor Green }
else { Write-Host "  [optional, skipped] performance-optimization (cortexloop; Stage 4 degrades to Playwright metrics)" -ForegroundColor DarkGray }

Write-Host "==> Done. Restart opencode if anything was installed." -ForegroundColor Green
