-- Создаём пустую таблицу, которая будет хранить все функции модуля
local M = {}

-- Строка, содержащая символы, допустимые в шестнадцатеричных кодах
local hexChars = "0123456789abcdef"

-- Функция для преобразования шестнадцатеричного кода цвета в RGB
function M.hex_to_rgb(hex)
	hex = string.lower(hex) -- Преобразует строку в нижний регистр
	local ret = {}
	for i = 0, 2 do
		-- Извлекаем по два символа для каждого компонента RGB
		local char1 = string.sub(hex, i * 2 + 2, i * 2 + 2)
		local char2 = string.sub(hex, i * 2 + 3, i * 2 + 3)
		-- Находим индекс каждого символа в строке hexChars и вычисляем значение
		local digit1 = string.find(hexChars, char1) - 1
		local digit2 = string.find(hexChars, char2) - 1
		-- Преобразуем шестнадцатеричное значение в десятичное и нормализуем его
		ret[i + 1] = (digit1 * 16 + digit2) / 255.0
	end
	return ret -- Возвращаем массив с компонентами RGB
end

-- Функция для преобразования цвета из RGB в HSL
function M.rgbToHsl(r, g, b)
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h = 0
	local s = 0
	local l = 0

	l = (max + min) / 2 -- Вычисляем lightness (светлоту)

	if max == min then
		h, s = 0, 0 -- Если цвет ахроматический (серый), то hue (оттенок) и saturation (насыщенность) равны 0
	else
		local d = max - min
		-- Вычисляем насыщенность
		if l > 0.5 then
			s = d / (2 - max - min)
		else
			s = d / (max + min)
		end
		-- Вычисляем оттенок в зависимости от компонента RGB, имеющего максимальное значение
		if max == r then
			h = (g - b) / d
			if g < b then
				h = h + 6
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h * 360, s * 100, l * 100 -- Возвращаем значение HSL
end

-- Функция для преобразования HSL в RGB
function M.hslToRgb(h, s, l)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- Если насыщенность равна 0, то цвет серый (ахроматический)
	else
		-- Вспомогательная функция для вычисления RGB на основе оттенка
		function hue2rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		-- Вычисляем значения p и q для формулы преобразования
		local q
		if l < 0.5 then
			q = l * (1 + s)
		else
			q = l + s - l * s
		end
		local p = 2 * l - q

		-- Вычисляем значения R, G и B
		r = hue2rgb(p, q, h + 1 / 3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1 / 3)
	end

	-- Возвращаем компоненты RGB в диапазоне от 0 до 255
	return r * 255, g * 255, b * 255
end

-- Функция для преобразования шестнадцатеричного цвета в HSL
function M.hexToHSL(hex)
	-- Импортируем модуль для работы с HSL (возможно, модуль для работы с цветами HSLuv)
	local hsluv = require("solarized-osaka.hsluv")
	-- Преобразуем hex в RGB
	local rgb = M.hex_to_rgb(hex)
	-- Преобразуем RGB в HSL
	local h, s, l = M.rgbToHsl(rgb[1], rgb[2], rgb[3])

	-- Возвращаем строку в формате HSL
	return string.format("hsl(%d, %d, %d)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
end

-- Функция для преобразования HSL в шестнадцатеричный формат
function M.hslToHex(h, s, l)
	-- Преобразуем HSL в RGB
	local r, g, b = M.hslToRgb(h / 360, s / 100, l / 100)

	-- Возвращаем цвет в шестнадцатеричном формате
	return string.format("#%02x%02x%02x", r, g, b)
end

-- Функция для замены шестнадцатеричных цветов на HSL в текущей строке в редакторе
function M.replaceHexWithHSL()
	-- Получаем текущий номер строки
	local line_number = vim.api.nvim_win_get_cursor(0)[1]

	-- Получаем содержимое текущей строки
	local line_content = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

	-- Ищем и заменяем все hex-коды в строке на HSL
	for hex in line_content:gmatch("#[0-9a-fA-F]+") do
		local hsl = M.hexToHSL(hex)
		line_content = line_content:gsub(hex, hsl)
	end

	-- Устанавливаем обновленное содержимое строки
	vim.api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { line_content })
end

-- Возвращаем таблицу M, чтобы другие модули могли использовать её функции
return M
