#!/bin/ferre/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function getAll(w)
    local tbname = os.date'W%U'
    local clause = "WHERE id_tag NOT LIKE '%Z' ORDER BY uid DESC"
    local w = { tbname= tbname,
		clause= clause,
		dbname= '/db/caja.sql',
		QRY= string.format('SELECT * FROM %q %s', tbname, clause) }
    return json( w )
end

aux( getAll )

