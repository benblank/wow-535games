-- $Id$

-- Copyright (c) 2009, Ben Blank
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- * Redistributions of source code must retain the above copyright
--  notice, this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright
--  notice, this list of conditions and the following disclaimer in the
--  documentation and/or other materials provided with the distribution.
--
-- * Neither the name of 535 Design nor the names of its contributors
--  may be used to endorse or promote products derived from this
--  software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED.	IN NO EVENT SHALL THE COPYRIGHT
-- OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local gmt = getmetatable
local mt = {}

function mt.__add(a, b)
	local c = Pool{}

	if gmt(a) == mt then
		for k in pairs(a) do c[k] = true end
	elseif type(a) == "table" then
		for _, v in ipairs(a) do c[v] = true end
	else
		c[a] = true
	end

	if gmt(b) == mt then
		for k in pairs(b) do c[k] = true end
	elseif type(b) == "table" then
		for _, v in ipairs(b) do c[v] = true end
	else
		c[b] = true
	end

	return c
end

function mt.__call(a)
	local keys = {}

	for k, _ in pairs(a) do table.insert(keys, k) end

	return keys[math.random(#keys)]
end

function mt.__mul(a, b)
	if gmt(a) ~= mt or gmt(b) ~= mt then
		error("may only intersect two pools")
	end

	local c = Pool{}

	for k, _ in pairs(a) do c[k] = b[k] end

	return c
end

function mt.__sub(a, b)
	local c = Pool{}

	if gmt(a) == mt then
		for k in pairs(a) do c[k] = true end
	elseif type(a) == "table" then
		for _, v in ipairs(a) do c[v] = true end
	else
		c[a] = true
	end

	if gmt(b) == mt then
		for k in pairs(b) do c[k] = nil end
	elseif type(b) == "table" then
		for _, v in ipairs(b) do c[v] = nil end
	else
		c[b] = nil
	end

	return c
end

function mt.__tostring(a)
	local keys = {}

	for k, _ in pairs(a) do table.insert(keys, k) end

	return "{ " .. table.concat(keys, " ") .. " }"
end

function Pool(a)
	local c = {}

	setmetatable(c, mt)
	for _, v in ipairs(a) do c[v] = true end

	return c
end
