-- selene: allow(global_usage)
-- Включает использование глобальных переменных в анализаторе кода Selene, если он используется.

local M = {}

-- Функция для получения информации о текущем местоположении (файл и строка) в коде
function M.get_loc()
  local me = debug.getinfo(1, "S")  -- Получаем информацию о текущем месте вызова функции
  local level = 2
  local info = debug.getinfo(level, "S")  -- Переходим к следующему уровню стека вызовов
  while info and (info.source == me.source or info.source == "@" .. vim.env.MYVIMRC or info.what ~= "Lua") do
    level = level + 1
    info = debug.getinfo(level, "S")  -- Продолжаем проверку уровня стека вызовов
  end
  info = info or me  -- Если информация о месте не найдена, используем текущее место
  local source = info.source:sub(2)  -- Удаляем начальный символ "@" из пути источника
  source = vim.loop.fs_realpath(source) or source  -- Получаем абсолютный путь к файлу
  return source .. ":" .. info.linedefined  -- Возвращаем путь и строку, где начинается код
end

---@param value any
---@param opts? {loc:string}
-- Функция для вывода отладочной информации в уведомление
function M._dump(value, opts)
  opts = opts or {}
  opts.loc = opts.loc or M.get_loc()  -- Устанавливаем местоположение для вывода, если оно не задано
  if vim.in_fast_event() then
    return vim.schedule(function()
      M._dump(value, opts)  -- Если выполняется быстрый процесс, откладываем выполнение
    end)
  end
  opts.loc = vim.fn.fnamemodify(opts.loc, ":~:.")  -- Преобразуем путь к более удобочитаемому формату
  local msg = vim.inspect(value)  -- Преобразуем значение в строку для отображения
  vim.notify(msg, vim.log.levels.INFO, {
    title = "Debug: " .. opts.loc,  -- Заголовок уведомления
    on_open = function(win)
      vim.wo[win].conceallevel = 3  -- Настройка уровня сокрытия текста в окне уведомления
      vim.wo[win].concealcursor = ""  -- Убираем скрытие курсора
      vim.wo[win].spell = false  -- Отключаем проверку орфографии
      local buf = vim.api.nvim_win_get_buf(win)  -- Получаем буфер окна
      if not pcall(vim.treesitter.start, buf, "lua") then
        vim.bo[buf].filetype = "lua"  -- Устанавливаем тип файла, если Treesitter не доступен
      end
    end,
  })
end

-- Функция для вывода отладочной информации, может принимать несколько значений
function M.dump(...)
  local value = { ... }
  if vim.tbl_isempty(value) then
    value = nil  -- Если нет значений, устанавливаем nil
  else
    value = vim.tbl_islist(value) and vim.tbl_count(value) <= 1 and value[1] or value  -- Если одно значение, используем его
  end
  M._dump(value)  -- Вызываем внутреннюю функцию для вывода отладочной информации
end

-- Функция для проверки утечек в расширенных отметках
function M.extmark_leaks()
  local nsn = vim.api.nvim_get_namespaces()  -- Получаем все пространства имен для расширенных отметок

  local counts = {}

  for name, ns in pairs(nsn) do
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local count = #vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})  -- Получаем количество расширенных отметок в буфере
      if count > 0 then
        counts[#counts + 1] = {
          name = name,
          buf = buf,
          count = count,
          ft = vim.bo[buf].ft,
        }
      end
    end
  end
  table.sort(counts, function(a, b)
    return a.count > b.count  -- Сортируем по количеству отметок
  end)
  dd(counts)  -- Выводим результаты (предполагается, что dd — это функция для отладки)
end

-- Функция для оценки размера значения в байтах
function estimateSize(value, visited)
  if value == nil then
    return 0
  end
  local bytes = 0

  -- инициализируем таблицу посещенных значений, если не сделано ранее
  --- @type table<any, true>
  visited = visited or {}

  -- обрабатываем уже посещенное значение, чтобы избежать бесконечной рекурсии
  if visited[value] then
    return 0
  else
    visited[value] = true
  end

  if type(value) == "boolean" or value == nil then
    bytes = 4  -- Размер булевого значения или nil
  elseif type(value) == "number" then
    bytes = 8  -- Размер численного значения
  elseif type(value) == "string" then
    bytes = string.len(value) + 24  -- Размер строки плюс дополнительная память
  elseif type(value) == "function" then
    bytes = 32  -- Размер функции
    -- добавляем размер upvalues (внешних значений функции)
    local i = 1
    while true do
      local name, val = debug.getupvalue(value, i)
      if not name then
        break
      end
      bytes = bytes + estimateSize(val, visited)  -- Добавляем размер каждого upvalue
      i = i + 1
    end
  elseif type(value) == "table" then
    bytes = 40  -- Размер таблицы
    for k, v in pairs(value) do
      bytes = bytes + estimateSize(k, visited) + estimateSize(v, visited)  -- Добавляем размер ключей и значений таблицы
    end
    local mt = debug.getmetatable(value)
    if mt then
      bytes = bytes + estimateSize(mt, visited)  -- Добавляем размер метатаблицы, если она существует
    end
  end
  return bytes
end

-- Функция для проверки утечек памяти в загруженных модулях
function M.module_leaks(filter)
  local sizes = {}
  for modname, mod in pairs(package.loaded) do
    if not filter or modname:match(filter) then
      local root = modname:match("^([^%.]+)%..*$") or modname
      -- root = modname
      sizes[root] = sizes[root] or { mod = root, size = 0 }
      sizes[root].size = sizes[root].size + estimateSize(mod) / 1024 / 1024  -- Оцениваем размер модуля в мегабайтах
    end
  end
  sizes = vim.tbl_values(sizes)
  table.sort(sizes, function(a, b)
    return a.size > b.size  -- Сортируем по размеру
  end)
  dd(sizes)  -- Выводим результаты
end

-- Функция для получения upvalue (внешнего значения) функции по имени
function M.get_upvalue(func, name)
  local i = 1
  while true do
    local n, v = debug.getupvalue(func, i)
    if not n then
      break
    end
    if n == name then
      return v
    end
    i = i + 1
  end
end

return M  -- Возвращаем модуль с определенными функциями
