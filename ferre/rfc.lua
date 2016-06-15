#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function record( q )
    local tbname = 'clientes'
    local clause = string.format("WHERE rfc LIKE %q", q.rfc)
    local w = {	tbname= tbname,
		dbname= '/db/ferre.sql',
		clause= clause,
		QRY= string.format('SELECT * FROM %q %s', tbname, clause) }
    return json( w )
end

aux( record )

