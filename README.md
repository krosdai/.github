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

## Reusable Workflows

Unlike community health files, GitHub Actions workflows in the `.github` repo are **not** automatically inherited. Other repositories must explicitly call them as [reusable workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows).

### Claude Code Review

Automated PR review powered by [claude-code-action](https://github.com/anthropics/claude-code-action). To use it in another repository, create `.github/workflows/code-review.yml`:

```yaml
name: Code Review

on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

permissions:
  contents: read
  pull-requests: write
  id-token: write

jobs:
  review:
    uses: xdanger/.github/.github/workflows/claude-code-review.yml@main
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      ANTHROPIC_BASE_URL: ${{ secrets.ANTHROPIC_BASE_URL }} # optional, for proxies like LiteLLM
```

Prerequisites:

1. Install the [Claude GitHub App](https://github.com/apps/claude)
2. Add `ANTHROPIC_API_KEY` to repository secrets (or organization secrets for all repos)
3. (Optional) Add `ANTHROPIC_BASE_URL` if routing through a proxy like [LiteLLM](https://github.com/BerriAI/litellm)

The workflow skips draft PRs, has a 15-minute timeout, and follows the review guidelines defined in [`REVIEW.md`](REVIEW.md).

## Tooling

- **Formatting**: `pnpm run format` — Prettier for JS/TS, AutoCorrect for CJK text spacing
- **Linting**: `pnpm run lint` — ESLint for JS/TS
- **Git hooks**: Husky + lint-staged for pre-commit checks
