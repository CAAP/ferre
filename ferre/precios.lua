#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'

local function quot(x)
    if 'table' == type(x) then return string.format('[%s]', table.concat(fd.reduce(x, fd.map(quot), fd.into, {}), ', ')) end
    return tonumber(x) and (math.tointeger(x) or x) or string.format('%q', x)
end 

local JSON = { 'clave', 'desc', 'fecha', 'faltante', 'obs', 'version', 'precio1', 'u1', 'precio2', 'u2', 'precio3', 'u3' }

local function tovec(a)
    local ret = fd.reduce( JSON, fd.map(function(k) return quot(a[k] or '') end), fd.into, {} )
    return string.format('[%s]', table.concat(ret, ', '))
end

local function groups(a)
    return function(w)
	if not a[w.clave] then a[w.clave] = {} end
	local ret = a[w.clave]
	ret[#ret+1] = w.obs
    end
end

local function int(x) return math.tointeger(x) or x end

local function records()
    local conn = assert( sql.connect'/db/ferre.db' )
    local clause = 'WHERE precios.clave == faltantes.clave AND desc NOT LIKE "VV%"'
    local qry = string.format('SELECT * FROM faltantes, precios %s', clause)

    assert( conn.exec"ATTACH DATABASE '/db/inventario.db' AS NV" )

    local keys = table.concat(fd.reduce(JSON, fd.map( quot ), fd.into, {}), ', ')
    local data = table.concat(fd.reduce( conn.query( qry ), fd.map( tovec ), fd.into, {} ), ', ')
    return string.format('Content-Type: text/html\r\n\r\n[[%s], [%s]]', keys, data)
end

aux( records )

