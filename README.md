# .github

This is a [special `.github` repository](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file). It serves as the centralized home for default community health files and shared configurations that apply across all repositories under this account.

## What Makes `.github` Special

GitHub treats a repository named `.github` differently from regular repositories:

- **Default community health files** — Files like `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SUPPORT.md`, `SECURITY.md`, and `FUNDING.yml` placed here automatically apply to all other repositories that don't define their own versions.
- **Default issue & PR templates** — Issue templates and pull request templates in `.github/ISSUE_TEMPLATE/` and `.github/PULL_REQUEST_TEMPLATE/` serve as fallback templates for all repositories.
- **Organization/user profile README** — A `profile/README.md` in this repo is displayed on the organization or user profile page.

> [!NOTE]
> Default files are not physically present in other repositories — they don't appear in file browsers, git history, clones, or downloads. GitHub displays them as links to this repo when a repository lacks its own version.

> [!NOTE]
> `LICENSE` files cannot be shared as defaults. Each repository must include its own license.

## Tooling

- **Formatting**: `pnpm run format` — Prettier for JS/TS, AutoCorrect for CJK text spacing
- **Linting**: `pnpm run lint` — ESLint for JS/TS
- **Git hooks**: Husky + lint-staged for pre-commit checks
