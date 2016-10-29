#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'

local function quot(x)
    if 'table' == type(x) then return string.format('[%s]', table.concat(fd.reduce(x, fd.map(quot), fd.into, {}), ', ')) end
    return tonumber(x) and (math.tointeger(x) or x) or string.format('%q', x)
end 

local JSON = {'clave', 'obs', 'proveedor'} --{ 'fecha', 'clave', 'desc', 'costol', 'obs', 'proveedor' }

local function tovec(a)
    local ret = fd.reduce( JSON, fd.map(function(k) return quot(a[k] or '') end), fd.into, {} )
    return string.format('[%s]', table.concat(ret, ', '))
end

local function records()
--    local conn = assert( sql.connect'/db/ferre.db' )
--    local clause = 'WHERE faltante = 1 AND datos.clave == proveedores.clave AND datos.clave == faltantes.clave'
--    local qry = string.format('SELECT datos.fecha, datos.clave, desc, ROUND(costol/1e4,2) costol, obs, proveedor FROM datos, proveedores, faltantes %s', clause)

    local conn = assert( sql.connect'/db/inventario.db' )

    local keys = table.concat(fd.reduce(JSON, fd.map( quot ), fd.into, {}), ', ')
    local data = table.concat(fd.reduce( conn.query( 'SELECT * FROM compras' ), fd.map( tovec ), fd.into, {} ), ', ')
    return string.format('Content-Type: text/html\r\n\r\n[[%s], [%s]]', keys, data)
end

aux( records )



