#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function tickets( q )
    local uid = q.uid
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = os.date( 'W%U', os.time{year=y, month=m, day=d} )
    local tbname = 'tickets'
    local clause = string.format("WHERE uid LIKE %q", uid)
    local w = {	tbname= tbname,
		dbname= string.format('/db/%s.db', week),
		clause= clause,
		QRY= string.format('SELECT * FROM %q %s', tbname, clause) }
    return json( w )
end

aux( tickets )

