#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.lpr'
local tkt = require'ferre.ticket'

local fd = require'carlos.fold'
local fs = require'carlos.files'

local function tickets( q )

-- maybe change to use fd.reduce || another version in stream.lua exists
    local function collect( a )
	local t = {}
	for k,v in a:gmatch'([^|]+)|([^|]+)' do t[k] = v end
	return t
    end

    q.datos = fd.reduce( q.args, fd.map(collect), fd.into, {} )

    lpr( tkt( q ) )

    return 'OK'
end

aux( tickets )
