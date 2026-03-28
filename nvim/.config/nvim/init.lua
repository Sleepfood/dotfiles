-- vim: ts=2 sts=2 sw=2 et
-- Neovim (Manjaro/Arch) — Python + DevOps
-- Uses NEW LSP model (nvim-lspconfig >= 2.0.0 / May 2025): vim.lsp.config() + mason-lspconfig automatic_enable
--
-- Suggested external tools (Arch packages where possible):
--   sudo pacman -S --needed ripgrep fd npm \
--     python-black python-isort ruff prettier shfmt shellcheck terraform taplo stylua
--
-- Notes:
-- - No setup_handlers()
-- - No lspconfig.SERVER.setup()
-- - Servers are configured via vim.lsp.config() and auto-enabled by mason-lspconfig

------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = "unnamedplus"

------------------------------------------------------------
-- Options
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("v", "<leader>y", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>y", '"+yy', { noremap = true, silent = true })
vim.keymap.set("v", "//", 'y/\\V<C-r>"<CR>')
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Terminal convenience
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>")

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- Indent guides (indent-blankline v3)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"python",
				"bash",
				"yaml",
				"json",
				"toml",
				"dockerfile",
				"terraform",
				"hcl",
				"markdown",
				"gitignore",
				"diff",
			},
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-n>",
					node_incremental = "<C-n>",
					scope_incremental = "<C-s>",
					node_decremental = "<C-m>",
				},
			},
		},
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader><space>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Grep project" },
			{ "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Doc symbols" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({})
			pcall(telescope.load_extension, "fzf")
		end,
	},

	-- Neo tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
			{ "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus file explorer" },
		},
		opts = {
			filesystem = {
				filtered_items = {
					visible = true,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
			},
			window = {
				position = "left",
				width = 32,
			},
		},
	},

	-- Completion + snippets
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				if col == 0 then
					return false
				end
				local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
				return text:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { autocomplete = false },
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				},
			})
		end,
	},

	----------------------------------------------------------
	-- LSP: NEW STYLE (nvim-lspconfig 2.x+) + mason-lspconfig 2.x+
	----------------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			})

			-- DevOps servers
			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.config("jsonls", { capabilities = capabilities })
			vim.lsp.config("dockerls", { capabilities = capabilities })
			vim.lsp.config("terraformls", { capabilities = capabilities })
			vim.lsp.config("taplo", { capabilities = capabilities })
			vim.lsp.config("ansiblels", { capabilities = capabilities })

			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				settings = {
					yaml = {
						validate = true,
						format = { enable = true },
						keyOrdering = false,
					},
				},
			})

			-- Diagnostics UI
			vim.diagnostic.config({
				float = { border = "rounded" },
				severity_sort = true,
			})

			-- Keymaps when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>ff", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				end,
			})

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"pyright",
					"bashls",
					"yamlls",
					"jsonls",
					"dockerls",
					"terraformls",
					"taplo",
					"ansiblels",
				},
				automatic_enable = true,
			})
		end,
	},

	-- Formatting (Conform)
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "isort", "black" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					yaml = { "prettier" },
					json = { "prettier" },
					markdown = { "prettier" },
					terraform = { "terraform_fmt" },
					hcl = { "terraform_fmt" },
					toml = { "taplo" },
					lua = { "stylua" },
				},
				format_on_save = { timeout_ms = 1500, lsp_fallback = true },
			})
		end,
	},

	-- Linting (nvim-lint)
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				python = { "ruff" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- Terminal
	{ "akinsho/toggleterm.nvim", version = "*", opts = { size = 10, open_mapping = "<c-s>" } },

	-- QoL
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup()
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{
		"supermaven-inc/supermaven-nvim",
		event = "InsertEnter",
		opts = {
			keymaps = {
				accept_suggestion = "<C-l>",
			},
		},
	},

	----------------------------------------------------------
	-- AI Assistant (avante.nvim)
	----------------------------------------------------------
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"hrsh7th/nvim-cmp",
		},
		opts = {
			provider = "claude",
			input = { provider = "dressing" },
			providers = {
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-haiku-4-5-20251001",
					extra_request_body = {
						temperature = 0,
						max_tokens = 4096,
					},
				},
			},
			mappings = {
				ask = "<leader>aa",
				edit = "<leader>ae",
				refresh = "<leader>ar",
				diff = {
					ours = "co",
					theirs = "ct",
					none = "c0",
					both = "cb",
					next = "]x",
					prev = "[x",
				},
			},
			hints = { enabled = true },
			windows = {
				sidebar_header = { align = "center" },
				width = 40,
			},
		},
	},
}, {
	rocks = { enabled = false },
})

------------------------------------------------------------
-- Yank highlight
------------------------------------------------------------
local grp = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = grp,
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function(data)
		local directory = vim.fn.isdirectory(data.file) == 1
		if not directory then
			return
		end
		vim.cmd.cd(data.file)
		pcall(require, "lazy")
		pcall(require("lazy").load, { plugins = { "neo-tree.nvim" } })
		vim.cmd("Neotree show")
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local wins = vim.api.nvim_list_wins()
		if #wins == 1 then
			local buf = vim.api.nvim_win_get_buf(wins[1])
			local ft = vim.api.nvim_buf_get_option(buf, "filetype")
			if ft == "neo-tree" then
				vim.cmd("quit")
			end
		end
	end,
})
