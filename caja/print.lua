#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'
local tkt = require'ferre.ticket'

local fd = require'carlos.fold'
local fs = require'carlos.files'
local sql = require'carlos.sqlite'

local function tickets( q )
-- XXX unify with stream.lua
    local dbname = string.format('/db/%s.db', q.week)
    local conn1 = assert( sql.connect( dbname ) )
    local qry1 = 'SELECT * FROM tickets WHERE uid LIKE %q'

    local conn2 = assert( sql.connect'/db/ferre.db' )

    local function asTable( s )
	local t = {}
	for k,v in s:gmatch'([^|]+)|([^|]+)' do t[k] = v end
	return t
    end

    local function addDescPrc( w )
	assert(w.precio)
	local j = w.precio:sub(-1)
	local qry = string.format('SELECT desc, precio%d ||"/"|| IFNULL(u%d,"?") prc FROM precios WHERE clave LIKE %q', j, j, w.clave)
	local a = fd.first( conn2.query(qry), function(x) return x end )
	w.desc = a.desc; w.prc = a.prc;
	return w
    end

    local function subTotal( w )
	w.subTotal = string.format( '%.2f', w.totalCents / 100 )
	return w
    end

    local function fetch( w )
	w.fecha = w.uid:match'([^P]+)P'
	assert(w.uid)
	w.datos = fd.reduce( conn1.query(string.format(qry1, w.uid)), fd.map( addDescPrc ), fd.map( subTotal ), fd.into, {} )
	return w
    end

--    lpr( tkt( fetch( q ) ) )
    fs.dump( '/cgi-bin/ferre/caja/test.txt', tkt( fetch( q ) ) )

    return 'OK'
end

aux( tickets )
