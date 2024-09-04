-- nvim/lua/config/lazy.lua
-- Определение пути к директории для установки Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Проверка, существует ли директория Lazy.nvim
if not vim.loop.fs_stat(lazypath) then
  -- Если директория не существует, клонируем репозиторий Lazy.nvim из GitHub
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",  -- Клонируем только необходимые файлы, исключая большие файлы
    "https://github.com/folke/lazy.nvim.git",  -- URL репозитория Lazy.nvim
    "--branch=stable",  -- Клонируем последнюю стабильную версию
    lazypath,  -- Путь, куда клонируется репозиторий
  })
end

-- Добавление пути к Lazy.nvim в 'runtimepath'
vim.opt.rtp:prepend(lazypath)

-- Настройка Lazy.nvim
require("lazy").setup({
  spec = {
    -- Добавление LazyVim и импорт его плагинов
    {
      "LazyVim/LazyVim",  -- Плагин LazyVim
      import = "lazyvim.plugins",  -- Импорт стандартных плагинов LazyVim
      opts = {
        colorscheme = "solarized-osaka",  -- Установка цветовой схемы Solarized Osaka
        news = {  -- Включение новостей LazyVim и Neovim
          lazyvim = true,
          neovim = true,
        },
      },
    },
    -- Импорт дополнительных модулей
    { import = "lazyvim.plugins.extras.linting.eslint" },  -- Модуль для линтинга с помощью ESLint
    { import = "lazyvim.plugins.extras.formatting.prettier" },  -- Модуль для форматирования с помощью Prettier
    { import = "lazyvim.plugins.extras.lang.typescript" },  -- Модуль поддержки TypeScript
    { import = "lazyvim.plugins.extras.lang.json" },  -- Модуль поддержки JSON
    -- { import = "lazyvim.plugins.extras.lang.markdown" },  -- Модуль поддержки Markdown (закомментировано)
    { import = "lazyvim.plugins.extras.lang.rust" },  -- Модуль поддержки Rust
    { import = "lazyvim.plugins.extras.lang.tailwind" },  -- Модуль поддержки Tailwind CSS
    -- { import = "lazyvim.plugins.extras.coding.copilot" },  -- Модуль поддержки GitHub Copilot(платный)
    -- { import = "lazyvim.plugins.extras.dap.core" },  -- Модуль поддержки DAP (закомментировано)
    -- { import = "lazyvim.plugins.extras.vscode" },  -- Модуль поддержки Visual Studio Code (закомментировано)
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },  -- Модуль утилит Mini Hipatterns
    -- { import = "lazyvim.plugins.extras.test.core" },  -- Модуль для тестирования (закомментировано)
    -- { import = "lazyvim.plugins.extras.coding.yanky" },  -- Модуль Yanky (закомментировано)
    -- { import = "lazyvim.plugins.extras.editor.mini-files" },  -- Модуль Mini Files (закомментировано)
    -- { import = "lazyvim.plugins.extras.util.project" },  -- Модуль управления проектами (закомментировано)
    { import = "plugins" },  -- Импорт дополнительных пользовательских плагинов
  },
  defaults = {
    lazy = false,  -- По умолчанию, только плагины LazyVim будут загружаться лениво. Пользовательские плагины загружаются во время старта.
    version = false,  -- Всегда использовать последнюю версию из git
  },
  dev = {
    path = "~/.ghq/github.com",  -- Установка пути для разработки плагинов
  },
  checker = { enabled = true },  -- Автоматическая проверка обновлений плагинов
  performance = {
    cache = {
      enabled = true,  -- Включение кэширования для повышения производительности
    },
    rtp = {
      disabled_plugins = -- Список плагинов, которые будут отключены для повышения производительности
			{
					"gzip",  -- Отключает поддержку сжатых файлов в формате gzip.
					-- "matchit",  -- (Закомментировано) Плагин для улучшенного сопоставления соответствующих пар скобок, тегов и т.д.
					-- "matchparen",  -- (Закомментировано) Плагин для выделения парных скобок.
					"netrwPlugin",  -- Отключает встроенный плагин для работы с файловыми системами и сетевыми протоколами (например, FTP).
					"rplugin",  -- Отключает поддержку удалённых плагинов, написанных на Python или другом языке.
					"tarPlugin",  -- Отключает поддержку для открытия tar-архивов.
					"tohtml",  -- Отключает функцию конвертации текущего буфера в HTML формат.
					"tutor",  -- Отключает плагин интерактивного обучения (Vim Tutor).
					"zipPlugin",  -- Отключает поддержку для открытия zip-архивов.
			},
    },
  },
  ui = {
    custom_keys = {
      ["<localleader>d"] = function(plugin)
        dd(plugin)  -- Пример пользовательской функции для ключа <localleader>d
      end,
    },
  },
  debug = false,  -- Отключение режима отладки
})
