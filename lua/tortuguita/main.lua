local main = {}

function main.main(cfg)
  local editor = require('tortuguita.editor')
  editor.default_opts()
  editor.numbers_and_lines()
  editor.indentation()
  editor.map_cc_to_esc()

  local utils = require('tortuguita.utils')
  utils.map_file_reference(cfg.editor.map.file_reference)

  -- Installing Lazy.nvim
  local lazy = require('tortuguita.lazy')
  lazy.load()

  -- Setting up plugins
  local plugins = {
    require('tortuguita.plugins.ui').colorscheme(),
    require('tortuguita.plugins.ui').statusline(),
    require('tortuguita.plugins.ui').indent_guides(),
    require('tortuguita.plugins.ui').gitgutter(cfg.editor),
    require('tortuguita.plugins.ui').file_tree(cfg.file_tree),

    require('tortuguita.plugins.editor').commentary(),
    require('tortuguita.plugins.editor').hardmode(),
    require('tortuguita.plugins.editor').project_config(),
    require('tortuguita.plugins.editor').assets_manager(cfg.border_style),
    require('tortuguita.plugins.fuzzy').file_explorer(cfg.fuzzy),
    require('tortuguita.plugins.fuzzy').base(cfg.fuzzy),

    require('tortuguita.plugins.lang').cpp_toggle(cfg.lang.cpp),
    require('tortuguita.plugins.lang').go_impl(cfg.lang.go),

    require('tortuguita.plugins.code').autocomplete(),
    require('tortuguita.plugins.code').treesitter(),
    require('tortuguita.plugins.code').linter(cfg.linter),

    require('tortuguita.plugins.lsp').engine(cfg.lsp),
    require('tortuguita.plugins.lsp').trouble(cfg.lsp),
    require('tortuguita.plugins.debug').dap(cfg.debug),

    require('tortuguita.plugins.tools').git(cfg.git),
    require('tortuguita.plugins.tools').colorizer(cfg.editor),
    require('tortuguita.plugins.tools').md_preview(cfg.md_preview),
  }

  lazy.setup(plugins, cfg.border_style)
end

return main
