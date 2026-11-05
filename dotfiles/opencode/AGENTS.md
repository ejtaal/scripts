## Git Commit Workflow
When the user asks to commit changes:
1. Show the colored diff (or clean diff with syntax highlighting if colors aren't available) for all staged changes
2. Show a proposed commit message
3. Wait for explicit approval before actually running `git commit`
4. Never auto-commit without the user saying "yes", "commit", or similar approval

## Compaction
When the user asks to compact, wait until any current operation is fully finished before triggering it.
