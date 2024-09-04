-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local discipline = require("craftzdog.discipline")

-- Выполнение функции cowboy из модуля discipline
discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
-- Эти команды выполняют операции, не изменяя содержимое регистров
keymap.set("n", "x", '"_x') -- Вырезать символ под курсором без изменения регистра
keymap.set("n", "<Leader>p", '"0p') -- Вставить последнее удаленное содержимое (из "0" регистра)
keymap.set("n", "<Leader>P", '"0P') -- Вставить перед курсором последнее удаленное содержимое
keymap.set("v", "<Leader>p", '"0p') -- Вставить последнее удаленное содержимое в визуальном режиме
keymap.set("n", "<Leader>c", '"_c') -- Заменить текст без изменения регистра
keymap.set("n", "<Leader>C", '"_C') -- Заменить до конца строки без изменения регистра
keymap.set("v", "<Leader>c", '"_c') -- Заменить текст в визуальном режиме без изменения регистра
keymap.set("v", "<Leader>C", '"_C') -- Заменить до конца строки в визуальном режиме без изменения регистра
keymap.set("n", "<Leader>d", '"_d') -- Удалить текст без изменения регистра
keymap.set("n", "<Leader>D", '"_D') -- Удалить до конца строки без изменения регистра
keymap.set("v", "<Leader>d", '"_d') -- Удалить текст в визуальном режиме без изменения регистра
keymap.set("v", "<Leader>D", '"_D') -- Удалить до конца строки в визуальном режиме без изменения регистра

-- Increment/decrement
keymap.set("n", "+", "<C-a>") -- Увеличить число под курсором
keymap.set("n", "-", "<C-x>") -- Уменьшить число под курсором

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d') -- Удалить слово перед курсором

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G") -- Выделить весь текст в файле

-- Save with root permission (not working for now)
-- vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})
-- (не работает) Сохранить файл с правами суперпользователя

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts) -- Вставить новую строку ниже и перейти в режим вставки
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts) -- Вставить новую строку выше и перейти в режим вставки

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts) -- Перемещение вперед по списку переходов

-- New tab
keymap.set("n", "te", ":tabedit") -- Открыть новую вкладку
keymap.set("n", "<tab>", ":tabnext<Return>", opts) -- Перейти к следующей вкладке
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts) -- Перейти к предыдущей вкладке

-- Split window
keymap.set("n", "ss", ":split<Return>", opts) -- Разделить окно по горизонтали
keymap.set("n", "sv", ":vsplit<Return>", opts) -- Разделить окно по вертикали

-- Move window
keymap.set("n", "sh", "<C-w>h") -- Переместить фокус окна влево
keymap.set("n", "sk", "<C-w>k") -- Переместить фокус окна вверх
keymap.set("n", "sj", "<C-w>j") -- Переместить фокус окна вниз
keymap.set("n", "sl", "<C-w>l") -- Переместить фокус окна вправо

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><") -- Уменьшить ширину окна
keymap.set("n", "<C-w><right>", "<C-w>>") -- Увеличить ширину окна
keymap.set("n", "<C-w><up>", "<C-w>+") -- Увеличить высоту окна
keymap.set("n", "<C-w><down>", "<C-w>-") -- Уменьшить высоту окна

-- Diagnostics
keymap.set("n", "<C-j>", function()
	vim.diagnostic.goto_next()
end, opts) -- Перейти к следующей диагностике (ошибке или предупреждению)

keymap.set("n", "<leader>r", function()
	require("craftzdog.hsl").replaceHexWithHSL()
end) -- Заменить шестнадцатеричный цвет на HSL (используя модуль craftzdog.hsl)

keymap.set("n", "<leader>i", function()
	require("craftzdog.lsp").toggleInlayHints()
end) -- Включить/выключить подсказки внутри кода (используя модуль craftzdog.lsp)
