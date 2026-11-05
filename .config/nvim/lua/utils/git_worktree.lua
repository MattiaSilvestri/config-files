-- Switch between git worktrees, each one backed by its own nvim-possession session.
-- Switching saves the current session, wipes every buffer/tab/window, `cd`s into the
-- worktree and then loads its session (or creates a new empty one named `<repo>@<branch>`).
local M = {}

-- Must match nvim-possession's `sessions.sessions_path` / `sessions.sessions_variable`
local sessions_path = vim.fn.stdpath("data") .. "/sessions/"
local sessions_variable = "session"
local title = "Worktree"

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = title })
end

local function git(args, cwd)
	local res = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
	if res.code ~= 0 then
		return nil, vim.trim(res.stderr or "")
	end
	return res.stdout
end

-- Directory used to run git commands: cwd if it's inside a repo, else the current file's dir
local function repo_cwd()
	local cwd = vim.fn.getcwd()
	if git({ "rev-parse", "--git-dir" }, cwd) then
		return cwd
	end
	local file_dir = vim.fn.expand("%:p:h")
	if file_dir ~= "" and vim.fn.isdirectory(file_dir) == 1 and git({ "rev-parse", "--git-dir" }, file_dir) then
		return file_dir
	end
	return nil
end

---@class Worktree
---@field path string
---@field branch? string
---@field head? string
---@field detached? boolean
---@field bare? boolean
---@field locked? boolean
---@field prunable? boolean

---@return Worktree[]|nil, string|nil
function M.list(cwd)
	local out, err = git({ "worktree", "list", "--porcelain" }, cwd)
	if not out then
		return nil, err
	end
	local worktrees, cur = {}, nil
	for line in (out .. "\n"):gmatch("(.-)\n") do
		if line == "" then
			if cur then
				table.insert(worktrees, cur)
				cur = nil
			end
		else
			local key, val = line:match("^(%S+)%s?(.*)$")
			if key == "worktree" then
				cur = { path = val }
			elseif cur then
				if key == "branch" then
					cur.branch = val:gsub("^refs/heads/", "")
				elseif key == "HEAD" then
					cur.head = val
				elseif key == "detached" or key == "bare" or key == "locked" or key == "prunable" then
					cur[key] = true
				end
			end
		end
	end
	if cur then
		table.insert(worktrees, cur)
	end
	return worktrees
end

-- The first entry of `git worktree list` is always the main worktree (or the bare repo)
local function repo_name(worktrees)
	return (vim.fs.basename(worktrees[1].path):gsub("%.git$", ""))
end

local function session_name(repo, wt)
	local ref = wt.branch or vim.fs.basename(wt.path)
	return (repo .. "@" .. ref):gsub("[/\\:]", "-")
end

local function same_path(a, b)
	return vim.fs.normalize(vim.fn.resolve(a)) == vim.fs.normalize(vim.fn.resolve(b))
end

