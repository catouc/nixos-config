{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      syntax off
      set number
      set splitright
      set splitbelow
      set clipboard=unnamedplus
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
              vim.lsp.enable('rust-analyzer')
          	  vim.lsp.config('rust_analyzer', {
          	    settings = {
                  ['rust-analyzer'] = {
                    highlightingOn = false
                  }
          	    }
          	  })

          	  vim.lsp.enable('gopls')
          	  vim.lsp.enable('nixd')

              vim.opt.clipboard = 'unnamedplus'
              vim.api.nvim_create_autocmd('LspAttach', {
          	    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          	    callback = function(ev)
                  -- Disable syntax highlighting for good
                  -- client.server_capabilities.semanticTokensProvider = nil
          	      -- Enable completion triggered by <c-x><c-o>
                        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                        -- See `:help vim.lsp.*` for documentation on any of the below functions
                        local opts = { buffer = ev.buf }
          	      vim.keymap.set('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })
                        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          	      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          	      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          	      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          	      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          	      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          	    end,
          	  })
          	'';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Telescope find files' })
          vim.keymap.set('n', 'fg', builtin.live_grep, { desc = 'Telescope live grep' })
          vim.keymap.set('n', 'fb', builtin.buffers, { desc = 'Telescope buffers' })
        '';
      }
    ];
  };
}
