# Code Review Policy

This file is the single source of truth for every automated code review agent in
this repository.

## Review scope

- Review changes for code quality, correctness, and security
- Analyze the diff in the context of the full codebase
- Report only actionable findings that are specific and important
- Keep the review concise: report at most 10 findings total

## Severity and reporting threshold

- **P0 — Critical:** an immediately exploitable vulnerability, irreversible data
  loss, or a failure with similarly catastrophic impact
- **P1 — Blocking/high risk:** an issue that can cause serious incorrect
  behavior, security exposure, or operational failure and should block merging
- **P2 — Meaningful:** a substantive correctness, reliability, compatibility,
  or maintainability issue worth fixing, but without P0 or P1 impact
- **P3 — Minor:** a low-impact improvement, nit, or preference

For code findings, report only P0, P1, and P2 issues. Skip P3 issues entirely;
never inflate or reframe a minor issue as P2 to make it reportable.

For findings in documentation rather than code, report only verifiable factual
errors with P0 or P1 impact. Do not report P2-or-lower documentation issues,
including minor inaccuracies, incomplete detail, wording, tone, or style. This
higher threshold prevents documentation review from blocking CI convergence on
non-critical details.

## Always check

- Logic errors, off-by-one bugs, and incorrect boundary conditions
- Security vulnerabilities (injection, XSS, SSRF, secrets in code, etc.)
- Race conditions and concurrency issues
- Error handling: unhandled exceptions, swallowed errors, missing edge cases
- API contract violations: mismatched types, missing required fields
- Database migrations are backward-compatible

## Authoring preferences (not review findings)

The following preferences guide new code, but violations are not review
findings on their own. Do not report them as style findings or inflate them to
P2. If one directly causes a reportable correctness, security, reliability, or
compatibility problem, report the underlying problem instead.

- Prefer early returns over deeply nested conditionals
- Use structured logging, not string interpolation in log calls
- Keep functions focused

## Skip

- Formatting-only changes (handled by Prettier / linters)
- Auto-generated files, lock files (`pnpm-lock.yaml`, etc.), and vendored code
- Minor naming preferences that don't affect readability
- Style-only issues covered by the authoring preferences above
