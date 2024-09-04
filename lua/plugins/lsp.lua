return {
	-- Настройка инструментов для проверки кода и форматирования
	{
		"williamboman/mason.nvim",
		-- Расширяем список установленных инструментов с помощью mason.nvim
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",  -- Форматтер для Lua
				"selene",  -- Анализатор для Lua
				"luacheck",  -- Линтер для Lua
				"shellcheck",  -- Линтер для shell-скриптов
				"shfmt",  -- Форматтер для shell-скриптов
				"tailwindcss-language-server",  -- Языковой сервер для TailwindCSS
				"typescript-language-server",  -- Языковой сервер для TypeScript
				"css-lsp",  -- Языковой сервер для CSS
			})
		end,
	},

	-- Настройка LSP-серверов для различных языков
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },  -- Отключаем inlay hints по умолчанию
			servers = {
				cssls = {},  -- Настройка LSP-сервера для CSS
				tailwindcss = {
					-- Определяем корневую директорию как директорию с .git
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
				},
				tsserver = {
					-- Определяем корневую директорию как директорию с .git
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,  -- Отключаем поддержку одиночных файлов
					settings = {
						typescript = {
							-- Включаем/отключаем различные inlay hints для TypeScript
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							-- Включаем/отключаем различные inlay hints для JavaScript
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				html = {},  -- Настройка LSP-сервера для HTML
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,  -- Отключаем сортировку ключей в YAML
						},
					},
				},
				lua_ls = {
					single_file_support = true,  -- Включаем поддержку одиночных файлов
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,  -- Отключаем проверку сторонних библиотек
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",  -- Включаем оба типа сниппетов в автодополнении
							},
							hint = {
								enable = true,  -- Включаем подсказки (hints)
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },  -- Исключаем переменные, начинающиеся с "_" из предупреждений о неиспользуемых локальных переменных
							},
							format = {
								enable = false,  -- Отключаем автоматическое форматирование
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",  -- Устанавливаем размер отступа в 2 пробела
									continuation_indent_size = "2",  -- Устанавливаем размер продолжения отступа в 2 пробела
								},
							},
						},
					},
				},
			},
			setup = {},  -- Пустая настройка, можно добавить пользовательские конфигурации
		},
	},

	-- Настройка дополнительных комбинаций клавиш для LSP
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			vim.list_extend(keys, {
				{
					"gd",
					function()
						-- Переход к определению функции с использованием Telescope,
						-- при этом окно не используется повторно (reuse_win = false)
						require("telescope.builtin").lsp_definitions({ reuse_win = false })
					end,
					desc = "Goto Definition",  -- Описание команды
					has = "definition",  -- Проверка наличия возможности перехода к определению
				},
			})
		end,
	},
}
