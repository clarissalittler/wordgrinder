--!nonstrict
-- © 2013 David Given.
-- WordGrinder is licensed under the MIT open source license. See the COPYING
-- file in this distribution for the full text.

local SCROLLMODES = { "Fixed", "Jump" }
local string_format = string.format
local table_sort = table.sort
local math_floor = math.floor

local function trim(s: string): string
	return s:match("^%s*(.-)%s*$") or ""
end

local function clamp_unit(v: number): number
	if v < 0 then
		return 0
	elseif v > 1 then
		return 1
	end
	return v
end

local function colour_to_hex(c: Colour): string
	local function tobyte(v: number): number
		return math_floor(clamp_unit(v) * 255 + 0.5)
	end

	return string_format("#%02X%02X%02X",
		tobyte(c[1]), tobyte(c[2]), tobyte(c[3]))
end

local function parse_colour(value: string): Colour?
	value = trim(value)
	local hex = value:match("^#?([%x][%x][%x][%x][%x][%x])$")
	if hex then
		local r = tonumber(hex:sub(1, 2), 16)
		local g = tonumber(hex:sub(3, 4), 16)
		local b = tonumber(hex:sub(5, 6), 16)
		if not r or not g or not b then
			return nil
		end
		return {
			r / 255,
			g / 255,
			b / 255,
		}
	end

	local nums: {number} = {}
	for n in value:gmatch("[-+]?%d*%.?%d+") do
		local value_number = tonumber(n)
		if not value_number then
			return nil
		end
		nums[#nums+1] = value_number
	end
	if #nums ~= 3 then
		return nil
	end

	local n1 = assert(nums[1])
	local n2 = assert(nums[2])
	local n3 = assert(nums[3])

	local scale = 1
	if (n1 > 1) or (n2 > 1) or (n3 > 1) then
		scale = 255
	end

	return {
		clamp_unit(n1 / scale),
		clamp_unit(n2 / scale),
		clamp_unit(n3 / scale),
	}
end

local function copy_colour(c: Colour): Colour
	return {c[1], c[2], c[3]}
end

local function copy_palette(palette: ColourMap): ColourMap
	local copy = {}
	for k, v in pairs(palette) do
		copy[k] = copy_colour(v)
	end
	return copy
end

-----------------------------------------------------------------------------
-- Fetch the maximum allowed width.

function GetMaximumAllowedWidth(screenwidth)
	local settings = GlobalSettings.lookandfeel
	if not settings or not settings.enabled then
		return screenwidth
	end
	return math.min(screenwidth, settings.maxwidth)
end

-----------------------------------------------------------------------------
-- Show the terminators?

function WantTerminators()
	local settings = GlobalSettings.lookandfeel
	if settings then
		return settings.terminators or false
	end
	return true
end

-----------------------------------------------------------------------------
-- Use the dense paragraph layout? (Indents, no space between paragraphs.)

function WantDenseParagraphLayout()
	local settings = GlobalSettings.lookandfeel
	if settings then
		return settings.denseparagraphs or false
	end
	return true
end

-----------------------------------------------------------------------------
-- Display an extra space after full stops?

function WantFullStopSpaces()
	local settings = GlobalSettings.lookandfeel
	if settings then
		return settings.fullstopspaces or false
	end
	return false
end

-----------------------------------------------------------------------------
-- Get the scroll mode.

function GetScrollMode()
	local settings = GlobalSettings.lookandfeel
	if settings then
		return settings.scrollmode
	end
	return "Fixed"
end

-----------------------------------------------------------------------------
-- Addon registration. Create the default global settings.

do
	local function cb()
		GlobalSettings.lookandfeel = MergeTables(GlobalSettings.lookandfeel,
			{
				enabled = false,
				maxwidth = 80,
				terminators = true,
				denseparagraphs = false,
				palette = "Light",
				custom_palettes = {},
				scrollmode = "Fixed",
				fullstopspaces = false,
			}
		)
		RegisterCustomPalettes(GlobalSettings.lookandfeel.custom_palettes)
		SetTheme(GlobalSettings.lookandfeel.palette)
	end

	AddEventListener("RegisterAddons", cb)
end

-----------------------------------------------------------------------------
-- Configuration user interface.

local function find(list, value): number?
	for i, k in ipairs(list) do
		if value == k then
			return i
		end
	end
	return nil
end

local function ensure_custom_palettes(settings)
	settings.custom_palettes = settings.custom_palettes or {}
	return settings.custom_palettes
end

local function edit_theme_palette(theme_name: string, palette: ColourMap, settings)
	local browser = Form.Browser {
		focusable = true,
		type = Form.Browser,
		x1 = 1, y1 = 2,
		x2 = -1, y2 = -3,
	}

	local function rebuild_palette_list()
		local keys = {}
		for k, _ in pairs(palette) do
			keys[#keys+1] = k
		end
		table_sort(keys)

		local data = {}
		for i, key in ipairs(keys) do
			local colour = palette[key]
			data[i] = {
				key = key,
				label = string_format("%s: %s", key, colour_to_hex(colour)),
			}
		end
		browser.data = data
		if #data > 0 then
			browser.cursor = math.min(browser.cursor or 1, #data)
		end
	end

	local function edit_colour_cb(self: Form): ActionResult
		local item = browser.data[browser.cursor]
		if not item then
			return "confirm"
		end

		local key = item.key
		local current = palette[key]
		local default_value = current and colour_to_hex(current) or ""
		local input = PromptForString(
			"Edit colour",
			"Enter colour for "..key.." (#RRGGBB or r g b):",
			default_value)
		if not input then
			return "confirm"
		end

		local colour = parse_colour(input)
		if not colour then
			ModalMessage("Invalid colour",
				"Please enter #RRGGBB or three numbers (0-1 or 0-255).")
			return "confirm"
		end

		palette[key] = colour
		RegisterCustomPalettes(settings.custom_palettes)
		SaveGlobalSettings()
		if settings.palette == theme_name then
			SetTheme(theme_name)
			QueueRedraw()
		end
		return "confirm"
	end

	local dialogue: Form =
	{
		title = "Edit Theme: "..theme_name,
		width = "large",
		height = "large",
		stretchy = false,

		actions = {
			["KEY_RETURN"] = edit_colour_cb,
			["KEY_ENTER"] = edit_colour_cb,
			["e"] = edit_colour_cb,
			["E"] = edit_colour_cb,
		},

		widgets = {
			Form.Label {
				x1 = 1, y1 = 1,
				x2 = -1, y2 = 1,
				value = "Select colour to edit:"
			},

			Form.Label {
				x1 = 1, y1 = -1,
				x2 = -1, y2 = -1,
				value = "ENTER, E: Edit colour    "..ESCAPE_KEY..": Close"
			},

			browser,
		}
	}

	while true do
		rebuild_palette_list()
		local result = Form.Run(dialogue, RedrawScreen)
		QueueRedraw()
		if not result then
			return true
		end
	end
end

function Cmd.ConfigureColourThemes()
	local settings = GlobalSettings.lookandfeel
	local custom_palettes = ensure_custom_palettes(settings)

	local browser = Form.Browser {
		focusable = true,
		type = Form.Browser,
		x1 = 1, y1 = 2,
		x2 = -1, y2 = -4,
	}

	local function rebuild_theme_list()
		local themes = GetThemes()
		local data = {}
		for i, name in ipairs(themes) do
			local label = name
			if name == settings.palette then
				label = "* "..label
			else
				label = "  "..label
			end
			if IsBuiltInTheme(name) then
				label = label.." (built-in)"
			end
			data[i] = { label = label, theme = name }
		end
		browser.data = data
		if #data > 0 then
			local cursor = 1
			for i, item in ipairs(data) do
				if item.theme == settings.palette then
					cursor = i
					break
				end
			end
			browser.cursor = cursor
		end
	end

	local function selected_theme(): string?
		local item = browser.data[browser.cursor]
		return item and item.theme
	end

	local function create_theme_copy(base_name: string): string?
		local base_palette = GetTheme(base_name)
		if not base_palette then
			ModalMessage("Unable to create theme", "Base theme not found.")
			return nil
		end

		local default_name = base_name.." copy"
		local name = PromptForString("New theme",
			"Name for new theme:", default_name)
		if not name then
			return nil
		end

		name = trim(name)
		if name == "" then
			return nil
		end
		if GetTheme(name) then
			ModalMessage("Name in use",
				"A theme named '"..name.."' already exists.")
			return nil
		end

		custom_palettes[name] = copy_palette(base_palette)
		RegisterCustomPalettes(custom_palettes)
		SaveGlobalSettings()
		return name
	end

	local function edit_theme_cb(self: Form): ActionResult
		local name = selected_theme()
		if not name then
			return "confirm"
		end

		if IsBuiltInTheme(name) then
			if not PromptForYesNo("Read-only theme",
				"Built-in themes can't be edited. Create a copy?") then
				return "confirm"
			end
			name = create_theme_copy(name)
			if not name then
				return "confirm"
			end
		end

		local palette = custom_palettes[name]
		if not palette then
			ModalMessage("Missing theme",
				"Theme data not found; try creating a new theme.")
			return "confirm"
		end

		edit_theme_palette(name, palette, settings)
		return "confirm"
	end

	local function new_theme_cb(self: Form): ActionResult
		local base_name = selected_theme() or settings.palette or "Light"
		create_theme_copy(base_name)
		return "confirm"
	end

	local function rename_theme_cb(self: Form): ActionResult
		local name = selected_theme()
		if not name then
			return "confirm"
		end
		if IsBuiltInTheme(name) then
			ModalMessage("Read-only theme",
				"Built-in themes can't be renamed.")
			return "confirm"
		end

		local newname = PromptForString("Rename theme",
			"New name:", name)
		if not newname then
			return "confirm"
		end

		newname = trim(newname)
		if (newname == "") or (newname == name) then
			return "confirm"
		end
		if GetTheme(newname) then
			ModalMessage("Name in use",
				"A theme named '"..newname.."' already exists.")
			return "confirm"
		end

		custom_palettes[newname] = custom_palettes[name]
		custom_palettes[name] = nil
		if settings.palette == name then
			settings.palette = newname
			SetTheme(newname)
		end
		RegisterCustomPalettes(custom_palettes)
		SaveGlobalSettings()
		return "confirm"
	end

	local function delete_theme_cb(self: Form): ActionResult
		local name = selected_theme()
		if not name then
			return "confirm"
		end
		if IsBuiltInTheme(name) then
			ModalMessage("Read-only theme",
				"Built-in themes can't be deleted.")
			return "confirm"
		end

		if not PromptForYesNo("Delete theme",
			"Delete theme '"..name.."'? This cannot be undone.") then
			return "confirm"
		end

		custom_palettes[name] = nil
		RegisterCustomPalettes(custom_palettes)
		if settings.palette == name then
			settings.palette = "Light"
			SetTheme(settings.palette)
		end
		SaveGlobalSettings()
		return "confirm"
	end

	local dialogue: Form =
	{
		title = "Colour Themes",
		width = "large",
		height = "large",
		stretchy = false,

		actions = {
			["KEY_RETURN"] = edit_theme_cb,
			["KEY_ENTER"] = edit_theme_cb,
			["e"] = edit_theme_cb,
			["E"] = edit_theme_cb,
			["n"] = new_theme_cb,
			["N"] = new_theme_cb,
			["r"] = rename_theme_cb,
			["R"] = rename_theme_cb,
			["d"] = delete_theme_cb,
			["D"] = delete_theme_cb,
		},

		widgets = {
			Form.Label {
				x1 = 1, y1 = 1,
				x2 = -1, y2 = 1,
				value = "Select theme:"
			},

			Form.Label {
				x1 = 1, y1 = -2,
				x2 = -1, y2 = -2,
				value = "ENTER, E: Edit theme    N: New theme    R: Rename"
			},

			Form.Label {
				x1 = 1, y1 = -1,
				x2 = -1, y2 = -1,
				value = "D: Delete theme    "..ESCAPE_KEY..": Close"
			},

			browser,
		}
	}

	while true do
		rebuild_theme_list()
		local result = Form.Run(dialogue, RedrawScreen)
		QueueRedraw()
		if not result then
			return true
		end
	end
end

function Cmd.ConfigureLookAndFeel()
	local settings = GlobalSettings.lookandfeel
	local themes = GetThemes()

	local enabled_checkbox =
		Form.Checkbox {
			x1 = 1, y1 = 1,
			x2 = -1, y2 = 1,
			label = "Enable widescreen mode",
			value = settings.enabled
		}

	local maxwidth_textfield =
		Form.TextField {
			x1 = -11, y1 = 3,
			x2 = -1, y2 = 3,
			value = tostring(settings.maxwidth)
		}

	local terminators_checkbox =
		Form.Checkbox {
			x1 = 1, y1 = 5,
			x2 = -1, y2 = 5,
			label = "Show terminators above and below document",
			value = settings.terminators
		}

	local denseparagraphs_checkbox =
		Form.Checkbox {
			x1 = 1, y1 = 7,
			x2 = -1, y2 = 7,
			label = "Use dense paragraph layout",
			value = settings.denseparagraphs
		}

	local fullstopspaces_checkbox =
		Form.Checkbox {
			x1 = 1, y1 = 9,
			x2 = -1, y2 = 9,
			label = "Show an extra space after full stops",
			value = settings.fullstopspaces
		}

	local palette_toggle =
		Form.Toggle {
			x1 = 1, y1 = 11,
			x2 = -1, y2 = 11,
			label = "Colour theme",
			values = themes,
			value = find(themes, settings.palette)
		}

	local function refresh_themes()
		themes = GetThemes()
		palette_toggle.values = themes
		palette_toggle.value = find(themes, settings.palette) or 1
	end

	local scrollmode_toggle =
		Form.Toggle {
			x1 = 1, y1 = 13,
			x2 = -1, y2 = 13,
			label = "Scroll mode",
			values = SCROLLMODES,
			value = find(SCROLLMODES, settings.scrollmode)
		}

	local function edit_themes_cb(self: Form): ActionResult
		Cmd.ConfigureColourThemes()
		refresh_themes()
		return "redraw"
	end

	local dialogue: Form =
	{
		title = "Configure Look and Feel",
		width = "large",
		height = 15,
		stretchy = false,

		actions = {
			["KEY_RETURN"] = "confirm",
			["KEY_ENTER"] = "confirm",
			["t"] = edit_themes_cb,
			["T"] = edit_themes_cb,
		},

		widgets = {
			enabled_checkbox,

			Form.Label {
				x1 = 1, y1 = 3,
				x2 = -12, y2 = 3,
				align = "left",
				value = "Maximum allowed width",
			},
			maxwidth_textfield,

			terminators_checkbox,
			denseparagraphs_checkbox,
			fullstopspaces_checkbox,
			palette_toggle,
			scrollmode_toggle,

			Form.Label {
				x1 = 1, y1 = -1,
				x2 = -1, y2 = -1,
				value = "T: Edit colour themes"
			},
		}
	}

	while true do
		local result = Form.Run(dialogue, RedrawScreen,
			"SPACE to toggle, RETURN to confirm, T to edit themes, "..ESCAPE_KEY.." to cancel")
		if not result then
			return false
		end

		local maxwidth = tonumber(maxwidth_textfield.value)
		if not maxwidth or (maxwidth < 20) then
			ModalMessage("Parameter error", "The maximum width must be a valid number that's at least 20.")
		else
			settings.enabled = enabled_checkbox.value
			settings.maxwidth = maxwidth
			settings.terminators = terminators_checkbox.value
			settings.denseparagraphs = denseparagraphs_checkbox.value
			settings.fullstopspaces = fullstopspaces_checkbox.value
			settings.palette = themes[palette_toggle.value]
			settings.scrollmode = SCROLLMODES[scrollmode_toggle.value]
			SetTheme(settings.palette)
			SaveGlobalSettings()
			UpdateDocumentStyles()

			return true
		end
	end

	return false
end
