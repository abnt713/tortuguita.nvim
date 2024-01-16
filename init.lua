vim.g.mapleader = " "
vim.g.dapleader = "\\"

local dapkey = function(combo)
  return vim.g.dapleader .. combo
end

require('tortuguita.main').main({
  border_style = 'rounded',
  editor = {
    map = {
      file_reference = '<Leader>fr',
      next_git_hunk = '<Leader>gn',
      prev_git_hunk = '<Leader>gp',
      colorize = '<Leader>cc'
    },
  },
  file_tree = {
    map = {
      toggle = '<Leader>ft',
    },
  },
  lsp = {
    map = {
      code_action = 'ga',
      hover_symbol = 'gh',
      goto_declaration = 'gD',
      rename = 'gm',
      goto_definition = 'gd',
      signature_help = 'gs',
      references = 'gr',
      goto_implementation = 'gi',
      show_symbol_diagnostic = 'gl',
      next_diagnostic = 'gn',
      prev_diagnostic = 'gp',
      trouble_project = 'gt',
      trouble_document = 'gT',
    }
  },
  debug = {
    map = {
      continue = dapkey('c'),
      open_repl = dapkey('r'),
      breakpoint = dapkey('b'),
      conditional_breakpoint = dapkey('<s-b>'),
      list_breakpoints = dapkey('l'),
      hover_widget = dapkey('h'),
    }
  },
  fuzzy = {
    map = {
      files = '<Leader>ff',
      grep = '<Leader>fg',
      buffers = '<Leader>fb',
      file_browser = '<Leader>fe',
    },
  },
  linter = {
    map = {
      toggle_revive = 'gq'
    }
  },
  git = {
    map = {
      panel = '<Leader>gs',
      commit = '<Leader>gc',
      blame = '<Leader>gb',
    }
  },
  lang = {
    cpp = {
      map = {
        toggle_header = 'gt'
      }
    },
    go = {
      map = {
        show_impl = '<Leader>gi'
      }
    }
  },
  md_preview = {
    app = { 'wfirefox', '--new-window' }
  }
})
