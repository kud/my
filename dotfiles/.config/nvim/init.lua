-- =============================================================================
-- 🚀 Modern Neovim Configuration (inspired by kickstart.nvim)
-- =============================================================================
-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- ⚙️ Basic Neovim Settings
-- =============================================================================
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Basic editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.guifont = "JetBrainsMono Nerd Font:h14"

-- =============================================================================
-- 🔌 Plugin Configuration with lazy.nvim
-- =============================================================================
require("lazy").setup({
  -- 🎨 Colorscheme
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        colorscheme = "onedark",
        options = {
          transparency = false,
        },
        plugins = {
          neo_tree = true,
        },
      })
      vim.cmd.colorscheme("onedark")
    end,
  },

  -- 🔍 Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })

      -- Enable telescope fzf native, if installed
      pcall(require("telescope").load_extension, "fzf")

      -- Telescope keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<C-f>", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<C-b>", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })
      vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Find current word" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })
    end,
  },

  -- 🌳 Treesitter (syntax highlighting & parsing)
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "go", "lua", "python", "rust", "tsx", "javascript", "typescript", "vimdoc", "vim", "bash",
          "html", "css", "json", "yaml", "markdown", "markdown_inline"
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- 🔧 Mason (LSP installer)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "eslint",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "bashls",
        },
      })
    end,
  },

  -- 💬 Autocompletion (must be loaded before LSP)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        },
      })
    end,
  },

  -- 🔧 LSP Configuration (loaded after cmp)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim",
    },
    config = function()
      -- Neodev setup for better Lua development
      require("neodev").setup()

      -- LSP settings
      local on_attach = function(_, bufnr)
        local nmap = function(keys, func, desc)
          if desc then
            desc = "LSP: " .. desc
          end
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
        nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        nmap("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
        nmap("gr", require("telescope.builtin").lsp_references, "Goto References")
        nmap("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
        nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type Definition")
        nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
        nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
        nmap("gD", vim.lsp.buf.declaration, "Goto Declaration")
      end

      -- Setup language servers with capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Configure specific language servers directly
      local lspconfig = require("lspconfig")

      -- Get installed servers from mason-lspconfig
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        ts_ls = {},
        eslint = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
      }

      -- Setup each server
      for server, config in pairs(servers) do
        lspconfig[server].setup(vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, config))
      end
    end,
  },

  -- 🤖 GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_filetypes = {
        gitcommit = true,
        markdown = true,
        yaml = true,
      }

      -- Copilot keymaps
      vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Enable Copilot" })
      vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Disable Copilot" })
      vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", { desc = "Copilot Status" })
    end,
  },

  -- 📁 File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false,
        window = {
          mappings = {
            ["<space>"] = "none",
          },
        },
      })
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
    end,
  },

  -- ⚡ Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          vim.keymap.set("n", "<leader>hp", require("gitsigns").preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
          vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { buffer = bufnr, desc = "Reset git hunk" })
          vim.keymap.set("n", "<leader>hs", require("gitsigns").stage_hunk, { buffer = bufnr, desc = "Stage git hunk" })
        end,
      })
    end,
  },

  -- 🤖 GitHub Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = false, -- Enable debugging
      model = "gpt-4o", -- GPT model to use
      auto_follow_cursor = false, -- Don't follow the cursor after getting response
      show_help = false, -- Show help in virtual text
      window = {
        layout = "vertical",
        width = 0.4,
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      chat.setup(opts)

      -- Setup keymaps
      vim.keymap.set("n", "<leader>cc", ":CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
      vim.keymap.set("v", "<leader>cc", ":CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
      vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain code" })
      vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain selected code" })
      vim.keymap.set("n", "<leader>cr", ":CopilotChatReview<CR>", { desc = "Review code" })
      vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", { desc = "Review selected code" })
      vim.keymap.set("n", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix code" })
      vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix selected code" })
      vim.keymap.set("n", "<leader>co", ":CopilotChatOptimize<CR>", { desc = "Optimize code" })
      vim.keymap.set("v", "<leader>co", ":CopilotChatOptimize<CR>", { desc = "Optimize selected code" })
      vim.keymap.set("n", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests" })
      vim.keymap.set("v", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests for selection" })

      -- Custom prompts
      vim.keymap.set("n", "<leader>cp", function()
        local input = vim.fn.input("Ask Copilot: ")
        if input ~= "" then
          chat.ask(input, { selection = select.buffer })
        end
      end, { desc = "Ask custom prompt" })

      vim.keymap.set("v", "<leader>cp", function()
        local input = vim.fn.input("Ask Copilot: ")
        if input ~= "" then
          chat.ask(input, { selection = select.visual })
        end
      end, { desc = "Ask custom prompt about selection" })
    end,
  },

  -- 🔧 Copilot.lua for better integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false, -- We use CopilotChat instead
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<Tab>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
      })
    end,
  },

  -- 💅 Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = false,
          theme = require("lualine.themes.onedark"),
          component_separators = "|",
          section_separators = "",
        },
      })
    end,
  },

  -- 🔄 Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- 💬 Comments
  {
    "numToStr/Comment.nvim",
    config = true,
  },

  -- 🎯 Which-key (shows keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup()
    end,
  },
}, {})

-- =============================================================================
-- ⌨️ Additional Keymaps
-- =============================================================================
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save and quit" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- =============================================================================
-- 🎨 Highlight on yank
-- =============================================================================
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})
