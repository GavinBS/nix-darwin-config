vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 编辑体验
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.confirm = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- 缩进和显示
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.colorcolumn = "100"
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 5
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line,number"
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true

local function set_editor_highlights()
  -- 仅让主编辑区透出终端背景；浮窗与选区仍使用主题的正常背景。
  for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.bg = "NONE"
    vim.api.nvim_set_hl(0, group, highlight)
  end

  -- 不设置 CursorLine 背景，以便第 100 列参考线在当前行仍保持可见。
  vim.api.nvim_set_hl(0, "CursorLine", { underline = true, sp = "#6f8197", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true, fg = "#89b4fa" })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#263449" })
  vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#FAB387" })

  vim.api.nvim_set_hl(0, "StatusLine", { bold = true, fg = "#c4ccd8", bg = "#1b2230" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#8d9aae", bg = "#161d28" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { bold = true, fg = "#c4ccd8", bg = "#263449" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { bold = true, fg = "#c4ccd8", bg = "#2c4557" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { bold = true, fg = "#c4ccd8", bg = "#463a54" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { bold = true, fg = "#c4ccd8", bg = "#493f2e" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { bold = true, fg = "#c4ccd8", bg = "#343b4a" })
  vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { bold = true, fg = "#c4ccd8", bg = "#343b4a" })
  vim.api.nvim_set_hl(0, "MiniStatuslineDevinfo", { fg = "#9aa7b8", bg = "#1b2230" })
  vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bold = true, fg = "#c4ccd8", bg = "#1b2230" })
  vim.api.nvim_set_hl(0, "MiniStatuslineFileinfo", { fg = "#9aa7b8", bg = "#1b2230" })
  vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { fg = "#8d9aae", bg = "#161d28" })
end

set_editor_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("EditorHighlights", { clear = true }),
  desc = "配色加载后恢复编辑器与 Markdown 高亮",
  callback = function()
    vim.schedule(set_editor_highlights)
  end,
})

-- 搜索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "保存文件" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "关闭窗口" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "关闭缓冲区" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "取消搜索高亮" })

map("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })

map("v", "<", "<gv", { desc = "减少缩进" })
map("v", ">", ">gv", { desc = "增加缩进" })
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "下移当前行" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "上移当前行" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "下移选中内容" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "上移选中内容" })

require("mini.pairs").setup()
require("mini.comment").setup()
require("mini.surround").setup()
require("mini.statusline").setup({ use_icons = false })
set_editor_highlights()
require("mini.pick").setup()

require("render-markdown").setup({
  render_modes = { "n" },
})
set_editor_highlights()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  desc = "Markdown 渲染开关",
  callback = function(event)
    map("n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", {
      buffer = event.buf,
      desc = "开关 Markdown 渲染",
    })
  end,
})

require("nvim-tree").setup({
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = { enable = true },
  view = { width = 30 },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = false,
      },
    },
  },
  git = { enable = false },
})

-- 使用 Neovim 内置 LSP 客户端，语言服务器由 Nix 安装。
vim.lsp.config("nixd", {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh", "zsh" },
  root_markers = { ".git" },
})

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

vim.lsp.enable({ "nixd", "pyright", "lua_ls", "bashls", "ts_ls" })

vim.diagnostic.config({
  severity_sort = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { border = "rounded", source = true },
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP 快捷键",
  callback = function(event)
    local opts = { buffer = event.buf }
    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "跳转到定义" }))
    map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "查找引用" }))
    map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "查看文档" }))
    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "重命名" }))
    map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "代码操作" }))
    map("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "查看诊断" }))
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, vim.tbl_extend("force", opts, { desc = "上一个诊断" }))
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, vim.tbl_extend("force", opts, { desc = "下一个诊断" }))

    vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  end,
})

map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "开关文件树" })
map("n", "<leader>o", "<cmd>NvimTreeFindFile<cr>", { desc = "在文件树中定位" })

map("n", "<leader>ff", function()
  require("mini.pick").builtin.files()
end, { desc = "查找文件" })

map("n", "<leader>fg", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "全文搜索" })

map("n", "<leader>fb", function()
  require("mini.pick").builtin.buffers()
end, { desc = "查找缓冲区" })

map("n", "<leader>fh", function()
  require("mini.pick").builtin.help()
end, { desc = "搜索帮助" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "复制文本时短暂高亮",
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
