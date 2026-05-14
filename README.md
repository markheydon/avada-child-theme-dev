# Avada Child Theme Source Files

## Overview

This repository contains the development source and tooling for an Avada child theme starter.

The starter structure is based on Avada's official child theme documentation:

- https://avada.com/documentation/avada-child-theme/

This repo is focused on local development workflow (dev container, coding standards, and test setup), not distribution of the Avada parent theme.

## Source and Licensing Notes

This project does not include the Avada parent theme itself. Avada should be obtained and licensed through ThemeFusion.

For the child-theme starter files in this repo, licensing depends on the originating code and your own additions. In practice:

- Keep upstream notices and attribution where applicable.
- Treat WordPress-derived code as GPL-compatible.
- Add an explicit license only for code you author and have rights to license.

This public repository includes a [NOTICE](NOTICE) file clarifying that this is an Avada child-theme development source repo and that Avada trademarks/theme files remain the property of their owners.

## Development Files

This repo includes VS Code Container files so this project can be worked on locally or via Codespaces. The general idea being, the files can be developed and tested before being released back into the release repo for use as a template. In a nutshell, all the files in the `src/` folder should end up in the release repo.

WordPress Standard Coding checking is included via `PHPCS` as well, run `composer install` on the command line to install it otherwise errors will be reported about phpcs missing.

This repo does not contain the Avada theme, it should be obtained through normal channels and installed onto this site before activating the child theme.

### Running PHP Code Sniffer

To run PHP Code Sniffer, after running `composer install`, use the following command in the terminal:

```bash
vendor/bin/phpcs --standard=WordPress src/
```	

## Container Files

Once up and running, the `/workspace/wordpress` folder is the site root in this devcontainer, and `/workspace/src` is mapped to `/var/www/html/wp-content/themes/Avada-Child-Theme` in the `wordpress` container.

### PHP Version Pinning

The dev container now pins WordPress to a PHP 8.4 base image via `.devcontainer/Dockerfile`:

- `ARG WORDPRESS_IMAGE=wordpress:php8.4-apache`

This avoids the floating `wordpress` default tag, which can point to a lower PHP release than your project requirement.

If you change image tags or Dockerfile base images, rebuild the container so changes take effect:

1. Rebuild and reopen the dev container from VS Code.
2. Run `php -v` to verify PHP 8.4 is active.
3. Run `composer update` again.

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
