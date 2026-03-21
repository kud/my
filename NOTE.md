# Work Machine — Resync After History Rewrite

The `my` repo history was rewritten (2026-03-20) to remove a committed `.notes.json` file.

Run this on the work machine to resync:

```zsh
git -C "$MY" fetch origin
git -C "$MY" reset --hard origin/main
git -C "$MY" fetch --tags --force
```

Then delete this file.
