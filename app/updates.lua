#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'
local hd = require'ferre.header'
local ex = require'ferre.extras'

local week = ex.week()

local ups = {store='VERS', week='', vers=0}

local QRY = 'SELECT * FROM updates %s'

local function push(ret)
    local conn = assert( ex.dbconn( ups.week ), 'Failed connecting to DB: '..ups.week ) -- sql.connect(string.format('/db/%s.db', ups.week))
    local clause = string.format('WHERE vers > %d', ups.vers)

    local function into(w)
	local clave = w.clave
	if not ret[clave] then ret[clave] = {clave=clave, store='PRICE'} end
	local z = ret[clave]
	z[w.campo] = w.valor or ''
    end

    if conn.count('updates', clause) > 0 then
	fd.reduce(conn.query(string.format(QRY, clause)), into)
	ups.vers = conn.count'updates'
    end
end

local function week2time( week )
    local time = ex.now()
    local wk = ex.asweek( time )
    while wk ~= week do
	time = time - 3600*24*7
	wk = ex.asweek( time )
    end
    return time
end

local function records(w)
    local ret = {ups}
    local time = week2time(w.oweek) -- ex.now() -- mx()

    ups.week = w.oweek; ups.vers = w.overs -- Initial values

    push( ret )

    while ups.week ~= w.nweek do
	time = time + 3600*24*7
	ups.week = ex.asweek( time ) --os.date('Y%YW%U', time)
	ups.vers = 0
	push( ret )
    end

    ret = fd.reduce(fd.keys( ret ), fd.map( hd.asJSON ), fd.into, {})

    return string.format('Content-Type: text/plain; charset=utf-8\r\n\r\n[%s]\n', table.concat(ret, ', '))
end

aux( records )

