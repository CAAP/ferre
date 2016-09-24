#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function tickets( )
    local tbname = 'datos'
    local clause = 'WHERE clave IN (SELECT clave FROM faltantes WHERE faltante = 1)'
    local w = {	tbname= tbname,
		dbname= '/db/ferre.db',
		clause= clause,
		QRY= string.format('SELECT clave, ROUND(costol/1e2, 2) costol FROM %q %s', tbname, clause) }
    return json( w )
end

aux( tickets )

