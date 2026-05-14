# Avada Child Theme Source Files

## Overview

These are the source files for the [Avada Child Theme](https://github.com/markheydon/avada-child-theme) repo used as a starting point template for any WordPress Avada Child Theme project.

See the [markheydon/Avada-Child-Theme](https://github.com/markheydon/avada-child-theme) repo for details of what's included, this repo only contains details of the development side of things.

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

Once up and running, the `~/wordpress` folder will be the root of the site, and the `~/src` folder will be mapped to `(site root)/wp-content/themes/Avada-Child-Theme`.

### PHP Version Pinning

The dev container now pins WordPress to a PHP 8.4 base image via `.devcontainer/Dockerfile`:

- `ARG WORDPRESS_IMAGE=wordpress:php8.4-apache`

This avoids the floating `wordpress` default tag, which can point to a lower PHP release than your project requirement.

If you change image tags or Dockerfile base images, rebuild the container so changes take effect:

1. Rebuild and reopen the dev container from VS Code.
2. Run `php -v` to verify PHP 8.4 is active.
3. Run `composer update` again.