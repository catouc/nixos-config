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
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
	type = "lua";
	config = ''
	  local lspconfig = require('lspconfig')
	  lspconfig.rust_analyzer.setup{
	    settings = {
              highlightingOn = false;
	    }
	  }
	  lspconfig.gopls.setup{}
          vim.api.nvim_create_autocmd('LspAttach', {
	    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	    callback = function(ev)
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
    ];
  };
}
