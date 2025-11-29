# Migrations

One-time migration scripts for environment changes that need to run exactly once.

## Structure

```
migrations/
├── global/                    # Migrations for all profiles
│   └── YYYY-MM-DD-name.zsh
└── profiles/                  # Profile-specific migrations
    ├── home/
    │   └── YYYY-MM-DD-name.zsh
    └── work/
        └── YYYY-MM-DD-name.zsh
```

## Usage

### Run all pending migrations
```bash
my migrate
```

### List all migrations and their status
```bash
my migrate --list
```

### Run a specific migration (by partial name match)
```bash
my migrate --run keepassxc
```

### Force re-run all migrations (use with caution)
```bash
my migrate --force
```

## Creating a Migration

1. Create a new `.zsh` file in the appropriate directory:
   - `migrations/global/` for all profiles
   - `migrations/profiles/{profile}/` for specific profile

2. Use the naming convention: `YYYY-MM-DD-description.zsh`

3. Write your migration script:

```zsh
#!/usr/bin/env zsh

################################################################################
# Migration: Brief description
# Date: YYYY-MM-DD
# Description: Detailed explanation of what this migration does
################################################################################

source $MY/core/utils/ui-kit.zsh

# Your migration commands here
ui_info_simple "Doing something..."
your-command-here

ui_success_simple "Migration completed"
```

4. Test with: `my migrate --run description`

## Migration Tracking

- Completed migrations are logged in `logs/migrations.log`
- Each migration ID is: `{context}/{filename}` (e.g., `work/2024-11-29-keepassxc-reinstall`)
- Migrations won't re-run unless forced or the log is cleared

## Examples

### Global migration (runs on all machines)
`migrations/global/2025-11-29-update-brew-taps.zsh`

### Profile-specific migration (runs only on work profile)
`migrations/profiles/work/2025-11-29-keepassxc-reinstall.zsh`

## Migration Lifecycle

### How Migrations Run

1. **Automatic during update**: `my update` runs pending migrations automatically
2. **Manual execution**: `my migrate` runs all pending migrations
3. **One-time execution**: Each migration runs exactly once per machine
4. **Self-destruct**: Migration file auto-deletes after successful execution
5. **Tracking**: Completed migrations are logged in `logs/migrations.log`

### How Tracking Works

When a migration completes successfully:
- Its ID (e.g., `work/2025-11-29-keepassxc-reinstall`) is added to `logs/migrations.log`
- **The migration file itself is automatically deleted** (self-destruct)
- Before running, the system checks if the ID exists in the log
- If found, the migration is skipped (even if file exists elsewhere)
- If not found, the migration runs

**Why auto-delete?**
- Migrations are for **current machines only**, not fresh installs
- After it runs once, the file is no longer needed
- Prevents clutter and confusion
- Tracking log persists forever, preventing re-execution

Example `logs/migrations.log`:
```
global/2025-11-29-test-migration
work/2025-11-29-keepassxc-reinstall
home/2025-12-01-cleanup-old-configs
```

### Migration Lifecycle Management

**Auto-cleanup**: Migrations automatically delete themselves after running successfully.

**What happens:**
1. You create and commit a migration file
2. Machine A runs it → file auto-deletes on Machine A, tracking log updated
3. Machine B pulls it from git → runs it → file auto-deletes on Machine B
4. Machine C (fresh install) pulls it from git → runs it → file auto-deletes
5. Eventually, no machines have the file anymore (all ran it)

**For git:**
- You commit the migration initially
- Each machine deletes its local copy after running
- Eventually someone can commit the deletion (or let git clean handle it)
- The tracking log prevents re-execution even if the file reappears

**No manual cleanup needed!** The system handles it automatically.

### Behavior During Updates

When you run `my update`:
- ✅ If there are **pending migrations**: Shows full section with visible output
- ✅ If there are **no pending migrations**: Completely silent (no section shown)
- ❌ If a migration **fails**: Update stops with an error message

This means:
- First time on a new machine: You'll see the migration section and all output
- Subsequent updates: Completely silent if nothing pending
- You always know what's happening when migrations run

### Git Workflow

**Migration files (.zsh)**: ✅ **Committed to git**
- These are the scripts that define what to run
- Shared across all machines via git
- Create them, commit them, push them

**Tracking log (`logs/migrations.log`)**: ❌ **NOT in git** (gitignored)
- This is your local machine's state
- Tracks which migrations YOU have run on THIS machine
- Each machine maintains its own tracking log

**Workflow example:**
```bash
# On your main machine:
1. Create migration: migrations/profiles/work/2025-11-29-keepassxc-reinstall.zsh
2. Git commit and push the .zsh file
3. Run `my update`
   → Migration executes
   → File auto-deletes locally
   → Tracking log updated: "work/2025-11-29-keepassxc-reinstall"

# On your work laptop:
4. Run `my update`
   → Pulls the .zsh file from git
   → Migration executes (not in YOUR tracking log yet)
   → File auto-deletes locally
   → Tracking log updated: "work/2025-11-29-keepassxc-reinstall"

# Both machines now have:
   ✓ No .zsh file (auto-deleted on both)
   ✓ Different logs/migrations.log files (local, gitignored)
   ✓ Both logs say "completed" for this migration

# In git:
   ✓ Still has the .zsh file (until someone commits the deletion)
   ✓ Or it gets deleted by next `git add -u` on any machine
```

**Key point**: Files self-destruct after running, but tracking persists forever.

## Common Questions

### Do I need to commit anything after a migration runs?

**Initial commit**: ✅ Commit the `.zsh` file when you create it

**After it runs**: 🤔 Optional
- The file auto-deletes locally after running
- You can `git add -u` to commit the deletion (optional)
- Or leave it in git for other machines to pull
- Either way works - tracking log prevents re-execution

**Never commit:**
- ❌ The tracking log (`logs/migrations.log`) - gitignored and local-only

### Will migrations run on all my machines?

**Yes!** When you:
1. Create a migration on Machine A
2. Commit and push it to git
3. Run `my update` on Machine B
4. Machine B pulls the migration file and executes it

Each machine tracks independently which migrations it has run.

### What if I accidentally delete my tracking log?

Don't worry! If `logs/migrations.log` is deleted:
- All migrations will be marked as "pending" again
- They will re-run on next update
- Most migrations should be idempotent (safe to re-run)
- Or just manually rebuild the log if you know what's been done

## Best Practices

- **Keep migrations small and focused** on one task
- **Use descriptive names** with dates (YYYY-MM-DD format)
- **Add comments** explaining **why** the migration is needed
- **Test before committing**: `my migrate --run <name>` to test specific ones
- **Make migrations idempotent** if possible (safe if they somehow re-run)
- **Use UI kit functions** for consistent, beautiful output
- **Commit the .zsh file** when you create it (initial commit only)
- **Let auto-cleanup handle the rest** - no manual maintenance needed
- **Never commit** the tracking log (`logs/migrations.log`)