-- Close everything and leave a single empty buffer. Returns false if the user cancelled.
local function reset_editor()
	local modified = vim.tbl_filter(function(buf)
		return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].modified
	end, vim.api.nvim_list_bufs())
	if #modified > 0 then
		local choice = vim.fn.confirm(#modified .. " unsaved buffer(s)", "&Save all\n&Discard\n&Cancel", 3)
		if choice == 1 then
			local ok, err = pcall(vim.cmd.wall)
			if not ok then
				notify("Could not save all buffers: " .. err, vim.log.levels.ERROR)
				return false
			end
		elseif choice ~= 2 then
			return false
		end
	end

	vim.cmd("silent! tabonly!")
	vim.cmd("silent! only!")
	vim.cmd.enew()
	local keep = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= keep and vim.api.nvim_buf_is_valid(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	-- Stop LSP clients left without buffers (they belong to the previous worktree)
	vim.schedule(function()
		for _, client in ipairs(vim.lsp.get_clients()) do
			if vim.tbl_isempty(client.attached_buffers) then
				client:stop()
			end
		end
	end)
	return true
end

-- Show the Snacks dashboard in place of the empty buffer when there are no file buffers
local function open_dashboard_if_empty()
	local has_files = vim.iter(vim.api.nvim_list_bufs()):any(function(buf)
		return vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
	end)
	local buf = vim.api.nvim_get_current_buf()
	if has_files or vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified then
		return
	end
	local ok, snacks = pcall(require, "snacks")
	if ok and snacks.dashboard then
		snacks.dashboard.open({ buf = 0, win = 0 })
	end
end

local function save_current_session()
	local cur = vim.g[sessions_variable]
	if cur == nil then
		return
	end
	pcall(vim.cmd, "ScopeSaveState")
	vim.cmd.mksession({ args = { sessions_path .. cur }, bang = true })
end

---Switch to worktree `wt`, loading (or creating) its possession session
---@param wt Worktree
---@param repo string
function M.switch(wt, repo)
	if vim.fn.isdirectory(wt.path) == 0 then
		notify("Worktree path does not exist: " .. wt.path, vim.log.levels.ERROR)
		return
	end
	local name = session_name(repo, wt)
	if vim.g[sessions_variable] == name and same_path(vim.fn.getcwd(), wt.path) then
		notify("Already on " .. name)
		return
	end

	save_current_session()
	if not reset_editor() then
		return
	end
	vim.cmd.cd(vim.fn.fnameescape(wt.path))

	vim.fn.mkdir(sessions_path, "p")
	local file = sessions_path .. name
	if vim.uv.fs_stat(file) then
		vim.cmd.source(vim.fn.fnameescape(file))
		vim.g[sessions_variable] = name
		pcall(vim.cmd, "ScopeLoadState")
		notify("Loaded session " .. name)
	else
		vim.cmd.mksession({ args = { file }, bang = true })
		vim.g[sessions_variable] = name
		notify("New session " .. name .. "\n" .. wt.path)
	end
	open_dashboard_if_empty()
end

---Create a new worktree (new or existing branch) and switch to it
---@param cwd? string
function M.create(cwd)
	cwd = cwd or repo_cwd()
	if not cwd then
		notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end
	local worktrees, err = M.list(cwd)
	if not worktrees then
		notify(err or "git worktree list failed", vim.log.levels.ERROR)
		return
	end
	local repo = repo_name(worktrees)
	local main = worktrees[1].path

	vim.ui.input({ prompt = "Branch: " }, function(branch)
		if not branch or vim.trim(branch) == "" then
			return
		end
		branch = vim.trim(branch)
		local default_path = vim.fs.joinpath(vim.fs.dirname(main), repo .. "-" .. branch:gsub("[/\\:]", "-"))
		vim.ui.input({ prompt = "Path: ", default = default_path, completion = "dir" }, function(path)
			if not path or vim.trim(path) == "" then
				return
			end
			path = vim.fs.normalize(vim.fn.fnamemodify(vim.trim(path), ":p")):gsub("/$", "")

			local args
			if git({ "show-ref", "--verify", "--quiet", "refs/heads/" .. branch }, cwd) then
				args = { "worktree", "add", path, branch }
			elseif git({ "show-ref", "--verify", "--quiet", "refs/remotes/origin/" .. branch }, cwd) then
				args = { "worktree", "add", "--track", "-b", branch, path, "origin/" .. branch }
			else
				args = { "worktree", "add", "-b", branch, path }
			end
			local _, add_err = git(args, cwd)
			if add_err then
				notify("git worktree add failed:\n" .. add_err, vim.log.levels.ERROR)
				return
			end
			M.switch({ path = path, branch = branch }, repo)
		end)
	end)
end

---Remove worktree `wt` (asks for confirmation, retries with --force if needed)
---@param wt Worktree
---@param cwd string
function M.remove(wt, cwd)
	if same_path(vim.fn.getcwd(), wt.path) then
		notify("Cannot remove the worktree you are in", vim.log.levels.WARN)
		return
	end
	if vim.fn.confirm("Remove worktree " .. wt.path .. "?", "&Yes\n&No", 2) ~= 1 then
		return
	end
	local _, err = git({ "worktree", "remove", wt.path }, cwd)
	if err then
		if vim.fn.confirm(err .. "\nForce remove?", "&Yes\n&No", 2) ~= 1 then
			return
		end
		_, err = git({ "worktree", "remove", "--force", wt.path }, cwd)
		if err then
			notify(err, vim.log.levels.ERROR)
			return
		end
	end
	notify("Removed " .. wt.path)
end

---Pick a worktree with fzf-lua. enter: switch, ctrl-n: new worktree, ctrl-x: remove
function M.pick()
	local cwd = repo_cwd()
	if not cwd then
		notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end
	local worktrees, err = M.list(cwd)
	if not worktrees then
		notify(err or "git worktree list failed", vim.log.levels.ERROR)
		return
	end
	local repo = repo_name(worktrees)

	local entries, by_entry = {}, {}
	local width = 0
	for _, wt in ipairs(worktrees) do
		if not wt.bare then
			local label = wt.branch or ("(detached " .. (wt.head or ""):sub(1, 8) .. ")")
			wt.label = label
			width = math.max(width, vim.fn.strdisplaywidth(label))
		end
	end
	for _, wt in ipairs(worktrees) do
		if not wt.bare then
			local marker = same_path(vim.fn.getcwd(), wt.path) and "*" or " "
			local flags = (wt.locked and " [locked]" or "") .. (wt.prunable and " [prunable]" or "")
			local entry = string.format("%s %-" .. width .. "s  %s%s", marker, wt.label, vim.fn.fnamemodify(wt.path, ":~"), flags)
			table.insert(entries, entry)
			by_entry[entry] = wt
		end
	end

	local function selected_wt(selected)
		return selected and selected[1] and by_entry[selected[1]]
	end

	require("fzf-lua").fzf_exec(entries, {
		prompt = "Worktrees> ",
		winopts = { title = " " .. repo .. " worktrees ", title_pos = "center", height = 0.4, width = 0.6 },
		fzf_opts = { ["--header"] = "enter: switch | ctrl-n: new worktree | ctrl-x: remove", ["--no-multi"] = true },
		actions = {
			["enter"] = function(selected)
				local wt = selected_wt(selected)
				if wt then
					M.switch(wt, repo)
				end
			end,
			["ctrl-n"] = function()
				M.create(cwd)
			end,
			["ctrl-x"] = function(selected)
				local wt = selected_wt(selected)
				if wt then
					M.remove(wt, cwd)
				end
			end,
		},
	})
end

vim.api.nvim_create_user_command("Worktree", function(opts)
	if opts.args == "" then
		return M.pick()
	end
	local cwd = repo_cwd()
	local worktrees = cwd and M.list(cwd)
	if not worktrees then
		notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end
	for _, wt in ipairs(worktrees) do
		if not wt.bare and (wt.branch == opts.args or same_path(wt.path, vim.fn.fnamemodify(opts.args, ":p"))) then
			return M.switch(wt, repo_name(worktrees))
		end
	end
	notify("No worktree matching " .. opts.args, vim.log.levels.WARN)
end, {
	nargs = "?",
	desc = "Switch git worktree (with possession session)",
	complete = function()
		local cwd = repo_cwd()
		local worktrees = cwd and M.list(cwd) or {}
		local items = {}
		for _, wt in ipairs(worktrees) do
			if not wt.bare then
				table.insert(items, wt.branch or wt.path)
			end
		end
		return items
	end,
})

return M
