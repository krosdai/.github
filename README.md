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
    types: [opened, ready_for_review, reopened, synchronize]

permissions:
  actions: read
  contents: read
  id-token: write
  issues: write
  pull-requests: write

jobs:
  review:
    if: >-
      github.event.pull_request &&
      !github.event.pull_request.draft &&
      github.event.pull_request.head.repo.full_name == github.repository
    uses: krosdai/.github/.github/workflows/code-review.yml@v1
    with:
      pr_number: ${{ github.event.pull_request.number }}
      is_draft: ${{ github.event.pull_request.draft }}
      head_repo_full_name: ${{ github.event.pull_request.head.repo.full_name }}
    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

`head_repo_full_name` is required rather than optional so the same-repo check fails closed if a caller forgets to pass it.

Prerequisites:

1. Install the [Claude GitHub App](https://github.com/apps/claude)
2. Add `ANTHROPIC_API_KEY` to repository secrets (or organization secrets for all repos)
3. Add `ANTHROPIC_API_KEY` **again** under Dependabot secrets — see below
4. (Optional) Set `ANTHROPIC_BASE_URL` as a repository **variable** (not secret) if routing through a proxy like [LiteLLM](https://github.com/BerriAI/litellm)

The workflow skips draft PRs and fork PRs, has a 15-minute timeout, and follows the review guidelines defined in [`REVIEW.md`](REVIEW.md).

#### Reviewing Dependabot PRs

Two separate things have to be right, and only one of them lives in this repo.

`claude-code-action` aborts on any actor that is not a `User`, so bot-authored PRs need an allow-list. The `allowed_bots` input covers this and **defaults to `dependabot[bot]`** — nothing to configure for the common case. To widen it, add `allowed_bots: "dependabot[bot],renovate[bot]"` to the `with:` block above, or pass `'*'` for every bot.

Passing an empty string does _not_ disable bot reviews — GitHub expressions treat `''` as falsy, so it falls through to the default. Gate the job in your calling workflow instead.

The other half is a GitHub platform behavior that no workflow change can work around: **Dependabot-triggered runs read secrets from the Dependabot store, not the Actions store.** A key that only exists as an Actions secret arrives as an empty string, and the review fails on an unauthenticated API call rather than anything obviously secret-related. Look for `Secret source: Dependabot` in the run log. Add the key to both stores:

```sh
gh secret set ANTHROPIC_API_KEY --org krosdai --app actions    --visibility all
gh secret set ANTHROPIC_API_KEY --org krosdai --app dependabot --visibility all
```

Repository **variables** such as `ANTHROPIC_BASE_URL` are not partitioned this way and resolve normally.

## Tooling

- **Formatting**: `pnpm run format` — Prettier for JS/TS, AutoCorrect for CJK text spacing
- **Linting**: `pnpm run lint` — ESLint for JS/TS
- **Git hooks**: Husky + lint-staged for pre-commit checks
