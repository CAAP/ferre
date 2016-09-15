#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function record( q )
    local tbname = 'datos'
    local clause = string.format("WHERE desc LIKE %q ORDER BY desc", q.desc:gsub('*','%%')..'%%')
    local w = {	tbname= tbname,
		dbname= '/db/ferre.db',
		clause= clause,
		QRY= string.format('SELECT desc FROM %q %s LIMIT 1', tbname, clause) }
    return json( w )
end

aux( record )



