# AGENTS.md

These instructions apply to the whole repository.

If a subdirectory has its own `AGENTS.md`, follow the more specific file for
that subdirectory.

## Before Modifying Files

Before modifying any file:

- Read the current version from disk.
- Verify the file has not changed unexpectedly.
- Apply a minimal diff.
- Never overwrite user changes without explicit confirmation.

## Working Rules

- Keep changes small, direct, and related to the task.
- Do not refactor unrelated code.
- Do not commit changes unless the user asks for a commit.
- Do not edit secrets, private keys, tokens, generated kubeconfigs, Terraform
  state files, or local credentials.
- Prefer existing project patterns over new conventions.
- Run relevant checks when the required tools are available.

## Generated Code Style

- Match the style of nearby files before adding new code.
- Follow the user's current approach instead of introducing a different design.
- Keep generated code simple, explicit, and easy to maintain.
- Prefer small focused changes over broad abstractions.
- Use the same naming, formatting, file layout, and command style already used
  in this repository.
- If the local style is unclear, ask before making a large style decision.

## Repository Notes

- Terraform code is in `terraform/`.
- Ansible code is in `ansible/`.
- Setup and common commands are in `INSTALL.md`.

## Additional Instructions

Add new repository instructions below this line.
