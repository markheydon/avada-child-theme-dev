---
name: Rebrand Child Theme
description: Update child-theme identity, slug/path mapping, and project metadata in one consistent pass based on RUNBOOK rebrand guidance.
argument-hint: Provide theme_name, theme_slug, text_domain, author, author_uri, gtm_required, and optional prefix_old/prefix_new
---

## When to use this prompt

- When creating a new child theme from this template and you need to rename/rebrand it safely.
- When your local theme slug/path is changing and you want to avoid path-mapping mistakes.
- Before release prep, to ensure naming and metadata are consistent.

## What you'll get

- A single guided rebrand pass across all relevant files.
- A short pre-edit plan before any changes are applied.
- A mandatory confirmation checkpoint before any edits are applied.
- A post-edit summary of what changed and what was intentionally left unchanged.
- Quick validation checks for consistency.

## Inputs required

Collect and confirm these values before editing:

- `theme_name` (WordPress admin display name)
- `theme_slug` (folder/path slug)
- `text_domain`
- `author`
- `author_uri`
- `gtm_required` (`yes` or `no`)
- `prefix_old` (optional; default `mhcg_`)
- `prefix_new` (optional; only if prefix rebrand requested)
- `security_contact_url` (optional; only if known)

If any required value is missing, ask for it and stop edits until provided.

## Step 1 - Present change plan first

Before editing files, show a short plan table based on the resolved inputs:

```
| Area | Files | Planned updates |
|------|-------|-----------------|
| Theme identity | src/style.css, src/functions.php, src/inc/gtm-helpers.php (only if GTM retained) | Theme labels, author, text domain, naming comments |
| Slug/path mapping | .devcontainer/docker-compose.yml, .vscode/launch.json | Theme mount path and Xdebug pathMappings |
| Metadata | composer.json, .devcontainer/devcontainer.json, phpcs.xml, SECURITY.md | Package/display/security metadata |
| GTM handling | src/functions.php, src/inc/gtm-helpers.php, src/parts/gtm-head-code.html, src/parts/gtm-body-code.html | Keep or remove GTM scaffolding based on gtm_required |
| Optional prefix | src/functions.php, src/inc/gtm-helpers.php (only if GTM retained), README.md | Prefix rename notes/usages if requested |
```

## Step 2 - Require explicit confirmation before edits

After the plan table, present a short resolved values summary and include this exact instruction:

`Please reply with 'confirm' to go ahead.`

Do not edit any files until the user replies with `confirm`.

## Step 3 - Apply GTM decision first

If `gtm_required` is `no`, remove GTM scaffolding before other edits:

1. `src/functions.php`
  - Remove `require_once get_theme_file_path( 'inc/gtm-helpers.php' );`.
  - Remove `add_action( 'wp_head', 'mhcg_add_gtm_data_layer', 1 );`.
  - Remove `add_action( 'wp_head', 'mhcg_add_gtm_head_code', 2 );`.
  - Remove `add_filter( 'avada_before_body_content', 'mhcg_add_gtm_to_body', 1 );`.

2. Delete these files:
  - `src/inc/gtm-helpers.php`
  - `src/parts/gtm-head-code.html`
  - `src/parts/gtm-body-code.html`

If `gtm_required` is `yes`, keep GTM files and hooks in place.

## Step 4 - Update theme identity files

1. `src/style.css`
  - Update `Theme Name` to `theme_name`.
  - Update `Author` and `Author URI`.
  - Update `Text Domain` to `text_domain`.

2. `src/functions.php`
  - Update project/package naming comments where applicable.
  - Update text-domain literals if present and rebrand-related.

3. `src/inc/gtm-helpers.php` (only when `gtm_required` is `yes`)
  - Update project/package naming comments where applicable.
  - Update text-domain literals if present and rebrand-related.

## Step 5 - Update slug/path-dependent files together

If `theme_slug` differs from current slug, update all path mappings in the same pass:

1. `.devcontainer/docker-compose.yml`
  - Update the mounted theme path under `/var/www/html/wp-content/themes/...`.

2. `.vscode/launch.json`
  - Update Xdebug `pathMappings` target path for the same slug.

Never update only one of these files.

## Step 6 - Update project metadata

1. `composer.json`
  - Update package name/description to match the rebrand.

2. `.devcontainer/devcontainer.json`
  - Update container display name if project naming changed.

3. `phpcs.xml`
  - Update ruleset name/description if project naming changed.

4. `SECURITY.md`
  - Update security reporting URL/contact if provided.

## Step 7 - Optional prefix rebrand

Only if explicitly requested:

- Rename function prefix from `prefix_old` to `prefix_new` in:
  - `src/functions.php`
  - `src/inc/gtm-helpers.php` (only when `gtm_required` is `yes`)
- Update any related notes in `README.md` where applicable.

If not requested, keep existing prefix and state that it was intentionally unchanged.

## Step 8 - Validation

After edits:

1. Re-open all changed files and verify:
  - `theme_name`, `theme_slug`, and `text_domain` are consistent.
  - Slug/path mapping matches in both `.devcontainer/docker-compose.yml` and `.vscode/launch.json`.
  - GTM decision was applied correctly:
    - If `gtm_required` is `no`, GTM hooks are removed from `src/functions.php` and GTM files were deleted.
    - If `gtm_required` is `yes`, GTM files/hooks are retained.

2. Run repository lint/check commands that are already documented and available.
  - Prefer minimal relevant checks.
  - If a check cannot run, report why.

3. Provide a final summary table:

```
| File | Change summary |
|------|----------------|
| ...  | ...            |
```

Include a short "Not changed" list for optional areas you intentionally skipped.

## Rules

- Do not make edits until required inputs are confirmed.
- Do not make edits until the user replies with `confirm`.
- Keep changes scoped to rebrand and path-alignment concerns.
- Do not refactor unrelated code.
- If expected values are ambiguous, ask before editing.
- Preserve existing formatting/style in touched files.
