return {
	-- Подключает плагин "nvim-treesitter/playground", который предоставляет интерактивную среду для исследования деревьев синтаксиса (AST).
	{ "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },

	{
		-- Подключает основной плагин "nvim-treesitter/nvim-treesitter", который предоставляет расширенные возможности работы с деревьями синтаксиса (AST).
		"nvim-treesitter/nvim-treesitter",
		opts = {
			-- Указывает языки, которые необходимо установить для анализа синтаксиса.
			ensure_installed = {
				"astro",
				"cmake",
				"cpp",
				"css",
				"fish",
				"gitignore",
				"go",
				"graphql",
				"http",
				"java",
				"php",
				"rust",
				"scss",
				"sql",
				"svelte",
			},

			-- Опции для включения и настройки линтера запросов.
			-- Линтер проверяет правильность написания деревьев синтаксиса.
			query_linter = {
				enable = true, -- Включение линтера.
				use_virtual_text = true, -- Показывать ошибки линтера в виде виртуального текста.
				lint_events = { "BufWrite", "CursorHold" }, -- События, при которых будет происходить линтинг.
			},

			-- Настройки для плагина playground, который предоставляет визуальное представление деревьев синтаксиса.
			playground = {
				enable = true, -- Включение playground.
				disable = {}, -- Список языков, для которых playground будет отключен.
				updatetime = 25, -- Задержка обновления подсветки узлов (в миллисекундах).
				persist_queries = true, -- Сохранение состояния запросов между сессиями Vim.
				keybindings = {
					-- Горячие клавиши для взаимодействия с playground.
					toggle_query_editor = "o", -- Переключение редактора запросов.
					toggle_hl_groups = "i", -- Переключение подсветки групп.
					toggle_injected_languages = "t", -- Переключение встраиваемых языков.
					toggle_anonymous_nodes = "a", -- Переключение отображения анонимных узлов.
					toggle_language_display = "I", -- Переключение отображения языка.
					focus_language = "f", -- Фокус на языке.
					unfocus_language = "F", -- Убрать фокус с языка.
					update = "R", -- Обновить playground.
					goto_node = "<cr>", -- Перейти к узлу.
					show_help = "?", -- Показать справку.
				},
			},
		},
		config = function(_, opts)
			-- Настройка плагина nvim-treesitter с заданными опциями.
			require("nvim-treesitter.configs").setup(opts)

			-- Добавление поддержки MDX (Markdown + JSX) в nvim.
			vim.filetype.add({
				extension = {
					mdx = "mdx", -- Определение расширения .mdx для типа файла mdx.
				},
			})
			vim.treesitter.language.register("markdown", "mdx") -- Регистрация языка Markdown для файлов .mdx.
		end,
	},
}
