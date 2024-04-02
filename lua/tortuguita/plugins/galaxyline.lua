local galaxyline = {}
local alias = {
  n = {
    label = "Nrm",
    icon = " "
  },
  i = {
    label = "Ins",
    icon = "󰗧 "
  },
  c = {
    label = "Cmd",
    icon = " "
  },
  v = {
    label = "Vis",
    icon = " "
  },
  V = {
    label = "VLn",
    icon = " "
  },
  [""] = {
    label = "VBk",
    icon = " "
  }
}

function galaxyline.statusline()
  return {
    "nvimdev/galaxyline.nvim",
    config = function()
      galaxyline.setup()
    end,
    dependencies = {
      'kyazdani42/nvim-web-devicons'
    },
  }
end

function galaxyline.setup()
  vim.opt.ruler = false
  vim.opt.showmode = false

  local gl = require('galaxyline')
  local gls = gl.section

  gls.left[1] = galaxyline.vi_mode()
  gls.left[2] = galaxyline.project()

  gls.right[1] = galaxyline.filename()
  gls.right[2] = galaxyline.git_branch()
end

function galaxyline.vi_mode()
  return {
    ViMode = {
      provider = function()
        local output = vim.fn.mode()
        local mode = alias[output]
        if mode ~= nil then
          output = mode.label
        end
        return output
      end,
      icon = function()
        return alias[vim.fn.mode()].icon
      end,
      separator = " _ ",
    }
  }
end

function galaxyline.project()
  return {
    FirstElement = {
      provider = function()
        return vim.fn.fnamemodify(vim.loop.cwd(), ':t')
      end,
      icon = function()

      end,
      separator = " ",
    }
  }
end

function galaxyline.filename()
  local condition = require('galaxyline.condition')
  return {
    FileName = {
      provider = function()
        local value = vim.fn.expand('%:~:.')
        if string.len(value) > 40 then
          return '...' .. string.sub(value, -40)
        end
        return value
      end,
      condition = condition.buffer_not_empty,
    }
  }
end

function galaxyline.git_branch()
  local condition = require('galaxyline.condition')
  return {
    GitBranch = {
      provider = function()
        return require("galaxyline.providers.vcs").get_git_branch()
      end,
      icon = ' ',
      condition = condition.check_git_workspace,
      separator = ' ',
    },
  }
end

function galaxyline.colorscheme()
  local ofirkai = require('ofirkai.design').scheme
  return {
    bg = ofirkai.background,
    fg = ofirkai.status_line.a_fg,
    fg_alt = ofirkai.status_line.inactive,
    yellow = ofirkai.yellow,
    cyan = ofirkai.aqua,
    green = ofirkai.green,
    orange = ofirkai.orange,
    magenta = ofirkai.purple,
    blue = ofirkai.blue,
    red = ofirkai.red,
  }
end

return galaxyline
