# Code Review Guidelines

## Always check

- Logic errors, off-by-one bugs, and incorrect boundary conditions
- Security vulnerabilities (injection, XSS, SSRF, secrets in code, etc.)
- Race conditions and concurrency issues
- Error handling: unhandled exceptions, swallowed errors, missing edge cases
- API contract violations: mismatched types, missing required fields
- Database migrations are backward-compatible

## Style

- Prefer early returns over deeply nested conditionals
- Use structured logging, not string interpolation in log calls
- Keep functions focused — flag functions doing too many things

## Skip

- Formatting-only changes (handled by Prettier / linters)
- Auto-generated files and lock files (`pnpm-lock.yaml`, etc.)
- Minor naming preferences that don't affect readability
