--!nonstrict
-- Copyright (c) 2008 David Given.
-- WordGrinder is licensed under the MIT open source license. See the COPYING
-- file in this distribution for the full text.

local style_tab: {[string]: {any}} =
{
	["H1"] = {false, '# ', '\n'},
	["H2"] = {false, '## ', '\n'},
	["H3"] = {false, '### ', '\n'},
	-- Gemtext only defines three heading levels; map H4 to H3.
	["H4"] = {false, '### ', '\n'},
	["P"] =  {false, '', '\n'},
	["L"] =  {false, '* ', ''},
	["LB"] = {false, '* ', ''},
	["LN"] = {false, '* ', ''},
	["Q"] =  {false, '> ', '\n'},
	["V"] =  {false, '> ', '\n'},
	["RAW"] = {false, '', ''},
	["PRE"] = {true, '```\n', '\n```\n'}
}

local function callback(writer: (...string) -> (), document: Document)
	local currentpara: string? = nil

	local function changepara(newpara: string?)
		local currentstyle = currentpara and style_tab[currentpara] or nil
		local newstyle = newpara and style_tab[newpara] or nil
		local currentpre = currentstyle and currentstyle[1] or false
		local newpre = newstyle and newstyle[1] or false

		if (newpara ~= currentpara) or
			not newpara or
			not currentpre or
			not newpre
		then
			if currentstyle then
				writer(currentstyle[3])
			end
			writer("\n")
			if newstyle then
				writer(newstyle[2])
			end
			currentpara = newpara
		else
			writer("\n")
		end
	end

	return ExportFileUsingCallbacks(document,
	{
		prologue = function()
		end,

		rawtext = function(s)
			writer(s)
		end,

		text = function(s)
			writer(s)
		end,

		notext = function()
		end,

		italic_on = function()
		end,

		italic_off = function()
		end,

		underline_on = function()
		end,

		underline_off = function()
		end,

		bold_on = function()
		end,

		bold_off = function()
		end,

		list_start = function()
			writer("\n")
		end,

		list_end = function()
			writer("\n")
		end,

		paragraph_start = function(para)
			changepara(para.style)
			if (para.style == "LN") then
				writer(tostring(para.number), ". ")
			end
		end,

		paragraph_end = function(para)
		end,

		epilogue = function()
			changepara(nil)
		end,
	})
end

function Cmd.ExportGemtextFile(filename)
	return ExportFileWithUI(filename, "Export Gemtext File", ".gmi", callback)
end

function Cmd.ExportToGemtextString()
	return ExportToString(currentDocument, callback)
end
