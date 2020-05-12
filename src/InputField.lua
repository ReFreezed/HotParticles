--[[============================================================
--=
--=  InputField class v1.1 (for LÖVE 0.10.2+) [EDITED]
--=  - Written by Marcus 'ReFreezed' Thunström
--=  - MIT License (See the bottom of this file)
--=
--==============================================================

	update
	mousepressed, mousemoved, mousereleased
	keypressed, textinput

	clearHistory
	getBlinkPhase, resetBlinking
	getCursor, setCursor, moveCursor, getCursorSelectionSide, getAnchorSelectionSide
	getFilter, setFilter
	getFont, setFont
	getScroll, setScroll
	getSelection, setSelection, selectAll, getSelectedText, getSelectedVisibleText
	getText, setText, getVisibleText
	getTextLength
	getTextOffset, getCursorOffset, getSelectionOffset
	getWidth, setWidth
	insert, replace
	isEditable, setEditable
	isFontFilteringActive, setFontFilteringActive
	isPasswordActive, setPasswordActive

----------------------------------------------------------------

	Enums:

	SelectionSide
	- "start": The start (left side) of the text selection
	- "end":   The end (right side) of the text selection

	TextCursorAlignment
	- "left":  Align cursor to the left
	- "right": Align cursor to the right

--============================================================]]



local DOUBLE_CLICK_MAX_DELAY = 0.40 -- Used if pressCount is not supplied to mousepressed().



local LS   = love.system
local LT   = love.timer
local utf8 = require"utf8"

local InputField   = {}
InputField.__index = InputField



--==============================================================
--==============================================================
--==============================================================

local applyFilter
local clamp
local cleanString
local getNextWordBound
local getPositionInText
local isModKeyState
local isNumber, isInteger, isFiniteNumber
local limitScroll



function clamp(n, min, max)
	return math.min(math.max(n, min), max)
end



-- string = cleanString( string [, field ] )
function cleanString(s, self)
	s = s:gsub("[%z\1-\31]+", "")

	if self and self._fontFilteringIsActive then
		local font      = self._font
		local hasGlyphs = font.hasGlyphs

		s = s:gsub(utf8.charpattern, function(c)
			if not hasGlyphs(font, c) then  return ""  end
		end)
	end

	return s
end



