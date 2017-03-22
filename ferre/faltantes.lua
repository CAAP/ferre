#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'

local function asint(x) return math.tointeger(x) or string.format('%q', x) end

local function records()
    local conn = assert( sql.connect'/db/ferre.db' )
    local clause = 'WHERE faltante = 1 AND precios.clave == stock.clave AND desc NOT LIKE "VV%" ORDER BY proveedor, desc'
    local qry = string.format('SELECT stock.clave FROM stock, precios %s', clause)

    assert( conn.exec"ATTACH DATABASE '/db/inventario.db' AS NV" )

    local data = table.concat(fd.reduce( conn.query( qry ), fd.map( function(w) return asint(w.clave) end ), fd.into, {} ), ', ')
    return string.format('Content-Type: text/html\r\n\r\n[%s]', keys, data)
end

aux( records )

