#!/usr/local/bin/lua

local aux = require'ferre.aux'
local json = require'ferre.json'

local function tickets( q )
    local uid = q.uid
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = os.date( 'Y%YW%U', os.time{year=y, month=m, day=d} )
    local tbname = 'tickets'
    local stmt = 'uid, SUM(qty) count, SUM(totalCents) totalCents, id_tag'
    local clause = string.format("WHERE uid LIKE '%s%%'", uid)
    local w = {	tbname= tbname,
		dbname= string.format('/db/%s.db', week),
		clause= clause,
		QRY= string.format('SELECT %s FROM %q %s GROUP BY uid', stmt, tbname, clause) }
    return json( w )
end

aux( tickets )

