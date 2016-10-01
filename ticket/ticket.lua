#!/usr/local/bin/lua

local socket = require"socket"
local fd = require'carlos.fold'
local hd = require'ferre.header'
local sql = require'carlos.sqlite'
local mx = require'ferre.timezone'

local hoy = os.date('%d-%b-%y', mx())
local today = os.date('%F', mx())
local week = os.date('W%U', mx())
local dbname = string.format('/db/%s.db', week)
local fdbname = '/db/ferre.db'

local function asJSON(w) return string.format('data: %s', hd.asJSON(w)) end

local function tickets(conn)
    local tbname = 'tickets'
    local vwname = 'caja'
    local schema = 'uid, id_tag, clave, precio, qty INTEGER, rea INTEGER, totalCents INTEGER'
    local keys = { uid=1, id_tag=2, clave=3, precio=4, qty=5, rea=6, totalCents=7 }
    local stmt = string.format('AS SELECT uid, SUM(qty) count, SUM(totalCents) totalCents, id_tag FROM %q WHERE uid LIKE %q GROUP BY uid', tbname, today..'%')
    local query = 'SELECT * FROM ' .. vwname

    function MM.init()
	conn.exec( string.format(sql.newTable, tbname, schema) )
	conn.exec( string.format('DROP VIEW IF EXISTS %q', vwname) )
	conn.exec( string.format('CREATE VIEW IF NOT EXISTS %q %s', vwname, stmt) )
    end

-- XXX input is not parsed to Number
    function MM.add( w )
	local uid = os.date('%FT%TP', mx()) .. w.pid
	fd.reduce( w.args, fd.map( collect ), ids( uid, w.id_tag ), sql.into( tbname ), conn )
	local a = fd.first( conn.query(string.format('%s WHERE uid = %q ', query, uid)), function(x) return x end )
	w.uid = uid; w.totalCents = a.totalCents; w.count = a.count
	forPrinting( w )
	MM.tabs.remove( w.pid )
	return w
    end

    function MM.sse()
	if conn.count( vwname ) == 0 then return ':empty\n\n'
	else return sse{ data=table.concat( fd.reduce(conn.query(query), fd.map(asJSON), fd.into, {} ), ',\n'), event='feed' } end
    end

    return conn
end

