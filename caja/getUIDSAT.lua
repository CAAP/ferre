#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function uids()
    local tbname = 'datos'
    local clause = "WHERE desc NOT LIKE 'VV%'"
    local w = {	tbname= tbname,
		dbname= '/db/ferre.db',
		clause= clause,
		QRY= string.format('SELECT clave, uidSAT FROM %q %s', tbname, clause) }
    return json( w )
end

aux( uids )

