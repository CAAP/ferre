#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.lpr'
local tkt = require'ferre.ticket'

local fd = require'carlos.fold'

local function tickets( q )
    local tag = q.tag
    local person = q.person

-- maybe change to use fd.reduce || another version in stream.lua exists
    local function collect( a )
	local t = {}
	for k,v in a.gmatch'([^%s]+)%s([^%s]+)' do t[k] = v end
	return t
    end

    q.data = fd.reduce( q.args, collect, fd.into, {} )

    lpr( tkt( q ) )

    return 'OK'
end

aux( tickets )

