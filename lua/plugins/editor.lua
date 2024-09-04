return {
	-- Отключение плагина flash.nvim
	{
		enabled = false, -- Данный плагин не будет загружаться.
		"folke/flash.nvim",
		---@type Flash.Config
		opts = {
			search = {
				forward = true, -- Поиск вперед по тексту.
				multi_window = false, -- Поиск только в текущем окне, не в нескольких окнах.
				wrap = false, -- Поиск не будет зацикливаться в конце файла.
				incremental = true, -- Поиск будет происходить по мере ввода текста.
			},
		},
	},

	-- Плагин mini.hipatterns для подсветки определенных шаблонов
	{
		"echasnovski/mini.hipatterns",
		event = "BufReadPre", -- Плагин будет загружен перед чтением файла в буфер.
		opts = {
			highlighters = {
				hsl_color = { -- Определение подсветки для шаблона HSL цвета.
					pattern = "hsl%(%d+,? %d+%%?,? %d+%%?%)", -- Шаблон для поиска HSL значений.
					group = function(_, match)
						local utils = require("solarized-osaka.hsl")
						local nh, ns, nl = match:match("hsl%((%d+),? (%d+)%%?,? (%d+)%%?%)")
						local h, s, l = tonumber(nh), tonumber(ns), tonumber(nl)
						local hex_color = utils.hslToHex(h, s, l)
						-- Возвращает группу подсветки на основе вычисленного цвета.
						return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
					end,
				},
			},
		},
	},

	-- Плагин git.nvim для интеграции с Git
	{
		"dinhhuy258/git.nvim",
		event = "BufReadPre", -- Плагин будет загружен перед чтением файла в буфер.
		opts = {
			keymaps = {
				-- Открытие окна blame
				blame = "<Leader>gb",
				-- Открытие файла/папки в репозитории Git
				browse = "<Leader>go",
			},
		},
	},

	-- Плагин Telescope для поиска и навигации
	{
		"telescope.nvim",
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make", -- Необходима сборка для FZF.
			},
			"nvim-telescope/telescope-file-browser.nvim",
		},
		keys = {
			{
				"<leader>fP",
				function()
					require("telescope.builtin").find_files({
						cwd = require("lazy.core.config").options.root,
					})
				end,
				desc = "Find Plugin File", -- Поиск файла плагина.
			},
			{
				";f",
				function()
					local builtin = require("telescope.builtin")
					builtin.find_files({
						no_ignore = false,
						hidden = true, -- Показывать скрытые файлы.
					})
				end,
				desc = "Lists files in your current working directory, respects .gitignore",
			},
			{
				";r",
				function()
					local builtin = require("telescope.builtin")
					builtin.live_grep({
						additional_args = { "--hidden" }, -- Включить скрытые файлы в поиск.
					})
				end,
				desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
			},
			{
				"\\\\",
				function()
					local builtin = require("telescope.builtin")
					builtin.buffers() -- Показать список открытых буферов.
				end,
				desc = "Lists open buffers",
			},
			{
				";t",
				function()
					local builtin = require("telescope.builtin")
					builtin.help_tags() -- Показать список доступных тегов справки.
				end,
				desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
			},
			{
				";;",
				function()
					local builtin = require("telescope.builtin")
					builtin.resume() -- Возобновить предыдущий выбор в Telescope.
				end,
				desc = "Resume the previous telescope picker",
			},
			{
				";e",
				function()
					local builtin = require("telescope.builtin")
					builtin.diagnostics() -- Показать диагностику для всех открытых буферов или конкретного буфера.
				end,
				desc = "Lists Diagnostics for all open buffers or a specific buffer",
			},
			{
				";s",
				function()
					local builtin = require("telescope.builtin")
					builtin.treesitter() -- Показать имена функций, переменных с помощью Treesitter.
				end,
				desc = "Lists Function names, variables, from Treesitter",
			},
			{
				"sf",
				function()
					local telescope = require("telescope")

					local function telescope_buffer_dir()
						return vim.fn.expand("%:p:h")
					end

					telescope.extensions.file_browser.file_browser({
						path = "%:p:h",
						cwd = telescope_buffer_dir(),
						respect_gitignore = false, -- Не учитывать .gitignore.
						hidden = true, -- Показывать скрытые файлы.
						grouped = true,
						previewer = false,
						initial_mode = "normal", -- Открывать в нормальном режиме.
						layout_config = { height = 40 },
					})
				end,
				desc = "Open File Browser with the path of the current buffer",
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = require("telescope").extensions.file_browser.actions

			opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
				wrap_results = true, -- Переносить результаты поиска.
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" }, -- Позиция строки поиска сверху.
				sorting_strategy = "ascending", -- Сортировка результатов по возрастанию.
				winblend = 0, -- Прозрачность окна.
				mappings = {
					n = {},
				},
			})
			opts.pickers = {
				diagnostics = {
					theme = "ivy",
					initial_mode = "normal", -- Начальный режим - нормальный.
					layout_config = {
						preview_cutoff = 9999,
					},
				},
			}
			opts.extensions = {
				file_browser = {
					theme = "dropdown", -- Тема в виде выпадающего списка.
					hijack_netrw = true, -- Отключить netrw и использовать telescope-file-browser вместо него.
					mappings = {
						["n"] = {
							["N"] = fb_actions.create, -- Создать новый файл/папку.
							["h"] = fb_actions.goto_parent_dir, -- Перейти в родительский каталог.
							["/"] = function()
								vim.cmd("startinsert")
							end,
							["<C-u>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_previous(prompt_bufnr) -- Перемещение выбора вверх на 10 строк.
								end
							end,
							["<C-d>"] = function(prompt_bufnr)
								for i = 1, 10 do
									actions.move_selection_next(prompt_bufnr) -- Перемещение выбора вниз на 10 строк.
								end
							end,
							["<PageUp>"] = actions.preview_scrolling_up, -- Прокрутка предпросмотра вверх.
							["<PageDown>"] = actions.preview_scrolling_down, -- Прокрутка предпросмотра вниз.
						},
					},
				},
			}
			telescope.setup(opts)
			require("telescope").load_extension("fzf") -- Загрузка расширения FZF для Telescope.
			require("telescope").load_extension("file_browser") -- Загрузка расширения file_browser для Telescope.
		end,
	},
}
