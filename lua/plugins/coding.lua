return {
	-- Плагин для создания аннотаций (документации) с помощью одной клавиши
	{
		"danymat/neogen",
		keys = {
			{
				"<leader>cc",
				function()
					require("neogen").generate({})
				end,
				desc = "Neogen Comment",  -- Описание команды для создания комментария
			},
		},
		opts = { snippet_engine = "luasnip" },  -- Настройка для использования движка сниппетов LuaSnip
	},

	-- Плагин для инкрементального переименования
	{
		"smjonas/inc-rename.nvim",
		cmd = "IncRename",  -- Команда для вызова инкрементального переименования
		config = true,  -- Автоматически использовать стандартные настройки плагина
	},

	-- Плагин для рефакторинга кода
	{
		"ThePrimeagen/refactoring.nvim",
		keys = {
			{
				"<leader>r",
				function()
					require("refactoring").select_refactor()
				end,
				mode = "v",  -- Работает в визуальном режиме
				noremap = true,  -- Без рекурсивного маппинга
				silent = true,  -- Без отображения команды в командной строке
				expr = false,
			},
		},
		opts = {},  -- Можно добавить дополнительные параметры конфигурации
	},

	-- Плагин для перемещения курсора вперед/назад с использованием квадратных скобок
	{
		"echasnovski/mini.bracketed",
		event = "BufReadPost",  -- Загружается после чтения буфера
		config = function()
			local bracketed = require("mini.bracketed")
			bracketed.setup({
				file = { suffix = "" },
				window = { suffix = "" },
				quickfix = { suffix = "" },
				yank = { suffix = "" },
				treesitter = { suffix = "n" },  -- Дополнительная настройка для работы с деревьями синтаксиса
			})
		end,
	},

	-- Плагин для улучшенного увеличения/уменьшения значений
	{
		"monaqa/dial.nvim",
    -- stylua: ignore
    keys = {
      { "<C-a>", function() return require("dial.map").inc_normal() end, expr = true, desc = "Increment" },
      { "<C-x>", function() return require("dial.map").dec_normal() end, expr = true, desc = "Decrement" },
    },
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,  -- Инкремент/декремент для десятичных чисел
					augend.integer.alias.hex,  -- Инкремент/декремент для шестнадцатеричных чисел
					augend.date.alias["%Y/%m/%d"],  -- Инкремент/декремент для дат
					augend.constant.alias.bool,  -- Инкремент/декремент для булевых значений
					augend.semver.alias.semver,  -- Инкремент для версий семантики
					augend.constant.new({ elements = { "let", "const" } }),  -- Инкремент/декремент между let и const
				},
			})
		end,
	},

	-- Плагин для отображения структуры символов в правой панели
	{
		"simrat39/symbols-outline.nvim",
		keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },  -- Клавиша для вызова символов
		cmd = "SymbolsOutline",  -- Команда для открытия панели символов
		opts = {
			position = "right",  -- Панель символов будет отображаться справа
		},
	},

	-- Настройка для добавления эмодзи в автодополнение nvim-cmp
	{
		"nvim-cmp",
		dependencies = { "hrsh7th/cmp-emoji" },  -- Зависимость для поддержки эмодзи
		opts = function(_, opts)
			table.insert(opts.sources, { name = "emoji" })  -- Добавление источника эмодзи в автодополнение
		end,
	},
}
