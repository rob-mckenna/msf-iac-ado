# Architecture Decision Records

Architecture Decision Records (ADRs) document the major technical and platform decisions made for this reference architecture.

## ADR Process

- ADRs are numbered sequentially using a zero-padded prefix, for example `0001`, `0002`, and `0003`.
- Create each ADR as a standalone markdown file using the standard template format.
- Update ADR status as the decision evolves.

## Status Values

Use one of the following statuses in every ADR:

- `Proposed`
- `Accepted`
- `Deprecated`
- `Superseded`

## Template Format

Each ADR should follow this structure:

```md
# ADR 000X: Title

## Status
Accepted

## Date
2026-05-27

## Context
Describe the problem, constraints, and drivers.

## Decision
Describe the chosen approach.

## Consequences
Describe the trade-offs, follow-up impacts, and operational implications.
```
