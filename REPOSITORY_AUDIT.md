# Repository Cleanup Decisions

This file is the working source of truth for the GitHub portfolio cleanup.

## Public flagship portfolio

These are the six projects that should represent the strongest work:

1. `vibelink_portal` — VibeLink website, lead capture, and CRM foundation
2. `vibeflex-headless` — VibeFlex full-stack headless commerce platform
3. `VibeOpsPortal` — business operations command center
4. `rork-vela-luxury-curtains` — luxury product visualization experience
5. `winrep-pro-wizard` — field-sales and territory-management system
6. Elite Eleven repository — identify the correct source repository, then document and feature it

## Official repository decisions

### VibeLink

- **KEEP / ACTIVE:** `vibelink_portal`
- **ARCHIVE:** `rork-vibelink-property-enhancement`
- **CONSOLIDATE:** `vibeops-lead-system` into VibeLink or VibeOps after useful lead logic is reviewed

The Rork repository is now labeled as a legacy reference and points visitors to the current platform.

### VibeFlex

- **KEEP / FLAGSHIP:** `vibeflex-headless`
- **REVIEW FOR UNIQUE SHOPIFY THEME CODE:** `vibeflex-shopify-theme`
- **ARCHIVE AFTER COMPARISON:** `VibeFlex-Sports`
- **ARCHIVE AFTER COMPARISON:** `vibeflex-sports-site`
- **ARCHIVE AFTER COMPARISON:** `LacedUp-By-VibeFlex-Sports`
- **ARCHIVE:** `vibeflex-drop-1`
- **CONSOLIDATE OR ARCHIVE:** `vibeflex-reapsow-empire`
- **DELETE:** `VibeFlex-Theme` if confirmed empty

### ReapSow

Keep only the repository with the strongest usable implementation. Current disposition:

- **DELETE IF EMPTY:** `ReapSow-Pro1`
- **DELETE IF EMPTY:** `ReapSow1.0`
- **COMPARE:** `ReapSowPro-Live`
- **COMPARE:** `ReapSow_hq`
- **COMPARE:** `ReapSow_Pro`

After comparison, retain one canonical repository and archive or delete the rest.

## Immediate delete candidates

These repositories are empty, accidental, misspelled, or low-value course artifacts and should not remain visible as active portfolio projects:

- `Data-Science-Notebook`
- `DataScienceEcosystem.piynb`
- `Realtor-Vibe`
- `Smiles-Lakewood-Ranch-CRM`
- `VibeFlex-Theme`
- Empty ReapSow duplicates after final verification

## Keep private pending product review

- `brand-shop-flow`
- `escapade-playbook`
- `rork-build-this`
- `rork-here`
- `rork-impulse-pdf-shop`
- `rork-quickfix-digital-toolkit`
- `vibe-forge-pack`
- `vibe-stack-starter`
- `VibeOps-Automation`
- `api-center`
- `azure-ai-travel-agents`
- `student-athlete-handbook`

## Profile repository

- **KEEP:** `daa25/daa25`
- Purpose: professional GitHub profile README and portfolio directory
- Never delete this repository

## Final presentation standard

A public flagship repository should have:

- Clear product name and one-sentence value proposition
- Professional README
- Screenshots or product preview
- Current status
- Stack and architecture summary
- Setup instructions where appropriate
- Live demo or release link when available
- No fake customer claims, sample leads presented as real, or exposed credentials

## Actions requiring GitHub settings access

The connected GitHub tools can edit code, documentation, branches, issues, and pull requests, but do not currently expose repository-level archive or permanent-delete controls. Repositories listed above for archive/delete must be completed from **Repository Settings → General → Danger Zone**. The decisions in this file are approved cleanup instructions.