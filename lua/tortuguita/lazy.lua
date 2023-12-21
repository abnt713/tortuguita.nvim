local lazy = {}

function lazy.load()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    lazy.install(lazypath)
  end
  vim.opt.rtp:prepend(lazypath)
end

function lazy.install(lazypath)
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

function lazy.setup(plugins, border)
  local opts = {
    ui = {
      border = border
    }
  }
  require("lazy").setup(plugins, opts)
end

return lazy
