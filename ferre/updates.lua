#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'
local mx = require'ferre.timezone'
local hd = require'ferre.header'

local week = os.date('W%U', mx())

local QRY = 'SELECT * FROM updates %s'

local function push(week, vers, ret)
    local conn = assert( sql.connect(string.format('/db/%s.db', week)) )
    local clause = string.format('WHERE vers > %d', vers)

    local function into(w)
	local clave = w.clave
	if not ret[clave] then ret[clave] = {clave=clave, store='PRICE'} end
	local z = ret[clave]
	z[w.campo] = w.valor
    end

    if conn.count('updates', clause) > 0 then
	fd.reduce(conn.query(string.format(QRY, clause)), into)
    end

    return conn.count'updates'
end

local function records(w)
    local ret = {}
    local vers = w.vers

    if w.week < week then -- XXX should NOT be valid for more than a week old | can define a new variable holding one week ago
	push( w.week, vers, ret )
	vers = 0
    end

    vers = push( week, vers, ret )

    ret.VERS = {store='VERS', week=week, vers=vers}

    ret = fd.reduce(fd.keys( ret ), fd.map( hd.asJSON ), fd.into, {})

    return string.format('Content-Type: text/plain; charset=utf-8\r\n\r\n[%s]\n', table.concat(ret, ', '))
end

aux( records )