-- boundPosition = getNextWordBound( string, startPosition, direction:int )
-- Cursor behavior examples:
--   a|a bb  ->  aa| bb
--   aa| bb  ->  aa bb|
--   aa |bb  ->  aa bb|
--   cc| = dd+ee  ->  cc =| dd+ee
--   cc =| dd+ee  ->  cc = dd|+ee
--   cc = dd|+ee  ->  cc = dd+|ee
--   f|f(-88  ->  ff|(-88
--   ff|(-88  ->  ff(-|88
--   ff(|-88  ->  ff(-|88
do
	local function newSet(values)
		local set = {}
		for _, v in ipairs(values) do
			set[v] = true
		end
		return set
	end

	local punctuation = "!\"#$%&'()*+,-./:;<=>?@[\\]^`{|}~"; punctuation = newSet{punctuation:byte(1, #punctuation)}
	local whitespace  = newSet{9,10,11,12,13,32} -- Horizontal tab, LF, vertical tab, form-feed, CR, space.

	local TYPE_WORD        = 1
	local TYPE_PUNCTUATION = 2
	local TYPE_WHITESPACE  = 3

	local function getCodepointCharType(c)
		if punctuation[c] then return TYPE_PUNCTUATION end
		if whitespace[c]  then return TYPE_WHITESPACE  end
		return TYPE_WORD
	end

	function getNextWordBound(s, pos, dirNum)
		assert(type(s) == "string")
		assert(dirNum == 1 or dirNum == -1)
		assert(isInteger(pos))

		local codepoints = {utf8.codepoint(s, 1, #s)}
		pos = clamp(pos, 0, #codepoints)

		if dirNum < 0 then  pos = pos+1  end

		while true do
			pos = pos+dirNum

			-- Check for end of string.
			local prevC = codepoints[pos]
			local nextC = codepoints[pos+dirNum]
			if not (prevC and nextC) then
				pos = pos+dirNum
				break
			end

			-- Check for word bound.
			local prevType = getCodepointCharType(prevC)
			local nextType = getCodepointCharType(nextC)
			if nextType ~= prevType and not (nextType ~= TYPE_WHITESPACE and prevType == TYPE_WHITESPACE) then
				if dirNum < 0 then  pos = pos-1  end
				break
			end

		end

		return clamp(pos, 0, #codepoints)
	end

end



-- position = getPositionInText( font, string, x )
function getPositionInText(font, s, x)
	x = math.floor(x)
	if (x <= 0) then
		return 0
	end
	local lastW, len = 0, utf8.len(s)
	for pos = 1, len do
		local w = font:getWidth(s:sub(1, utf8.offset(s, pos+1)-1))
		if (w > x and lastW <= x) then
			return pos+(x < lastW+(w-lastW)/2-1 and -1 or 0)
		end
		lastW = w
	end
	return len
end



-- result:boolean = isModKeyState( state:string )
-- Example: isModKeyState("cs") -- returns true if the ctrl and alt keys are pressed and other modifier keys are not
do
	local isDown = love.keyboard.isDown
	if LS.getOS() == "OS X" then
		function isModKeyState(stateStr)
			return (stateStr:find("a", 1, true) ~= nil) == isDown("lalt", "ralt")
			   and (stateStr:find("c", 1, true) ~= nil) == isDown("lgui", "rgui")
			   and (stateStr:find("s", 1, true) ~= nil) == isDown("lshift", "rshift")
		end
	else
		function isModKeyState(stateStr)
			return (stateStr:find("a", 1, true) ~= nil) == isDown("lalt", "ralt")
			   and (stateStr:find("c", 1, true) ~= nil) == isDown("lctrl", "rctrl")
			   and (stateStr:find("s", 1, true) ~= nil) == isDown("lshift", "rshift")
		end
	end
end



function isNumber(v)
	return (v == v and type(v) == "number")
end

function isInteger(v)
	return (isNumber(v) and v == math.floor(v))
end

function isFiniteNumber(v)
	return (isNumber(v) and v ~= math.huge and v ~= -math.huge)
end



function limitScroll(self)
	local limit = self._font:getWidth(self:getVisibleText())-self._width
	self._scroll = math.max(math.min(self._scroll, limit), 0)
end



function applyFilter(self, s)
	local filter = self._filter
	if not filter then  return s  end

	s = s:gsub(utf8.charpattern, function(c)
		if filter(c) then  return ""  end
	end)
	return s
end



--==============================================================
--==============================================================
--==============================================================

local pushHistory
local finilizeHistoryGroup
local undoEdit, redoEdit



function pushHistory(self, group)
	-- @Incomplete: Don't save history for password fields.
	local history = self._editHistory
	local i, state

	if group and group == self._editHistoryGroup then
		i     = self._editHistoryIndex
		state = history[i]

	else
		i     = self._editHistoryIndex+1
		state = {}
		history[i] = state
	end

	for i = i+1, #history do
		history[i] = nil
	end

	state.text           = self._text
	state.cursorPosition = self._cursorPosition
	state.selectionStart = self._selectionStart
	state.selectionEnd   = self._selectionEnd

	self._editHistoryIndex = i
	self._editHistoryGroup = group
end



function finilizeHistoryGroup(self)
	self._editHistoryGroup = nil
end



do
	local function applyHistoryState(self, offset)
		self._editHistoryIndex = self._editHistoryIndex+offset

		local state = self._editHistory[self._editHistoryIndex] or assert(false)

		self._text           = state.text
		self._cursorPosition = state.cursorPosition
		self._selectionStart = state.selectionStart
		self._selectionEnd   = state.selectionEnd
	end

	-- @Incomplete: Improve how the cursor and selection are restored on undo.
	function undoEdit(self)
		if self._editHistoryIndex == 1 then  return  end

		finilizeHistoryGroup(self)
		applyHistoryState(self, -1)
	end

	function redoEdit(self)
		if self._editHistoryIndex == #self._editHistory then  return  end

		finilizeHistoryGroup(self)
		applyHistoryState(self, 1)
	end
end



--==============================================================
--==============================================================
--==============================================================



-- InputField( [ initialText="" ] )
function InputField:init(text)
	text = cleanString(tostring(text == nil and "" or text))

	local len  = utf8.len(text)
	self._text = text

	self._editHistory = {{
		text           = text,
		cursorPosition = len,
		selectionStart = 0,
		selectionEnd   = len,
	}}
end



-- update( deltaTime )
local speed = 5
function InputField:update(dt)

	-- Update scrolling
	local mx = self._mouseScrollX
	local scroll, w = self._scroll, self._width
	if (mx) then
		scroll = (mx < 0 and scroll+speed*mx*dt) or (mx > w and scroll+speed*(mx-w)*dt) or (scroll)
	else
		local visibleText = self:getVisibleText()
		local preText = visibleText:sub(1, utf8.offset(visibleText, self._cursorPosition+1)-1)
		local x = self._font:getWidth(preText)
		scroll = clamp(scroll, x-w, x)
	end
	self._scroll = scroll
	limitScroll(self)

end



--==============================================================



function InputField:getBlinkPhase()
	return LT.getTime()-self._blinkTimer
end

function InputField:resetBlinking()
	self._blinkTimer = LT.getTime()
end



-- position = getCursor( )
function InputField:getCursor()
	return self._cursorPosition
end

-- setCursor( position [, selectionSideToAnchor:SelectionSide ] )
function InputField:setCursor(pos, selSideAnchor)
	finilizeHistoryGroup(self)

	pos = clamp(pos, 0, self:getTextLength())
	self._cursorPosition = pos

	local selStart = (selSideAnchor == "start" and self._selectionStart or pos)
	local selEnd   = (selSideAnchor == "end"   and self._selectionEnd   or pos)
	self._selectionStart = math.min(selStart, selEnd)
	self._selectionEnd   = math.max(selStart, selEnd)

	self:resetBlinking()
end

-- moveCursor( amount [, selectionSideToAnchor:SelectionSide ] )
function InputField:moveCursor(amount, selSideAnchor)
	self:setCursor(self._cursorPosition+amount, selSideAnchor)
end

-- side:SelectionSide = getCursorSelectionSide( )
function InputField:getCursorSelectionSide()
	return (self._cursorPosition < self._selectionEnd and "start" or "end")
end

-- side:SelectionSide = getAnchorSelectionSide( )
function InputField:getAnchorSelectionSide()
	return (self._cursorPosition < self._selectionEnd and "end" or "start")
end



function InputField:getFont()      return self._font  end
function InputField:setFont(font)  self._font = font  end



function InputField:getScroll()
	return self._scroll
end

function InputField:setScroll(scroll)
	self._scroll = scroll
	limitScroll(self)
end



-- from, to = getSelection( )
function InputField:getSelection()
	return self._selectionStart, self._selectionEnd
end

-- setSelection( from, to [, cursorAlign:TextCursorAlignment="right" ] )
function InputField:setSelection(from, to, cursorAlign)
	finilizeHistoryGroup(self)

	local len = self:getTextLength()
	from = clamp(from, 0, len)
	to   = clamp(to,   0, len)

	from, to = math.min(from, to), math.max(from, to)

	self._selectionStart = from
	self._selectionEnd   = to
	self._cursorPosition = (cursorAlign == "left" and from or to)

	self:resetBlinking()
end

function InputField:selectAll()
	self:setSelection(0, self:getTextLength())
end

function InputField:getSelectedText()
	local text = self._text
	local i1 = utf8.offset(text, self._selectionStart+1)
	local i2 = utf8.offset(text, self._selectionEnd+1)-1
	return text:sub(i1, i2)
end

function InputField:getSelectedVisibleText()
	return self._isPassword and ("*"):rep(self._selectionEnd-self._selectionStart) or self:getSelectedText()
end



function InputField:getText()  return self._text  end

-- setText( text [, replaceLastHistoryEntry=false ] )
function InputField:setText(text, replaceLastHistoryEntry)
	text = cleanString(tostring(text), self)
	if self._text == text then  return  end

	local len = utf8.len(text)

	self._text           = text
	self._cursorPosition = math.min(len, self._cursorPosition)
	self._selectionStart = math.min(len, self._selectionStart)
	self._selectionEnd   = math.min(len, self._selectionEnd)

	if replaceLastHistoryEntry then
		local state = self._editHistory[self._editHistoryIndex]
		state.text           = self._text
		state.cursorPosition = self._cursorPosition
		state.selectionStart = self._selectionStart
		state.selectionEnd   = self._selectionEnd
	else
		pushHistory(self)
	end
end

function InputField:getVisibleText()
	return (self._isPassword and ("*"):rep(self:getTextLength()) or self._text)
end



-- length = getTextLength( )
-- Length is number of characters in the UTF-8 text string.
function InputField:getTextLength()
	return utf8.len(self._text)
end



function InputField:getTextOffset()
	return -math.floor(self._scroll)
end

function InputField:getCursorOffset()
	local visibleText = self:getVisibleText()
	local preText = visibleText:sub(1, utf8.offset(visibleText, self._cursorPosition+1)-1)
	return self._font:getWidth(preText)-math.floor(self._scroll)
end

-- left, right = getSelectionOffset( )
function InputField:getSelectionOffset()
	-- @Incomplete: Handle kerning on the right end of the selection.
	local font, visibleText = self._font, self:getVisibleText()
	local preText1 = visibleText:sub(1, utf8.offset(visibleText, self._selectionStart+1)-1)
	local preText2 = visibleText:sub(1, utf8.offset(visibleText, self._selectionEnd+1)-1)
	local scroll = math.floor(self._scroll)
	return font:getWidth(preText1)-scroll,
	       font:getWidth(preText2)-scroll
end



function InputField:getWidth()   return self._width  end
function InputField:setWidth(w)  self._width = w     end



do
	local function insertText(self, newText)
		local text = self._text
		local pos  = self._cursorPosition
		local i    = utf8.offset(text, pos+1)

		self._text           = text:sub(1, i-1)..newText..text:sub(i)
		self._cursorPosition = pos+utf8.len(newText)
		self._selectionStart = self._cursorPosition
		self._selectionEnd   = self._cursorPosition

		pushHistory(self, "insert")
		self:resetBlinking()
	end

	-- Insert text at cursor position
	function InputField:insert(newText)
		insertText(self, cleanString(tostring(newText), self))
	end

	-- Replace text selection with another text
	function InputField:replace(newText)
		newText = cleanString(tostring(newText), self)

		local text     = self._text
		local selStart = self._selectionStart
		local i1       = utf8.offset(text, selStart+1)
		local i2       = utf8.offset(text, self._selectionEnd+1)

		self._text           = text:sub(1, i1-1)..text:sub(i2)
		self._selectionEnd   = selStart
		self._cursorPosition = selStart

		if newText == "" then
			pushHistory(self, "remove")
			self:resetBlinking()
		else
			insertText(self, newText)
		end
	end
end



function InputField:isFontFilteringActive()        return self._fontFilteringIsActive   end
function InputField:setFontFilteringActive(state)  self._fontFilteringIsActive = state  end

function InputField:isPasswordActive()        return self._isPassword   end
function InputField:setPasswordActive(state)  self._isPassword = state  end

function InputField:isEditable()        return self._isEditable   end
function InputField:setEditable(state)  self._isEditable = state  end

-- setFilter( filterFunction )
-- removeCharacter = filterFunction( character )
-- filterFunction==nil removes the filter.
-- Note: The filter is only used for input functions, like textinput().
-- setText() etc. are unaffected (unlike with font filtering).
function InputField:getFilter()        return self._filter    end
function InputField:setFilter(filter)  self._filter = filter  end



function InputField:clearHistory()
	local history = self._editHistory

	history[1] = history[#history]
	for i = 2, #history do  history[i] = nil  end

	self._editHistoryGroup = nil
	self._editHistoryIndex = 1
end



----------------------------------------------------------------



-- wasHandled = mousepressed( x, y, button [, pressCount ] )
function InputField:mousepressed(x, y, buttonN, pressCount)
	if buttonN ~= 1 then return false end

	-- Check if double click.
	local isDoubleClick = false

	if buttonN == 1 then
		local time = LT.getTime()

		if pressCount then
			isDoubleClick = pressCount%2 == 0
		else
			isDoubleClick = (
				time < self._doubleClickExpirationTime
				and math.abs(self._doubleClickLastX-x) <= 1
				and math.abs(self._doubleClickLastY-y) <= 1
			)
		end

		self._doubleClickExpirationTime = isDoubleClick and 0 or time+DOUBLE_CLICK_MAX_DELAY
		self._doubleClickLastX          = x
		self._doubleClickLastY          = y

	else
		self._doubleClickExpirationTime = 0.0
	end

	-- Handle mouse press.
	local visibleText = self:getVisibleText()
	local pos         = getPositionInText(self._font, visibleText, x+self._scroll)

	if isDoubleClick then
		pos = getNextWordBound(visibleText, pos+1, -1)

		self:setSelection(pos, getNextWordBound(visibleText, pos, 1))

	elseif isModKeyState"s" then
		local anchorPos = (self:getAnchorSelectionSide() == "start" and self._selectionStart or self._selectionEnd)

		self:setSelection(pos, anchorPos, (pos < anchorPos and "left" or "right"))

		self._mouseTextSelectionStart = anchorPos
		self._mouseScrollX            = x

	else
		self:setCursor(pos)

		self._mouseTextSelectionStart = pos
		self._mouseScrollX            = x
	end

	return true
end

-- wasHandled = mousemoved( x, y )
function InputField:mousemoved(x, y)
	if not self._mouseTextSelectionStart then  return false  end

	local pos = getPositionInText(self._font, self:getVisibleText(), x+self._scroll)

	self:setSelection(
		self._mouseTextSelectionStart,
		pos,
		(pos < self._mouseTextSelectionStart and "left" or "right")
	)

	self._mouseScrollX = x
	return true
end

-- wasHandled = mousereleased( x, y, button )
function InputField:mousereleased(x, y, buttonN)
	if (buttonN ~= 1) then return false end
	if (not self._mouseTextSelectionStart) then
		return false
	end
	self._mouseTextSelectionStart = nil
	self._mouseScrollX = nil
	return true
end



-- wasHandled, wasEdited = keypressed( key, scancode, isRepeat )
function InputField:keypressed(key, scancode, isRepeat)
	-- Left: Move cursor to the left
	if (key == "left" and isModKeyState"") then
		if (self._selectionStart ~= self._selectionEnd) then
			self:setCursor(self._selectionStart)
		else
			self:moveCursor(-1)
		end
	-- Shift+Left: Move cursor to the left and preserve selection
	elseif (key == "left" and isModKeyState"s") then
		self:moveCursor(-1, self:getAnchorSelectionSide())
	-- Ctrl+Left: Move cursor to the previous word
	elseif (key == "left" and isModKeyState"c") then
		self:setCursor(getNextWordBound(self:getVisibleText(), self._cursorPosition, -1))
	-- Ctrl+Shift+Left: Move cursor to the previous word and preserve selection
	elseif (key == "left" and isModKeyState"cs") then
		self:setCursor(getNextWordBound(self:getVisibleText(), self._cursorPosition, -1), self:getAnchorSelectionSide())

	-- Right: Move cursor to the right
	elseif (key == "right" and isModKeyState"") then
		if (self._selectionStart ~= self._selectionEnd) then
			self:setCursor(self._selectionEnd)
		else
			self:moveCursor(1)
		end
	-- Shift+Right: Move cursor to the right and preserve selection
	elseif (key == "right" and isModKeyState"s") then
		self:moveCursor(1, self:getAnchorSelectionSide())
	-- Ctrl+Right: Move cursor to the next word
	elseif (key == "right" and isModKeyState"c") then
		self:setCursor(getNextWordBound(self:getVisibleText(), self._cursorPosition, 1))
	-- Ctrl+Shift+Right: Move cursor to the next word and preserve selection
	elseif (key == "right" and isModKeyState"cs") then
		self:setCursor(getNextWordBound(self:getVisibleText(), self._cursorPosition, 1), self:getAnchorSelectionSide())

	-- Home: Move cursor to start
	elseif (key == "home" and isModKeyState"") then
		self:setCursor(0)
	-- Shift+Home: Move cursor to start and preserve selection
	elseif (key == "home" and isModKeyState"s") then
		self:setCursor(0, self:getAnchorSelectionSide())

	-- End: Move cursor to end
	elseif (key == "end" and isModKeyState"") then
		self:setCursor(self:getTextLength())
	-- Shift+End: Move cursor to end and preserve selection
	elseif (key == "end" and isModKeyState"s") then
		self:setCursor(self:getTextLength(), self:getAnchorSelectionSide())

	-- Backspace: Remove selection, previous character, or previous word
	elseif (self._isEditable and key == "backspace") then
		if (self._selectionStart ~= self._selectionEnd) then
			-- void
		elseif (isModKeyState"c") then
			self._cursorPosition = getNextWordBound(self:getVisibleText(), self._cursorPosition, -1)
			self._selectionStart = self._cursorPosition
		elseif (self._cursorPosition == 0) then
			self:resetBlinking()
			return true, true
		else
			self._selectionStart = self._cursorPosition-1
			self._selectionEnd = self._cursorPosition
		end
		self:replace("")
		return true, true

	-- Delete: Remove selection, next character, or next word
	elseif (self._isEditable and key == "delete") then
		if self._selectionStart ~= self._selectionEnd then
			-- void
		elseif isModKeyState"c" then
			self._cursorPosition = getNextWordBound(self:getVisibleText(), self._cursorPosition, 1)
			self._selectionEnd = self._cursorPosition
		elseif self._cursorPosition == self:getTextLength() then
			self:resetBlinking()
			return true, true
		else
			self._selectionStart = self._cursorPosition
			self._selectionEnd = self._cursorPosition+1
		end
		self:replace("")
		return true, true

	-- Ctrl+A: Select all text
	elseif (key == "a" and isModKeyState"c") then
		self:selectAll()

	-- Ctrl+C or Ctrl+Insert: Copy selected text
	elseif (key == "c" and isModKeyState"c") or (key == "insert" and isModKeyState"c") then
		local text = self:getSelectedVisibleText()
		if (text ~= "") then
			LS.setClipboardText(text)
			self:resetBlinking()
		end

	-- Ctrl+X: Cut selected text (or copy if not editable)
	elseif (key == "x" and isModKeyState"c") then
		local text = self:getSelectedVisibleText()
		if (text ~= "") then
			LS.setClipboardText(text)
			if (self._isEditable) then
				self:replace("")
				return true, true
			else
				self:resetBlinking()
			end
		end

	-- Ctrl+V or Shift+Insert: Paste copied text
	elseif (self._isEditable) and ((key == "v" and isModKeyState"c") or (key == "insert" and isModKeyState"s")) then
		local text = cleanString(LS.getClipboardText(), self)
		if (text ~= "") then
			self:replace(applyFilter(self, text))
		end
		self:resetBlinking()
		return true, true

	-- Ctrl+Z: Undo text edit
	elseif (self._isEditable and key == "z" and isModKeyState"c") then
		-- @Robustness: Filter and/or font filter could have changed after the last edit.
		if not self._isPassword then  undoEdit(self)  end
		return true, true

	-- Ctrl+Shift+Z or Ctrl+Y: Redo text edit
	elseif (self._isEditable) and ((key == "z" and isModKeyState"cs") or (key == "y" and isModKeyState"c")) then
		-- @Robustness: Filter and/or font filter could have changed after the last edit.
		if not self._isPassword then  redoEdit(self)  end
		return true, true

	else
		return false, false
	end

	return true, false
end

-- wasHandled, wasEdited = textinput( text )
function InputField:textinput(text)
	if not self._isEditable then  return true, false  end

	text = applyFilter(self, text)

	if self._selectionStart ~= self._selectionEnd then
		self:replace(text)
	else
		self:insert(text)
	end

	return true, true
end



--==============================================================
--==============================================================
--==============================================================

return function(...)
	local field = {
		_blinkTimer                = 0,

		_cursorPosition            = 0,
		_selectionStart            = 0,
		_selectionEnd              = 0,

		_doubleClickExpirationTime = 0.0,
		_doubleClickLastX          = 0.0,
		_doubleClickLastY          = 0.0,

		_editHistory               = nil,
		_editHistoryIndex          = 1,
		_editHistoryGroup          = nil,

		_font                      = love.graphics.getFont(),
		_fontFilteringIsActive     = false,

		_mouseScrollX              = nil,
		_mouseTextSelectionStart   = nil,

		_isEditable                = true,
		_isPassword                = false,

		_filter                    = nil,
		_scroll                    = 0,
		_text                      = "",
		_width                     = math.huge,
	}
	setmetatable(field, InputField):init(...)
	return field
end

--==============================================================
--=
--=  MIT License
--=
--=  Copyright © 2017-2019 Marcus 'ReFreezed' Thunström
--=
--=  Permission is hereby granted, free of charge, to any person obtaining a copy
--=  of this software and associated documentation files (the "Software"), to deal
--=  in the Software without restriction, including without limitation the rights
--=  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--=  copies of the Software, and to permit persons to whom the Software is
--=  furnished to do so, subject to the following conditions:
--=
--=  The above copyright notice and this permission notice shall be included in all
--=  copies or substantial portions of the Software.
--=
--=  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--=  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--=  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--=  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--=  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--=  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--=  SOFTWARE.
--=
--==============================================================
