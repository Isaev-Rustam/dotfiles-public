-- Отключить режим вставки при выходе из режима вставки
vim.api.nvim_create_autocmd("InsertLeave", {
	-- Событие: "InsertLeave" означает, что автокоманда будет выполнена при выходе из режима вставки.
	pattern = "*",  -- Применяется ко всем файлам.
	command = "set nopaste",  -- Устанавливает опцию "nopaste", которая отключает режим вставки (paste mode), если он был включён.
})

-- Отключить сокрытие (concealing) в некоторых форматах файлов
-- Значение conceallevel по умолчанию равно 3 в LazyVim
vim.api.nvim_create_autocmd("FileType", {
	-- Событие: "FileType" означает, что автокоманда будет выполнена при открытии файла с определённым типом.
	pattern = { "json", "jsonc", "markdown" },  -- Применяется только к файлам с типами JSON, JSONC и Markdown.
	callback = function()
		vim.opt.conceallevel = 0  -- Устанавливает уровень сокрытия (conceallevel) в 0, что отключает сокрытие текста (например, скрытие синтаксических элементов в Markdown или JSON).
	end,
})
