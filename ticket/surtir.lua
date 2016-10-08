#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'

local fd = require'carlos.fold'
local sql = require'carlos.sqlite'
local fs = require'carlos.files'

local function int(d) return math.tointeger(d) or d end

-- also found in stream.lua
local function collect( q )
    local t = {}
    for k,v in q:gmatch'([^|]+)|([^|]+)' do t[k] = int(v) end
    return t
end

local conn = sql.connect'/db/ferre.db'

local function getDesc( q )
    local ret = fd.first( conn.query(string.format('SELECT desc FROM precios WHERE clave LIKE %q', q.clave)), function(x) return x end )
    q.desc = ret.desc
    return q
end

local function asstr(q) return string.format('%s\n%s\t%s', q.desc, q.clave, q.qty) end

local function items(q)
    local ret = fd.reduce( q.args, fd.map( collect ), fd.map( getDesc ), fd.map( asstr ), fd.into, {} )
     ret[#ret+1] = '\27\100\7 \27\105'
    lpr( table.concat(ret, '\n') )
    return 'OK'
end

aux( items )
