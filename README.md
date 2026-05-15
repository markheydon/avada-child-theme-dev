# Avada Child Theme Source Files

## Overview

This repository is intended for development only. Theme files for deployment are produced from the `src/` folder via the automated distribution workflow.

For a full end-to-end operational guide (template setup, renaming, distribution testing, and release validation), see [RUNBOOK.md](RUNBOOK.md).

Template feature note: this starter includes optional Google Tag Manager (GTM) helper scaffolding in `src/` that you can keep, adapt, or remove.

The Avada child theme starter structure is based on Avada's official child theme documentation:

- https://avada.com/documentation/avada-child-theme/

This repo is focused on local development environment (dev container, coding standards, and test setup), not distribution of the Avada parent theme.

## Quick Start

1. Create a new repository from this template.
2. Open the repository in VS Code.
3. Reopen in Dev Container.
4. Wait for container startup tasks to finish (including automatic WordPress setup via `.devcontainer/setup.sh`).
5. Visit `http://localhost:8080`.


### Admin Login

- Username: `admin`
- Password: `admin`

### Notes

- WordPress is configured with UK regional defaults on startup:
	- Language: `en_GB` (English UK)
	- Time zone: `Europe/London`
	- Date format: `j F Y` (for example `15 May 2026`)
	- Time format: `H:i` (24-hour format)
	- Week starts on: Monday
- Avada is a commercial product by ThemeFusion. Avada theme files are not included in this repository and must be obtained and licensed separately through official channels.

## Source and Licensing Notes

This project does not include the Avada parent theme itself. Avada should be obtained and licensed through ThemeFusion.

For the child-theme starter files in this repo, licensing depends on the originating code and your own additions. In practice:

- Keep upstream notices and attribution where applicable.
- Treat WordPress-derived code as GPL-compatible.
- Add an explicit license only for code you author and have rights to license.

This public repository includes a [NOTICE](NOTICE) file clarifying that this is an Avada child-theme development source repo and that Avada trademarks/theme files remain the property of their owners.

## Development Files

This repo includes VS Code Container files so this project can be worked on locally or via Codespaces. The general idea being, the files can be developed and tested before being released back into the release repo for use as a template. In a nutshell, all the files in the `src/` folder should end up in the release repo.

WordPress Standard Coding checking is included via `PHPCS` as well. In Dev Container workflows, Composer dependencies are installed automatically by `.devcontainer/setup.sh` during startup. If you are not using the container workflow, run `composer install` manually.

This repo does not contain the Avada theme, it should be obtained through normal channels and installed onto this site before activating the child theme.

### Coding Standards Commands

After dependencies are installed, use the Composer shortcuts for standards checking:

```bash
composer lint
```

Runs PHPCS using `phpcs.xml`.

```bash
composer lint:fix
```

Runs PHPCBF to auto-fix sniff violations where possible.

```bash
composer lint:php
```

Runs a PHP-only PHPCS scan with full reporting.

```bash
composer standards
```

Lists installed coding standards (useful for environment checks and debugging).

If you need to run PHPCS directly, you can still use:

```bash
vendor/bin/phpcs --standard=phpcs.xml
```

## Container Files

Once up and running, the `/workspace/wordpress` folder is the site root in this devcontainer, and `/workspace/src` is mapped to `/var/www/html/wp-content/themes/Avada-Child-Theme` in the `wordpress` container.

### Automated Setup Script

The `.devcontainer/setup.sh` startup script reduces initial setup time by automating:

- `composer install` for local tooling dependencies.
- WordPress install (if not already installed).
- Default local site/admin values for development.
- UK regional settings setup for local development:
	- UK English language install/activation (`en_GB`)
	- `Europe/London` timezone
	- UK-style date/time formats (`j F Y`, `H:i`)
	- Monday as first day of week

### Permissions Notes

The setup script ensures WordPress content directories are writable for both `wp-cli` operations and wp-admin uploads. In particular, it normalizes `wp-content/themes`, `wp-content/plugins`, `wp-content/uploads`, `wp-content/upgrade`, and `wp-content/languages` (including `wp-content/languages/plugins` and `wp-content/languages/themes`) permissions/ownership to avoid common local failures when uploading plugin/theme ZIP files or installing/updating translation packs.

The devcontainer Compose configuration also injects `FS_METHOD` as `direct` using `WORDPRESS_CONFIG_EXTRA` so containerized environments (including Codespaces) do not fall back to FTP credential prompts when direct filesystem writes are available.

The script is idempotent and can be re-run safely if needed.

### PHP Version Pinning

The dev container now pins WordPress to a PHP 8.4 base image via `.devcontainer/Dockerfile`:

- `ARG WORDPRESS_IMAGE=wordpress:php8.4-apache`

This avoids the floating `wordpress` default tag, which can point to a lower PHP release than your project requirement.

