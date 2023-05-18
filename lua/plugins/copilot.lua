local enable_copilot_statusline = false

return {
  {
    "github/copilot.vim",
    event = "VeryLazy",
    config = function()
      -- For copilot.vim
      -- enable copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
      }

      vim.cmd([[
        let g:copilot_assume_mapped = v:true
      ]])

      -- setup keymap
      local keymap = vim.keymap.set
      -- Silent keymap option
      local opts = { silent = true }

      -- Copilot
      keymap("i", "<C-j>", "<Plug>(copilot-next)", opts)
      keymap("i", "<C-k>", "<Plug>(copilot-previous)", opts)
      keymap("i", "<C-l>", "<Plug>(copilot-suggest)", opts)
    end,
  },
  -- add status line icon for copilot
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      if enable_copilot_statusline then
        local Util = require("lazyvim.util")
        table.insert(opts.sections.lualine_x, 2, {
          function()
            local icon = require("lazyvim.config").icons.kinds.Copilot
            return icon
          end,
          cond = function()
            local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot", bufnr = 0 })
            return ok and #clients > 0
          end,
          color = function()
            return Util.fg("Special")
          end,
        })
      end
    end,
  },
}
