# MCP and Skills Library for Product Teams

This repository is a shared catalog where product teammates can publish and reuse MCPs and skills. Each item lives in its own folder with a short README, a `run.sh`, and any supporting files required to work.

## Structure

```
mcp/
  <name>/
    README.md
    run.sh
    ...supporting files
skills/
  <name>/
    README.md
    run.sh
    ...supporting files
```

## Conventions

- Folder names use `kebab-case`.
- Each item folder must include:
  - `README.md` with purpose, requirements, inputs/outputs, and usage.
  - `run.sh` as the entry point.
- Keep scripts safe by validating inputs and printing clear output messages.

## Running on Windows

`run.sh` works natively on macOS. On Windows, use Git Bash or WSL to run the scripts.

## Contributing

See `CONTRIBUTING.md` and the item template at `templates/ITEM_README_TEMPLATE.md`.
