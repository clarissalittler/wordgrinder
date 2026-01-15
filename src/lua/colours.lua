--!nonstrict
-- © 2022 David Given.
-- WordGrinder is licensed under the MIT open source license. See the COPYING
-- file in this distribution for the full text.

local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local string_char = string.char

local function MakeDark(): ColourMap
	local ink = {1, 1, 1}
	local paper = {0.2, 0.2, 0.2}
	local headerfg = {1, 1, 0}
	local headerbg = {0.3, 0.3, 0.3}

	return {
		Desktop      = {0.135, 0.135, 0.135},
		Paper        = paper,
		MarkerFG     = {0.100, 0.500, 0.500},
		StatusbarBG  = {0.140, 0.220, 0.400},
		StatusbarFG  = {0.800, 0.700, 0.200},
		MessageBG    = {0.140, 0.220, 0.400},
		MessageFG    = {0.800, 0.700, 0.200},
		StyleFG      = {0.500, 0.500, 0.500},
		ControlFG    = {1.000, 1.000, 0.000},
		ControlBG    = {0.140, 0.220, 0.400},
		H1_BG        = headerbg,
		H1_FG        = headerfg,
		H2_BG        = headerbg,
		H2_FG        = headerfg,
		H3_BG        = paper,
		H3_FG        = headerfg,
		H4_BG        = paper,
		H4_FG        = headerfg,
		LN_BG        = paper,
		LN_FG        = ink,
		LB_BG        = paper,
		LB_FG        = ink,
		L_BG         = paper,
		L_FG         = ink,
		PRE_BG       = paper,
		PRE_FG       = ink,
		P_BG		 = paper,
		P_FG         = ink,
		Q_BG         = paper,
		Q_FG         = ink,
		RAW_BG       = paper,
		RAW_FG       = ink,
		V_BG         = paper,
		V_FG         = ink,
	}
end

local function MakeLight(): ColourMap
	local ink = {0, 0, 0}
	local paper = {0.760, 0.760, 0.730}
	local headerfg = {0.14, 0.22, 0.40}
	local headerbg = {0.66, 0.66, 0.66}

	return {
		Desktop      = {0.510, 0.500, 0.470},
		Paper        = paper,
		MarkerFG     = {0.250, 0.250, 0.250},
		StatusbarBG  = {0.140, 0.220, 0.400},
		StatusbarFG  = {0.800, 0.700, 0.200},
		MessageBG    = {0.140, 0.220, 0.400},
		MessageFG    = {0.800, 0.700, 0.200},
		StyleFG      = {0.200, 0.200, 0.200},
		ControlFG    = {0.200, 0.200, 0.200},
		ControlBG    = {0.850, 0.850, 0.850},
		H1_BG        = headerbg,
		H1_FG        = headerfg,
		H2_BG        = headerbg,
		H2_FG        = headerfg,
		H3_BG        = paper,
		H3_FG        = ink,
		H4_BG        = paper,
		H4_FG        = ink,
		LN_BG        = paper,
		LN_FG        = ink,
		LB_BG        = paper,
		LB_FG        = ink,
		L_BG         = paper,
		L_FG         = ink,
		PRE_BG       = paper,
		PRE_FG       = ink,
		P_BG         = paper,
		P_FG         = ink,
		Q_BG         = paper,
		Q_FG         = ink,
		RAW_BG       = paper,
		RAW_FG       = ink,
		V_BG         = paper,
		V_FG         = ink,
	}
end

local function MakeClassic(): ColourMap
	local ink = {0.8, 0.8, 0.8}
	local white = {1, 1, 1}
	local black = {0, 0, 0}
	local yellow = {1, 1, 0}

	return {
		Desktop      = black,
		Paper        = black,
		MarkerFG     = white,
		StatusbarFG  = black,
		StatusbarBG  = white,
		MessageFG    = black,
		MessageBG    = white,
		StyleFG      = {0.500, 0.500, 0.500},
		ControlFG    = white,
		ControlBG    = black,
		H1_BG        = black,
		H1_FG        = yellow,
		H2_BG        = black,
		H2_FG        = yellow,
		H3_BG        = black,
		H3_FG        = yellow,
		H4_BG        = black,
		H4_FG        = yellow,
		LN_BG        = black,
		LN_FG        = ink,
		LB_BG        = black,
		LB_FG        = ink,
		L_BG         = black,
		L_FG         = ink,
		PRE_BG       = black,
		PRE_FG       = ink,
		P_BG         = black,
		P_FG         = ink,
		Q_BG         = black,
		Q_FG         = ink,
		RAW_BG       = black,
		RAW_FG       = ink,
		V_BG         = black,
		V_FG         = ink,
	}
end

local function MakeForest(): ColourMap
	local ink = {0.90, 0.93, 0.88}
	local paper = {0.12, 0.17, 0.13}
	local headerfg = {0.85, 0.95, 0.72}
	local headerbg = {0.18, 0.25, 0.18}

	return {
		Desktop      = {0.10, 0.14, 0.11},
		Paper        = paper,
		MarkerFG     = {0.35, 0.62, 0.48},
		StatusbarBG  = {0.14, 0.23, 0.19},
		StatusbarFG  = {0.90, 0.82, 0.58},
		MessageBG    = {0.14, 0.23, 0.19},
		MessageFG    = {0.90, 0.82, 0.58},
		StyleFG      = {0.50, 0.60, 0.50},
		ControlFG    = {0.90, 0.90, 0.80},
		ControlBG    = {0.21, 0.30, 0.23},
		H1_BG        = headerbg,
		H1_FG        = headerfg,
		H2_BG        = headerbg,
		H2_FG        = headerfg,
		H3_BG        = paper,
		H3_FG        = headerfg,
		H4_BG        = paper,
		H4_FG        = headerfg,
		LN_BG        = paper,
		LN_FG        = ink,
		LB_BG        = paper,
		LB_FG        = ink,
		L_BG         = paper,
		L_FG         = ink,
		PRE_BG       = paper,
		PRE_FG       = ink,
		P_BG         = paper,
		P_FG         = ink,
		Q_BG         = paper,
		Q_FG         = ink,
		RAW_BG       = paper,
		RAW_FG       = ink,
		V_BG         = paper,
		V_FG         = ink,
	}
