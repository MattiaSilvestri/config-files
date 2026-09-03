#!/bin/sh
# Git log for lazygit's main "Log" view, with a marker on every commit that
# has a note in refs/notes/ai-context.
#
# lazygit runs git.branchLogCmd / git.allBranchesLogCmds through str.ToArgv,
# NOT through a shell, so pipes and $(...) cannot live in the config itself.
#
# Usage: ai-context-log.sh <branchName>
#        ai-context-log.sh --all

rev=${1:---all}

# --exclude keeps the refs/notes/* commits themselves out of the --all graph
git log --graph --color=always --abbrev-commit --decorate --date=relative \
	--exclude='refs/notes/*' \
	--pretty=format:'%C(auto)%h%d %s %C(dim white)(%ar) %an%x1f%H' "$rev" -- |
	awk -v notes="$(git notes --ref=ai-context list 2>/dev/null | cut -d' ' -f2 | tr '\n' ' ')" '
	BEGIN { split(notes, a, " "); for (i in a) if (a[i] != "") n[a[i]] = 1 }
	{
		i = index($0, "\037")
		if (i == 0) { print "   " $0; next }
		line = substr($0, 1, i - 1)
		hash = substr($0, i + 1)
		print ((hash in n) ? "\033[35m*\033[0m  " : "   ") line
	}
	'
