#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'

local function quot(x)
    if 'table' == type(x) then return string.format('[%s]', table.concat(fd.reduce(x, fd.map(quot), fd.into, {}), ', ')) end
    return tonumber(x) and (math.tointeger(x) or x) or string.format('%q', x)
end 

local JSON = { 'clave', 'desc', 'fecha', 'faltante', 'obs', 'proveedor', 'costol' }

local function tovec(a)
    local ret = fd.reduce( JSON, fd.map(function(k) return quot(a[k] or '') end), fd.into, {} )
    return string.format('[%s]', table.concat(ret, ', '))
end

local function records()
    local conn = assert( sql.connect'/db/ferre.db' )
    local clause = 'WHERE precios.clave == compras.clave AND desc NOT LIKE "VV%"'
    local qry = string.format('SELECT datos.clave, desc, fecha, costol, faltante, obs, proveedor FROM compras, datos %s', clause)

    assert( conn.exec"ATTACH DATABASE '/db/inventario.db' AS NV" )

    local keys = table.concat(fd.reduce(JSON, fd.map( quot ), fd.into, {}), ', ')
    local data = table.concat(fd.reduce( conn.query( qry ), fd.map( tovec ), fd.into, {} ), ', ')
    return string.format('Content-Type: text/html\r\n\r\n[[%s], [%s]]', keys, data)
end

aux( records )

