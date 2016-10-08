#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'
local tkt = require'ferre.ticket'

local fd = require'carlos.fold'
local sql = require'carlos.sqlite'

local function int(d) return math.tointeger(d) or d end

local function tickets(q)
    local uid = q.uid
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = os.date( 'W%W', os.time{year=y, month=m, day=d} )
    local conn = assert(sql.connect(string.format('/db/%s.db', week)), 'Error while connecting to DB ' .. week)
    local QRY = 'SELECT * FROM tickets WHERE uid LIKE %q'
    local PRC = 'SELECT desc, precio%d ||"/"|| IFNULL(u%d,"?") prc FROM precios WHERE clave LIKE %q'

    assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

    local nombres = fd.reduce( conn.query'SELECT * FROM empleados', fd.rejig(function(w) return w.nombre, w.id end), fd.merge, {} )

    local function precio(w)
	local j = w.precio:sub(-1)
	w.clave = int(w.clave)
	w.qty = int(w.qty)
	w.rea = int(w.rea)
	local ret = fd.first( conn.query(string.format(PRC, j, j, w.clave)), function(x) return x end )
	w.desc = ret.desc
	w.prc = ret.prc
	w.subTotal = string.format('%.2f', w.totalCents/100)
	return w
    end

    local function fetch()
	local fecha = uid:match'([^P]+)P'
	local p = nombres[int(uid:match'(%d+)$')] or 'NaP'

	local ret = {fecha=fecha, person=p, tag=(q.tag or '')}

        local total = 0
	local suma = fd.map(function(w) total = total + w.totalCents; return w end)

	ret.datos = fd.reduce( conn.query(string.format(QRY, uid)), suma, fd.map(precio), fd.into, {} )
	ret.total = string.format('%.2f', total/100)

	return ret
    end

    lpr( tkt( fetch() ) )

    return 'OK'
end

aux( tickets )
