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

- Absolute Git state-change ban: never run, trigger, schedule, or
  approve any command, script, API call, UI action, or tool invocation that can
  change Git history, refs, branches, tags, remotes, the index, the stash, or
  the current checked-out branch or commit. This includes commits, pushes,
  pulls, fetches, rebases, merges, branch switches, tag operations, stash
  operations, staging, remote configuration changes, or similar actions. This
  prohibition is absolute and has no escalation or approval exception.
- Absolute sensitive material change ban: never create, edit, overwrite, move,
  delete, decrypt, generate, rotate, or otherwise modify secrets, private keys,
  tokens, kubeconfigs, Terraform state files, state backups, local credentials,
  or other sensitive material. Never reveal their contents. This prohibition is
  absolute and has no escalation or approval exception.
- Keep changes small, direct, and related to the task.
- Do not refactor unrelated code.
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

## Commit Messages

When asked for commit message text:

- Check the current diff first.
- Base the commit message on the actual diff, not on conversation context.
- Write it in simple English.
- Use Conventional Commits format: `<type>(<scope>): <description>`.
- Use `<type>` for the change type, for example `feat`, `fix`, `docs`,
  `refactor`, or `chore`.
- Use `<scope>` for the affected area or component.
- Use `<description>` for a short summary.

## Repository Notes

- Terraform code is in `terraform/`.
- Ansible code is in `ansible/`.
- Setup and common commands are in `INSTALL.md`.

## Additional Instructions

Add new repository instructions below this line.
