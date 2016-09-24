#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function record( q )
    local tbname = 'datos'
    local clause = q.clave and string.format("WHERE clave LIKE %q", q.clave) or string.format("WHERE desc LIKE '%s%%'", q.desc)
    local w = {	tbname= tbname,
		dbname= '/db/ferre.db',
		clause= clause,
		QRY= string.format('SELECT * FROM %q %s LIMIT 1', tbname, clause) }
    return json( w )
end

aux( record )

