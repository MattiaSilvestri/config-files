--- @type LazySpec
return {
  "andymass/vim-matchup",
  event = "User AstroFile",
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
    vim.g.matchup_matchparen_deferred = 1
  end,
}
