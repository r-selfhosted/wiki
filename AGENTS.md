# AGENTS.md

## Project Overview
This repository is the official r/SelfHosted wiki, a Retype-powered documentation site for people learning about and contributing self-hosting guides. The content is mostly Markdown with Retype YAML navigation/front matter, plus a small Bash helper for icon normalization and a Docker image that serves the static build with Apache httpd.

## Repository Structure
```text
.
|-- .github/workflows/        # GitHub Actions for Docker image build/publish and deployment backup
|-- _components/icon/fa/      # Custom Retype Font Awesome SVG icons
|-- _includes/                # Retype include files, including custom head HTML
|-- contributing/             # Contributor documentation and Retype section metadata
|-- guides/                   # Self-hosting guide content grouped by topic
|-- learn/                    # Introductory self-hosting learning pages
|-- scripts/                  # Maintenance scripts; currently icon normalization
|-- static/                   # Static assets such as the favicon
|-- Dockerfile                # Production static-site image build
|-- index.md                  # Site homepage content
|-- retype.yml                # Retype site configuration, branding, links, and output path
`-- README.md                 # Project intro and custom icon notes
```

## Environment Setup
1. Install Retype. The contributor docs point to the official Retype setup guide for general use.
2. On macOS ARM64, this checkout includes local npm tooling for Retype 4.6.0. Run `npm install` from the repository root if `node_modules/` is missing.
3. No application environment variables are required. Site configuration lives in `retype.yml`.
4. When adding or replacing custom SVG icons, place them under `_components/icon/<pack>/<name>.svg` and run `bash scripts/normalize-icons.sh`.

## Build & Run
- Local preview: `npm run start` starts Retype and serves the wiki, usually at `http://127.0.0.1:5000/`.
- Production build: `npm run build` runs `prebuild`, which normalizes icons, then runs `retype build` into `.retype/`.
- Direct icon normalization: `npm run icons:normalize`.
- Docker build: `docker build . --file Dockerfile --tag wiki`. The Dockerfile installs Retype 4.6.0 with the .NET 10 SDK, normalizes icons, builds the static site into `.docker-build/`, and serves it from `httpd:2.4`.

## Testing
There is no separate automated test suite. Treat `npm run build` as the required validation for content, navigation, Retype front matter, and custom icon changes. GitHub Actions also validates the production Docker path on pushes to `main` by running `docker build`.

## Code Style & Conventions
- Write pages in Markdown with Retype front matter. Regular pages should use a clear `label`, `icon: dot`, and `title` only when the full page title should differ from the sidebar label.
- Keep content friendly, practical, beginner-aware, and concise. Explain technical terms the first time a beginner may not know them.
- Use headings in order; do not skip from `##` to `####`.
- Use descriptive link text. Prefer internal links for wiki pages, lowercase paths, and trailing slashes, such as `/guides/software/virtual-private-networks/wireguard/`.
- Use fenced code blocks with language tags for commands and configuration. Use inline code for filenames, commands, package names, and configuration keys.
- Run `npm run build` before submitting changes that affect content, navigation, Retype config, icons, or Docker build behavior.

## Architecture Notes
- Retype builds from `input: .` and writes generated output to `.retype/`; do not edit generated files.
- Content is organized by top-level section folders. Each section uses `index.yml` for folder-level navigation metadata and `.md` files for pages.
- Custom Retype icons are resolved from `_components/icon/<pack>/<name>.svg` as `<pack>-<name>` in `retype.yml`. Font Awesome icons must be normalized to a `24x24` wrapper with `scripts/normalize-icons.sh`.
- The production container does not rely on the local npm Retype package. Docker installs `retypeapp` via `dotnet tool install retypeapp --version 4.6.0 --tool-path /bin`.
- The published static site is served by Apache httpd from `/usr/local/apache2/htdocs/`.

## Commit & PR Conventions
- No strict branch naming or commit message convention is documented in this repository.
- Keep PRs focused on one content or infrastructure change at a time.
- Before opening a PR, verify the wiki builds with `npm run build`; for Docker or CI changes, also run `docker build . --file Dockerfile --tag wiki` when Docker is available.
- GitHub Actions builds and pushes `ghcr.io/r-selfhosted/wiki:latest` on pushes to `main`.

## Things to Avoid
- Do not edit `.retype/`, `.docker-build/`, `retype.manifest`, `node_modules/`, or other generated/local dependency output.
- Do not add unnormalized Font Awesome SVGs; run `bash scripts/normalize-icons.sh` after icon changes.
- Do not use mixed-case wiki links or paths when lowercase paths are available; case drift can break Retype navigation on case-sensitive systems.
- Do not place a new page in a new folder unless the folder will be useful for more than one page.
- Do not bypass `index.yml` when adding or reorganizing sections; Retype navigation depends on the section metadata.
- Do not assume the local npm Retype package is the production source of truth; the Dockerfile owns the production Retype installation path.