If you change image tags or Dockerfile base images, rebuild the container so changes take effect:

1. Rebuild and reopen the dev container from VS Code.
2. Run `php -v` to verify PHP 8.4 is active.
3. Run `composer update` again.

### Theme Upload Limits

The dev container sets higher PHP upload limits so WordPress admin theme ZIP uploads work in local development:

- `upload_max_filesize=128M`
- `post_max_size=128M`
- `memory_limit=256M`

If you change `.devcontainer/Dockerfile`, rebuild the dev container for those PHP settings to take effect.

### Mounting model

**Note**: The child theme folder is mounted separately over the WordPress tree, so changes to `src/` are reflected in the container without needing to rebuild. The mount structure is as follows:

- `../wordpress` is mounted to `/var/www/html` so WordPress core/theme/plugin files are visible locally for debugging.
- `../src` is mounted over `/var/www/html/wp-content/themes/Avada-Child-Theme` and is the source of truth for the child theme.

## Automated Theme Distribution

This template includes `.github/workflows/theme-distribution.yml` to automate delivery of **theme-only** files from `src/`.

### Supported modes

- **ZIP package mode**: creates a clean ZIP containing only the theme files from `src/`.
- **Repo sync mode**: optionally syncs only `src/` contents to a destination repo (for example a non-`-src` repo).

On each published release, ZIP generation is enabled by default. Repo sync runs when a destination repo is configured.

### Composer dependency behavior

- For ZIP packages, if `src/composer.json` exists, the workflow runs `composer install --no-dev` in the staged theme directory so runtime dependencies are included in the ZIP.
- For repo sync, `vendor/` is excluded so composer-installed dependencies are **not** synced to the destination repo.

### Configuration

Set these in repository **Variables** (Settings → Secrets and variables → Actions → Variables):

- `THEME_DESTINATION_REPO` (optional): destination in `owner/repo` format.
- `THEME_SLUG` (optional): theme folder name in the ZIP. Default is repo name without trailing `-src`.
- `THEME_CREATE_ZIP` (optional): `true`/`false` for release-triggered ZIP creation (default `true`).
- `THEME_SYNC_REPO` (optional): `true`/`false` for release-triggered repo sync (default `true`).

Set this in repository **Secrets** when syncing to another repo:

- `THEME_SYNC_TOKEN`: token with permission to push to the destination repository.

### Manual runs

Use **Actions → Theme Distribution → Run workflow** to override defaults per run:

- `destination_repo`: optional destination repo for sync
- `theme_slug`: optional override for ZIP theme folder name
- `create_zip`: enable/disable ZIP output
- `sync_repo`: enable/disable repo sync

## Using This Template For A New Child Theme

Use this quick checklist first, then follow [RUNBOOK.md](RUNBOOK.md) for full detail.

### Required updates

- Update WordPress theme header values in `src/style.css` (at minimum `Theme Name`, plus `Author`, `Author URI`, and `Text Domain` as needed).
- If you rename the local theme folder slug/path, update both mount/debug paths so local development still works:
	- `.devcontainer/docker-compose.yml`
	- `.vscode/launch.json`

### Recommended updates

- Rebrand package metadata in `composer.json`.
- Update project naming in `.devcontainer/devcontainer.json` and `phpcs.xml`.
- Replace project-specific function prefix usage (currently `mhcg_`) in `src/functions.php` and `src/inc/gtm-helpers.php` if this template will be reused broadly.

### Optional GTM integration

- GTM support in this template is optional.
- If your project does not use GTM, remove the GTM include/hooks from `src/functions.php` and remove GTM files in `src/inc/gtm-helpers.php`, `src/parts/gtm-head-code.html`, and `src/parts/gtm-body-code.html`.
- See [RUNBOOK.md](RUNBOOK.md) for a step-by-step removal checklist.

### Distribution naming behavior

- ZIP folder naming defaults to repository name with trailing `-src` removed.
- Override with `THEME_SLUG` variable (or `theme_slug` in manual run input) when needed.

## Testing Theme Distribution (Quick Path)

Use this short version for day-to-day checks. Use [RUNBOOK.md](RUNBOOK.md) for full validation steps and troubleshooting.

### What can be tested now

- The workflow supports manual `workflow_dispatch` runs from **Actions → Theme Distribution → Run workflow**.
- You can test ZIP-only, sync-only, or both, without creating a release.

### Fast test matrix

- ZIP-only test:
	- `create_zip=true`
	- `sync_repo=false`
	- `destination_repo` blank
- Sync-only test (safe mode):
	- `create_zip=false`
	- `sync_repo=true`
	- `destination_repo` set to a disposable test repository
- Release-path test:
	- publish a test release and verify tag-based ZIP naming.

### Safety note

- Sync uses `rsync --delete`; always test sync against a disposable destination repo before pointing to a production destination.
