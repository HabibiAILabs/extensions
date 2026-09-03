# Essentials

Essentials provides the small, general-purpose tool set needed to inspect and modify files or run
commands within Habibi's global boundaries:

- `essentials.ls` — list at most 500 directory entries.
- `essentials.read` — read at most 2,000 lines and 48 KiB of UTF-8 text.
- `essentials.edit` — atomically replace one exact text block with stale-write protection.
- `essentials.find` — find paths recursively by name using an approved `find` executable.
- `essentials.grep` — recursively search bounded UTF-8 files for literal text.
- `essentials.bash` — run `bash -lc` in the bounded Linux process sandbox.

Enable filesystem and process access by configuring **Settings → Boundaries**. Exact and wildcard
rules are shared by every capable extension. The most specific matching rule wins; includes win ties.
`find` and `bash` must be allowed by the program boundary. Shell access is powerful: programs launched
by Bash are constrained by the sandbox mount and network boundaries, not by the initial program-name
rule.

Process output is bounded to 32 KiB per stream. Essentials read and list results are independently
bounded to prevent tool results from overflowing later model context.

Habibi's process host is currently Linux-only. A PowerShell tool should be registered instead of Bash
when a Windows sandbox host exists; Essentials does not advertise an unavailable tool today.
