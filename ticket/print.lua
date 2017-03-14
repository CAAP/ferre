#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'
local tkt = require'ferre.ticket'
local ex = require'ferre.extras'

local fd = require'carlos.fold'
local sql = require'carlos.sqlite'

local ventas = {VENTA=true, FACTURA=true, CREDITO=true}

local function ventap(s)
    return (ventas[s] and 'ventas' or 'tickets')
end

local function int(d) return math.tointeger(d) or d end

local function tickets(q)
    local uid = q.uid
    local tag = q.tag or ''
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = ex.asweek(os.time{year=y, month=m, day=d})
    local conn = assert(ex.dbconn(week), 'Error while connecting to DB ' .. week)
    local QRY = 'SELECT * FROM %s WHERE uid LIKE %q'
    local PRC = 'SELECT desc, precio%d ||"/"|| IFNULL(u%d,"?") prc FROM precios WHERE clave LIKE %q'

    assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

    local nombres = fd.reduce( conn.query'SELECT * FROM empleados', fd.rejig(function(w) return w.nombre, w.id end), fd.merge, {} )

    local function precio(w)
	local j = w.precio:sub(-1)
	w.clave = int(w.clave)
	w.qty = int(w.qty)
	w.rea = int(w.rea)
	if not w.desc then
	    local ret = fd.first( conn.query(string.format(PRC, j, j, w.clave)), function(x) return x end )
	    w.desc = ret.desc
	    w.prc = ret.prc
	end
	w.subTotal = string.format('%.2f', w.totalCents/100)
	return w
    end

    local function fetch()
	local fecha = uid:match'([^P]+)P'
	local p = nombres[int(uid:match'(%d+)$')] or 'NaP'

        local total = 0
	local suma = fd.map(function(w) total = total + w.totalCents; return w end)

	local ret = {fecha=fecha, person=p, tag=tag}
	ret.datos = fd.reduce( conn.query(string.format(QRY, ventap(tag), uid)), suma, fd.map(precio), fd.into, {} )
	ret.total = string.format('%.2f', total/100)

	return ret
    end

    lpr( tkt( fetch() ) )

    return 'OK'
end

aux( tickets )
