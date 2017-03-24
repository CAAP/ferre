#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'
local tkt = require'ferre.ticket'
local ex = require'ferre.extras'
local precio = require'ferre.precio'

local fd = require'carlos.fold'

--[[ NEED TO BE REWRITTEN XXX
local ventas = {VENTA=true, FACTURA=true, CREDITO=true}

local function ventap(s)
    return (ventas[s] and 'ventas' or 'tickets')
end
--]]

local function tickets(q)
    local uid = q.uid
    local tag = q.tag or ''
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = ex.asweek(os.time{year=y, month=m, day=d})
    local conn = assert(ex.dbconn(week), 'Error while connecting to DB ' .. week)
    local QRY = 'SELECT * FROM %s WHERE uid LIKE %q'

    assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

    local nombres = fd.reduce( conn.query'SELECT * FROM empleados', fd.rejig(function(w) return w.nombre, w.id end), fd.merge, {} )

    local function fetch()
	local p = nombres[math.tointeger(uid:match'(%d+)$')] or 'NaP'

        local total = 0
	local suma = fd.map(function(w) total = total + w.totalCents; return w end)
	-- uid REQUIRED to get DATE & TIME
	local ret = {uid=uid, person=p, tag=tag}
	ret.datos = fd.reduce( conn.query(string.format(QRY, 'tickets', uid)), fd.map(precio(conn)), suma, fd.into, {} ) -- ventap(tag) : DBase to connect
	ret.total = string.format('%.2f', total/100)

	return ret
    end

    lpr( tkt( fetch() ) )
--]]

    return 'OK'
end

aux( tickets )
