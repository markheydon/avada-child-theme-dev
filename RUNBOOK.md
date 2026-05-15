# Theme Template Runbook

This runbook is the detailed end-to-end guide for using this repository as a child-theme template and validating the distribution workflow.

Use [README.md](README.md) for quick-start basics and checklists.

## Scope

This repository has two responsibilities:

- Local development and quality tooling for the child theme source.
- Automated delivery of theme-only files from [src](src) using [theme-distribution.yml](.github/workflows/theme-distribution.yml).

The template also includes optional Google Tag Manager (GTM) helper scaffolding that can be retained or removed.

## End-To-End Path A: Create A New Child Theme From This Template

Optional fast path: use the GitHub Copilot prompt [.github/prompts/theme-rebrand.prompt.md](.github/prompts/theme-rebrand.prompt.md) to run this full rebrand flow in one guided pass.

### 1. Create your repository from this template

1. Create a new repository from this template.
2. Clone/open it in VS Code.
3. Reopen in Dev Container and wait for setup to complete.

### 2. Set your theme identity

Update these first:

1. [src/style.css](src/style.css)
	- Set `Theme Name` (display label in WordPress admin).
	- Set `Author` and `Author URI`.
	- Set `Text Domain` according to your translation approach.

2. [src/functions.php](src/functions.php)
	- Update package labels and project naming comments if needed.

3. [src/inc/gtm-helpers.php](src/inc/gtm-helpers.php)
	- Update package labels and project naming comments if needed.

### 3. Align your local theme slug/path

If your local theme folder slug changes, update all path-dependent files together:

1. [.devcontainer/docker-compose.yml](.devcontainer/docker-compose.yml)
	- Theme mount path under `/var/www/html/wp-content/themes/...`.

2. [.vscode/launch.json](.vscode/launch.json)
	- Xdebug `pathMappings` target path for the theme.

### 4. Rebrand project metadata (recommended)

1. [composer.json](composer.json)
	- Package `name` and description.

2. [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)
	- Container display name.

3. [phpcs.xml](phpcs.xml)
	- Ruleset display name and description.

4. [SECURITY.md](SECURITY.md)
	- Repository-specific security reporting URL.

### 5. Function prefix guidance

This template currently uses `mhcg_` for helper functions.

If this template will be reused across clients/projects, change function prefixes to your own organization/project prefix to reduce collision risk.

## End-To-End Path B: Configure Distribution

Distribution behavior is defined in [theme-distribution.yml](.github/workflows/theme-distribution.yml).

### 1. Understand triggers

- `release.published`: release automation path.
- `workflow_dispatch`: manual run path for testing/operations.

### 2. Configure Actions Variables (optional but recommended)

Set in repository settings under Actions Variables:

- `THEME_DESTINATION_REPO` (optional): `owner/repo` destination for sync.
- `THEME_SLUG` (optional): override theme folder slug for ZIP output.
- `THEME_CREATE_ZIP` (optional): `true` or `false` default for release runs.
- `THEME_SYNC_REPO` (optional): `true` or `false` default for release runs.

### 3. Configure Actions Secret for cross-repo sync

Set in repository settings under Actions Secrets:

- `THEME_SYNC_TOKEN` (required when pushing to another repo).

Use a token with permission to push to the destination repository.

## Optional Path: Remove GTM Integration

Use this when you do not need Google Tag Manager support in the child theme.

### 1. Remove GTM hooks from theme bootstrap

Edit [src/functions.php](src/functions.php) and remove:

- `require_once get_theme_file_path( 'inc/gtm-helpers.php' );`
- `add_action( 'wp_head', 'mhcg_add_gtm_data_layer', 1 );`
- `add_action( 'wp_head', 'mhcg_add_gtm_head_code', 2 );`
- `add_filter( 'avada_before_body_content', 'mhcg_add_gtm_to_body', 1 );`

### 2. Remove GTM helper/code files

Delete these files from [src](src):

- [src/inc/gtm-helpers.php](src/inc/gtm-helpers.php)
- [src/parts/gtm-head-code.html](src/parts/gtm-head-code.html)
- [src/parts/gtm-body-code.html](src/parts/gtm-body-code.html)

### 3. Validate theme behavior

After removal:

- Load front-end pages and verify there are no PHP fatal errors.
- Confirm no GTM markup/scripts are present in page source.
- Run lint checks to catch any accidental syntax issues.

### 4. Optional cleanup

If you are also rebranding function prefixes, remove or update any GTM-related prefix references from template notes in [README.md](README.md).

## End-To-End Path C: Test Distribution Safely

### 1. Branch-safe manual test (recommended first)

Run the workflow manually from Actions with `workflow_dispatch`.

Test set 1: ZIP-only

- `create_zip=true`
- `sync_repo=false`
- `destination_repo` left blank

Expected result:

- ZIP job runs.
- Artifact named `theme-package` is uploaded.
- ZIP contains only files staged from [src](src).

Test set 2: Sync-only to disposable target

- `create_zip=false`
- `sync_repo=true`
- `destination_repo` set to a disposable test repository

Expected result:

- Sync job pushes source theme files from [src](src) to destination repo root.
- `vendor/` is excluded from sync by workflow rule.

### 2. Release-path test

Publish a test release to validate release trigger behavior.

Expected result:

- ZIP suffix uses release tag.
- Sync runs only when destination is configured and sync is enabled.

### 3. Validate outputs

ZIP validation checklist:

- Archive has one top-level theme folder.
- Contents match [src](src) payload.
- No repository-level development files are included.

Sync validation checklist:

- Destination reflects [src](src) content after sync.
- Expected files are added/updated/removed.
- No unexpected repository metadata changes are pushed.

## Safety And Risk Notes

### `rsync --delete` behavior

Sync uses delete semantics and can remove files in the destination repository.

Always validate sync against a disposable destination first.

### Empty source guard

Workflow intentionally fails when [src](src) is missing or empty to avoid destructive sync/package runs.

### Composer behavior in distribution

ZIP packaging runs `composer install --no-dev` only when `src/composer.json` exists.

Repo sync excludes `vendor/` by design.

## Common Issues And Fixes

1. Sync job skipped unexpectedly
	- Check `sync_repo` value and destination configuration.
	- Confirm destination repo is set either in manual input or variable.

2. Cross-repo push fails
	- Confirm `THEME_SYNC_TOKEN` exists and has correct permissions.
	- Confirm destination repository name and owner are correct.

3. ZIP naming not as expected
	- Check `THEME_SLUG` and manual `theme_slug` input.
	- For release runs, confirm release tag value.

4. Local breakpoints not hitting in theme files
	- Re-check theme path alignment in [docker-compose.yml](.devcontainer/docker-compose.yml) and [launch.json](.vscode/launch.json).

5. WordPress asks for FTP credentials when installing plugin/theme ZIPs
	- Confirm `.devcontainer/setup.sh` completed successfully after container startup.
	- Verify `wp-content/themes` and `wp-content/plugins` are writable in the container and use expected ownership/modes.
	- Confirm `.devcontainer/docker-compose.yml` sets `WORDPRESS_CONFIG_EXTRA` with `FS_METHOD` set to `direct`.

## Pre-Release Checklist

1. Confirm theme metadata is correct in [src/style.css](src/style.css).
2. Confirm local slug/path alignment in [.devcontainer/docker-compose.yml](.devcontainer/docker-compose.yml) and [.vscode/launch.json](.vscode/launch.json).
3. Run lint checks locally.
4. Run manual ZIP-only distribution test.
5. Run manual sync-only test to disposable target (if sync will be used).
6. Review workflow logs for warnings/failures.
7. Publish release when checks pass.
