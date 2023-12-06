-- disable lsp-inlayhints and lsp lenf if that is nightly version, will remove when 0.10.0 is stable
local is_stable_version = true
if vim.fn.has("nvim-0.10.0") == 1 then
  is_stable_version = false
end

return {
  {
    "lvimuser/lsp-inlayhints.nvim",
    ft = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact", "svelte", "go" },
    enabled = is_stable_version,
    opts = {
      debug_mode = true,
    },
    config = function(_, options)
      vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
      vim.api.nvim_create_autocmd("LspAttach", {
        group = "LspAttach_inlayhints",
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end

          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          require("lsp-inlayhints").on_attach(client, bufnr)
        end,
      })
      require("lsp-inlayhints").setup(options)
      -- define key map for toggle inlay hints: require('lsp-inlayhints').toggle()
      vim.api.nvim_set_keymap(
        "n",
        "<leader>uh",
        "<cmd>lua require('lsp-inlayhints').toggle()<CR>",
        { noremap = true, silent = true, desc = "Toggle Inlay Hints" }
      )
    end,
  },
  {
    "rmagatti/goto-preview",
    opts = {
      default_mappings = false,
      -- default_mappings = false, and then you can map preview window with your favorite keymap
      -- nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
      -- nnoremap gpD <cmd>lua require('goto-preview').goto_preview_declaration()<CR>
      -- nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
      -- nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
      -- nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>
      -- nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>
    },
    keys = {
      -- Preview definition
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview Definition" },
      -- Preview declaration
      { "gpD", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", desc = "Preview Declaration" },
      -- Preview type definition
      {
        "gpt",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        desc = "Preview Type Definition",
      },
      -- Preview implementation
      {
        "gpi",
        "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
        desc = "Preview Implementation",
      },
      -- Close all preview windows
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Preview Windows" },
      -- Hover doc with native lsp
      { "gh", vim.lsp.buf.hover, desc = "Hover Doc" },
    },
  },
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    opts = {},
    config = true,
    enabled = false, -- Disable lspsaga, use goto-preview instead
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      -- Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" },
    },
    -- Group LspSaga keymap with prefix "gl"
    keys = {
      -- LSP finder - Find the symbol's definition
      { "glf", "<cmd>Lspsaga finder<CR>", desc = "LSP Finder" },
      -- Go to definition
      { "gld", "<cmd>Lspsaga goto_definition<CR>", desc = "Go to Definition" },
      -- Go to type definition
      { "glt", "<cmd>Lspsaga goto_type_definition<CR>", desc = "Go to Type Definition" },
      -- Toggle Outline
      { "glo", "<cmd>Lspsaga outline<CR>", desc = "Toggle Outline" },
      -- Peek definition
      { "glp", "<cmd>Lspsaga peek_definition<CR>", desc = "Peek Definition" },
      -- Hover Doc
      { "glh", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc" },
    },
  },
  {
    "Wansmer/symbol-usage.nvim",
    event = is_stable_version and "LspAttach" or "BufReadPre",
    opts = function()
      local function h(name)
        return vim.api.nvim_get_hl(0, { name = name })
      end

      -- hl-groups can have any name
      vim.api.nvim_set_hl(0, "SymbolUsageRounding", { fg = h("CursorLine").bg, italic = true })
      vim.api.nvim_set_hl(0, "SymbolUsageContent", { bg = h("CursorLine").bg, fg = h("Comment").fg, italic = true })
      vim.api.nvim_set_hl(0, "SymbolUsageRef", { fg = h("Function").fg, bg = h("CursorLine").bg, italic = true })
      vim.api.nvim_set_hl(0, "SymbolUsageDef", { fg = h("Type").fg, bg = h("CursorLine").bg, italic = true })
      vim.api.nvim_set_hl(0, "SymbolUsageImpl", { fg = h("@keyword").fg, bg = h("CursorLine").bg, italic = true })

      local function text_format(symbol)
        local res = {}

        local round_start = { "", "SymbolUsageRounding" }
        local round_end = { "", "SymbolUsageRounding" }

        if symbol.references then
          local usage = symbol.references <= 1 and "usage" or "usages"
          local num = symbol.references == 0 and "no" or symbol.references
          table.insert(res, round_start)
          table.insert(res, { "󰌹 ", "SymbolUsageRef" })
          table.insert(res, { ("%s %s"):format(num, usage), "SymbolUsageContent" })
          table.insert(res, round_end)
        end

        if symbol.definition then
          if #res > 0 then
            table.insert(res, { " ", "NonText" })
          end
          table.insert(res, round_start)
          table.insert(res, { "󰳽 ", "SymbolUsageDef" })
          table.insert(res, { symbol.definition .. " defs", "SymbolUsageContent" })
          table.insert(res, round_end)
        end

        if symbol.implementation then
          if #res > 0 then
            table.insert(res, { " ", "NonText" })
          end
          table.insert(res, round_start)
          table.insert(res, { "󰡱 ", "SymbolUsageImpl" })
          table.insert(res, { symbol.implementation .. " impls", "SymbolUsageContent" })
          table.insert(res, round_end)
        end

        return res
      end

      return {
        references = { enabled = true, include_declaration = false },
        definition = { enabled = false },
        implementation = { enabled = false },
        text_format = text_format,
      }
    end,
  },
}
