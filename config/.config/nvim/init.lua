vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ========================================================================== --
-- ==                            GENERAL SETTINGS                          == --
-- ========================================================================== --
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.wrap = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- ========================================================================== --
-- ==                             FUZZY SEARCH                             == --
-- ========================================================================== --
-- 1. Keep wildignore strictly for your :e and command-line completions
vim.opt.wildignore:append({
  "*/.git/*",
  "*/node_modules/*",
  "*/target/*",
  "*/out/*",
  "*/build/*",
  "*/dist/*",
})

-- 2. Clean Netrw hide list (No dotfile hider so your .config is always visible)
vim.g.netrw_list_hide = [[node_modules/,target/,out/,build/,dist/]]

-- 3. FIX: Clear wildignore locally inside Netrw so it doesn't choke
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("netrw-wildignore-fix", { clear = true }),
  pattern = "netrw",
  callback = function()
    vim.opt_local.wildignore = ""
  end,
})

-- 4. Enable the popup menu (pum) and fuzzy matching for command-line completion
vim.o.wildoptions = "pum,fuzzy"
vim.o.wildmode = "noselect"

-- 5. NEOVIM 0.12 SUPERPOWER: Hook into findfunc for true interactive fuzzy finding
local project_root = vim.fn.getcwd()
local files_cache = {}
vim.o.path = ".,**," .. project_root

_G.native_find_picker = function(arg, flag)
  -- Gather files exactly once from the true project root folder
  if #files_cache == 0 then
    local cmd = "find " .. vim.fn.shellescape(project_root) .. " -type f " ..
        "-not -path '*/.git/*' " ..
        "-not -path '*/node_modules/*' " ..
        "-not -path '*/target/*' " ..
        "-not -path '*/out/*' " ..
        "-not -path '*/build/*'"
    local raw_files = vim.fn.systemlist(cmd)

    files_cache = {}
    for _, file in ipairs(raw_files) do
      -- Strip the absolute project root prefix to keep the completion menu clean
      local relative_file = file:sub(#project_root + 2)
      table.insert(files_cache, relative_file)
    end
  end

  -- Return ALL matching candidates and let Neovim's pum handle the scrolling
  if arg == "" then
    return files_cache
  else
    return vim.fn.matchfuzzy(files_cache, arg)
  end
end

-- Wire the custom picker into Neovim's native find engine
vim.o.findfunc = "v:lua.native_find_picker"

-- Smart cache invalidation: Only clear the find cache when a NEW file is saved
vim.api.nvim_create_autocmd("BufWritePost", {
  desc = "Clear fuzzy find cache when a new file is created",
  group = vim.api.nvim_create_augroup("smart-find-cache", { clear = true }),
  callback = function(args)
    if #files_cache == 0 then return end

    local saved_file = vim.fn.fnamemodify(args.match, ":.")
    local is_known_file = false

    for _, cached_file in ipairs(files_cache) do
      if cached_file == saved_file then
        is_known_file = true
        break
      end
    end

    if not is_known_file then
      files_cache = {}
    end
  end,
})

-- Auto-trigger completion popup as you type in the command-line
vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("cmdline-fuzzy-complete", { clear = true }),
  pattern = ":",
  callback = function()
    vim.fn.wildtrigger()
  end,
})

-- ========================================================================== --
-- ==                             BASIC KEYMAPS                            == --
-- ========================================================================== --
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>f", ":find ")
vim.keymap.set("n", "<leader>b", ":b ")

-- ========================================================================== --
-- ==                                AUTOCMDS                              == --
-- ========================================================================== --
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Auto-start Neovim native treesitter highlighting",
  group = vim.api.nvim_create_augroup("treesitter-auto-start", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- ========================================================================== --
-- ==             PLUGINS (Neovim 0.12 Native Package Management)          == --
-- ========================================================================== --
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/xiyaowong/transparent.nvim" },
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/Saghen/blink.cmp" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/sainnhe/everforest" },
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

-- 1. Blink.cmp Setup (Autocomplete)
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  blink.setup({
    keymap = { preset = "enter" },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      ghost_text = { enabled = false },
      menu = { border = "rounded", scrollbar = false },
      documentation = {
        window = {
          border = "rounded",
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDoc,Search:None",
          scrollbar = false,
        },
      },
    },
  })

  -- ======================================================================== --
  -- ==                      CUSTOM AUTOCOMPLETE COLORS                    == --
  -- ======================================================================== --
  -- 1. Mute the harsh white borders by linking them to your theme's Comment color
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "Comment" })
  vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "Comment" })

  -- 2. Make the typed letters that match suggestions pop using your accent color
  vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { link = "Special", bold = true })

  -- 3. FIX: Match the menu backgrounds directly to your main editor window
  -- vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "none" })
  -- vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "none" })

  -- 4. Make the documentation separator line transparent with white dashes
  -- vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { bg = "none", fg = "#ffffff" })
end

-- 2. Formatting Engine (Conform.nvim)
local has_conform, conform = pcall(require, "conform")
if has_conform then
  conform.setup({
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettier" },
      css = { "prettier" },
      go = { "lsp" },
      lua = { "lsp" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
  })
end

-- 3. Treesitter Setup (Modern Highlighting and Indentation)
local has_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if has_ts then
  ts_configs.setup({
    ensure_installed = { "html", "css", "javascript", "typescript", "tsx", "lua", "go" },
    -- Highlighting is now handled natively via the FileType autocmd above
    -- highlight = { enable = true },
    indent = { enable = true },
  })
end

-- 4. LSP & Mason Setup
local has_mason, mason = pcall(require, "mason")

if has_mason then
  -- Wrap both Mason AND the LSP configurations inside the schedule block.
  -- This ensures Mason registers its binary paths before Neovim tries to start the servers.
  vim.schedule(function()
    mason.setup()

    local capabilities = has_blink and blink.get_lsp_capabilities() or {}

    -- 1. Setup Lua LS
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- 2. Dynamically setup the rest
    local servers = { "gopls", "eslint", "html", "cssls", "ts_ls" }
    for _, server in ipairs(servers) do
      vim.lsp.config(server, { capabilities = capabilities })
      vim.lsp.enable(server)
    end
  end)
end

-- 5. Theme Setup

local use_theme = 'everforest'

-- Theme Options:
vim.g.everforest_background = 'medium'
vim.g.everforest_enable_italics = true

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  desc = "Automatically reload theme when the terminial theme switches",
  callback = function()
    vim.cmd.colorscheme(use_theme)
  end,
})
vim.cmd.colorscheme(use_theme)

-- 6. Transparency Setup
local has_transparent, transparent = pcall(require, "transparent")
if has_transparent then
  transparent.setup({
    -- Add the Blink UI elements here so transparent.nvim handles them automatically
    extra_groups = {
      "BlinkCmpMenu",
      "BlinkCmpMenuBorder",
      "BlinkCmpDoc",
      "BlinkCmpDocBorder",
      "BlinkCmpDocSeparator",
    },
  })
end

-- Modelines
-- vim: ts=2 sts=2 sw=2 et
