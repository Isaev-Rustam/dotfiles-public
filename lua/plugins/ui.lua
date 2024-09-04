return {
	-- Настройка для плагина noice.nvim, который управляет уведомлениями, командной строкой и всплывающим меню.
	{
		"folke/noice.nvim",
		opts = function(_, opts)
			-- Добавляем правило, чтобы пропускать уведомления, содержащие текст "No information available".
			table.insert(opts.routes, {
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			})

			-- Определяем переменную, чтобы отслеживать, сфокусировано ли окно.
			local focused = true

			-- Автокоманда для установки состояния фокуса при получении/потере фокуса окна.
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})
			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})

			-- Добавляем правило, чтобы при потере фокуса показывались уведомления через view "notify_send".
			table.insert(opts.routes, 1, {
				filter = {
					cond = function()
						return not focused
					end,
				},
				view = "notify_send",
				opts = { stop = false },
			})

			-- Настраиваем команду для истории сообщений, вызываемую через `:Noice`.
			opts.commands = {
				all = {
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {},
				},
			}

			-- Автокоманда для вызова клавишных событий при работе с markdown файлами.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.schedule(function()
						require("noice.text.markdown").keys(event.buf)
					end)
				end,
			})

			-- Включаем границы для документов LSP.
			opts.presets.lsp_doc_border = true
		end,
	},

	-- Настройка плагина nvim-notify для отображения уведомлений.
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 5000,  -- Устанавливаем время ожидания уведомлений на 5 секунд.
		},
	},

	-- Настройка плагина mini.animate для анимации.
	{
		"echasnovski/mini.animate",
		event = "VeryLazy",  -- Загружаем плагин только при необходимости.
		opts = function(_, opts)
			opts.scroll = {
				enable = false,  -- Отключаем анимацию для прокрутки.
			}
		end,
	},

	-- Настройка плагина bufferline.nvim для управления табами и буферами.
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },  -- Переход к следующему табу.
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },  -- Переход к предыдущему табу.
		},
		opts = {
			options = {
				mode = "tabs",  -- Используем режим табов.
				show_buffer_close_icons = false,  -- Скрываем иконки для закрытия буферов.
				show_close_icon = false,  -- Скрываем иконку для закрытия таба.
			},
		},
	},

	-- Настройка плагина incline.nvim для отображения имени файла в строке состояния.
	{
		"b0o/incline.nvim",
		dependencies = { "craftzdog/solarized-osaka.nvim" },  -- Зависимость от темы Solarized Osaka.
		event = "BufReadPre",  -- Загружаем плагин перед чтением буфера.
		priority = 1200,
		config = function()
			local colors = require("solarized-osaka.colors").setup()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
						InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },  -- Устанавливаем отступы окна.
				hide = {
					cursorline = true,  -- Скрываем строку курсора.
				},
				render = function(props)
					-- Получаем имя файла.
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					-- Добавляем метку, если файл был изменен.
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end
					-- Получаем иконку и цвет файла.
					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},

	-- Настройка плагина lualine.nvim для строки состояния.
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			local LazyVim = require("lazyvim.util")
			opts.sections.lualine_c[4] = {
				LazyVim.lualine.pretty_path({
					length = 0,
					relative = "cwd",
					modified_hl = "MatchParen",
					directory_hl = "",
					filename_hl = "Bold",
					modified_sign = "",
					readonly_icon = " 󰌾 ",
				}),
			}
		end,
	},

	-- Настройка плагина zen-mode.nvim для фокусированного режима.
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,  -- Включаем поддержку gitsigns.
				tmux = true,  -- Включаем поддержку tmux.
				kitty = { enabled = false, font = "+2" },  -- Отключаем поддержку kitty.
			},
		},
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },  -- Ключевая комбинация для активации ZenMode.
	},

	-- Настройка плагина dashboard-nvim для стартового экрана.
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		opts = function(_, opts)
			-- Задаем ASCII-логотип для стартового экрана.
			local logo = [[
				███╗   ██╗██╗   ██╗██╗███╗   ███╗
				████╗  ██║██║   ██║██║████╗ ████║
				██╔██╗ ██║██║   ██║██║██╔████╔██║
				██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
				██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
				╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
				]]

			logo = string.rep("\n", 8) .. logo .. "\n\n"  -- Добавляем несколько пустых строк перед логотипом.
			opts.config.header = vim.split(logo, "\n")  -- Устанавливаем логотип в качестве заголовка.
		end,
	},
}
