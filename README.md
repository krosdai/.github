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
    uses: krosdai/.github/.github/workflows/code-review.yml@v2
    with:
      pr_number: ${{ github.event.pull_request.number }}
      is_draft: ${{ github.event.pull_request.draft }}
      head_repo_full_name: ${{ github.event.pull_request.head.repo.full_name }}
```

`head_repo_full_name` is required rather than optional so the same-repo check fails closed if a caller forgets to pass it.

Prerequisites:

1. Install the [Claude GitHub App](https://github.com/apps/claude)
2. Keep `id-token: write` in the caller's `permissions`, as above. The review authenticates to the Claude API with [Workload Identity Federation](https://platform.claude.com/docs/en/manage-claude/wif-providers/github-actions): `claude-code-action` exchanges the run's GitHub OIDC token for a short-lived access token, so no `ANTHROPIC_API_KEY` secret is needed.
3. Make sure the organization's federation rule trusts the calling repository. The OIDC token carries the caller's subject, not this repository's, in one of two formats: `repo:<owner>/<repo>:pull_request`, or GitHub's [immutable format](https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims) `repo:<owner>@<owner-id>/<repo>@<repo-id>:pull_request` for repositories created, renamed, or transferred after July 15, 2026. Match on the `repository_owner_id` and `event_name` claims rather than a literal `repo:<owner>/` prefix so both formats pass. A run the rule rejects fails at the token exchange.

Requests go straight to `https://api.anthropic.com`. An `ANTHROPIC_BASE_URL` variable is ignored, because the federated access token is only valid against the Claude API.

The workflow skips draft PRs and fork PRs, has a 15-minute timeout, and follows the review guidelines defined in [`REVIEW.md`](REVIEW.md).

#### Migrating from `@v1`

`v2` replaces the `ANTHROPIC_API_KEY` secret with Workload Identity Federation. Point `uses:` at `@v2` and delete the `secrets:` block: `v2` no longer declares that secret, so passing it fails workflow validation. The `ANTHROPIC_API_KEY` secrets and the `ANTHROPIC_BASE_URL` variable can be removed once no caller is left on `@v1`.

#### Reviewing Dependabot PRs

`claude-code-action` aborts on any actor that is not a `User`, so bot-authored PRs need an allow-list. The `allowed_bots` input covers this and **defaults to `dependabot[bot]`** — nothing to configure for the common case. To widen it, add `allowed_bots: "dependabot[bot],renovate[bot]"` to the `with:` block above, or pass `'*'` for every bot.

Passing an empty string does _not_ disable bot reviews — GitHub expressions treat `''` as falsy, so it falls through to the default. Gate the job in your calling workflow instead.

Unlike `v1`, there is no API key to mirror into the Dependabot secret store: Dependabot-triggered runs read secrets from a separate store, but `v2` reads no secrets at all.

## Tooling

Run `mise install` after checkout to install the native AutoCorrect CLI used by
formatting and pre-commit hooks.

- **Formatting**: `pnpm run format` — Prettier for JS/TS, AutoCorrect for CJK text spacing
- **Linting**: `pnpm run lint` — ESLint for JS/TS
- **Git hooks**: Husky + lint-staged for pre-commit checks