end

local function MakeAutumn(): ColourMap
	local ink = {0.96, 0.90, 0.82}
	local paper = {0.22, 0.16, 0.11}
	local headerfg = {0.98, 0.78, 0.40}
	local headerbg = {0.32, 0.22, 0.14}

	return {
		Desktop      = {0.18, 0.13, 0.09},
		Paper        = paper,
		MarkerFG     = {0.85, 0.55, 0.25},
		StatusbarBG  = {0.28, 0.19, 0.12},
		StatusbarFG  = {0.98, 0.82, 0.55},
		MessageBG    = {0.28, 0.19, 0.12},
		MessageFG    = {0.98, 0.82, 0.55},
		StyleFG      = {0.60, 0.52, 0.40},
		ControlFG    = {0.96, 0.90, 0.82},
		ControlBG    = {0.35, 0.24, 0.16},
		H1_BG        = headerbg,
		H1_FG        = headerfg,
		H2_BG        = headerbg,
		H2_FG        = headerfg,
		H3_BG        = paper,
		H3_FG        = headerfg,
		H4_BG        = paper,
		H4_FG        = headerfg,
		LN_BG        = paper,
		LN_FG        = ink,
		LB_BG        = paper,
		LB_FG        = ink,
		L_BG         = paper,
		L_FG         = ink,
		PRE_BG       = paper,
		PRE_FG       = ink,
		P_BG         = paper,
		P_FG         = ink,
		Q_BG         = paper,
		Q_FG         = ink,
		RAW_BG       = paper,
		RAW_FG       = ink,
		V_BG         = paper,
		V_FG         = ink,
	}
end

local function MakeSakura(): ColourMap
	local ink = {0.20, 0.16, 0.19}
	local paper = {0.98, 0.95, 0.96}
	local headerfg = {0.47, 0.18, 0.30}
	local headerbg = {0.92, 0.84, 0.88}

	return {
		Desktop      = {0.90, 0.84, 0.88},
		Paper        = paper,
		MarkerFG     = {0.60, 0.24, 0.34},
		StatusbarBG  = {0.83, 0.70, 0.78},
		StatusbarFG  = {0.20, 0.12, 0.18},
		MessageBG    = {0.83, 0.70, 0.78},
		MessageFG    = {0.20, 0.12, 0.18},
		StyleFG      = {0.35, 0.26, 0.30},
		ControlFG    = {0.30, 0.18, 0.25},
		ControlBG    = {0.94, 0.89, 0.92},
		H1_BG        = headerbg,
		H1_FG        = headerfg,
		H2_BG        = headerbg,
		H2_FG        = headerfg,
		H3_BG        = paper,
		H3_FG        = ink,
		H4_BG        = paper,
		H4_FG        = ink,
		LN_BG        = paper,
		LN_FG        = ink,
		LB_BG        = paper,
		LB_FG        = ink,
		L_BG         = paper,
		L_FG         = ink,
		PRE_BG       = paper,
		PRE_FG       = ink,
		P_BG         = paper,
		P_FG         = ink,
		Q_BG         = paper,
		Q_FG         = ink,
		RAW_BG       = paper,
		RAW_FG       = ink,
		V_BG         = paper,
		V_FG         = ink,
	}
end

local BuiltInPalettes: {[string]: ColourMap} = {
	Dark = MakeDark(),
	Light = MakeLight(),
	Classic = MakeClassic(),
	Forest = MakeForest(),
	Autumn = MakeAutumn(),
	Sakura = MakeSakura(),
}

local Palettes: {[string]: ColourMap} = {}

local function rebuild_palettes(custom: {[string]: ColourMap}?)
	Palettes = {}
	for name, palette in pairs(BuiltInPalettes) do
		Palettes[name] = palette
	end
	if custom then
		for name, palette in pairs(custom) do
			Palettes[name] = palette
		end
	end
end

rebuild_palettes(nil)

function RegisterCustomPalettes(custom: {[string]: ColourMap}?)
	rebuild_palettes(custom)
end

function IsBuiltInTheme(theme: string): boolean
	return BuiltInPalettes[theme] ~= nil
end

function GetTheme(theme: string): ColourMap?
	return Palettes[theme]
end

-----------------------------------------------------------------------------
-- Gets the list of themes.

function GetThemes(): {string}
	local t = {}
	for n, _ in pairs(Palettes) do
		t[#t+1] = n
	end
	table_sort(t)
	return t
end

-----------------------------------------------------------------------------
-- Configures the current theme.

function SetTheme(theme: string)
	Palette = Palettes[theme] or {}
end

-----------------------------------------------------------------------------
-- Actually sets a style for drawing.

function SetColour(fg: Colour?, bg: Colour?)
	if not fg then
		fg = {1.0, 1.0, 1.0}
	end
	assert(fg)

	if not bg then
		bg = {0.0, 0.0, 0.0}
	end
	assert(bg)

	wg.setcolour(fg, bg)
end
