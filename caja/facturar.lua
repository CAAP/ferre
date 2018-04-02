#!/usr/local/bin/lua

local aux = require'ferre.aux'
local lpr = require'ferre.bixolon'
local tkt = require'ferre.ticket'
local ex = require'ferre.extras'
local precio = require'ferre.precio'

local fd = require'carlos.fold'

local fs = require'carlos.files'

local function tickets(q)
    local uid = q.uid
    local tag = q.tag or ''
    local y,m,d = uid:match'^(%d+)-(%d+)-(%d+)'
    local week = ex.asweek(os.time{year=y, month=m, day=d})
    local conn = assert(ex.dbconn(week), 'Error while connecting to DB ' .. week)
    local QRY = 'SELECT * FROM %s WHERE uid LIKE %q'

    assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

    local function fetch()
	local p = 'NaP'

        local total = 0
	local function suma(w)
	    total = total + w.totalCents
	    return w
	end
	local function bruto(w)
	    w.prc = string.format('%.2f/%s', tonumber(w.bruto) or 0, w.unit) 
	    w.subTotal = string.format('%.2f', w.totalCents/116)
	    return w
	end
	local function sat(w)
	    local ret = fd.first(conn.query(string.format('SELECT uidSAT FROM datos WHERE clave LIKE %q', w.clave)), function(x) return x end)
	    w.uidSAT = ret.uidSAT == 0 and 'XXXXXX' or ret.uidSAT
	    return w
	end

	-- uid REQUIRED to get DATE & TIME
	local ret = {uid=uid, person=p, tag=tag}
	ret.datos = fd.reduce( conn.query(string.format(QRY, 'tickets', uid)), fd.map(precio(conn)), fd.map(suma), fd.map(bruto), fd.map(sat), fd.into, {} ) -- ventap(tag) : DBase to connect
	ret.total = string.format('%.2f', total/116) -- BRUTO
	ret.iva = string.format("%.2f", total/725)

	return ret
    end

--    lpr( tkt( fetch() ) )
    fs.dump('ticket.txt', tkt( fetch() ) )
--]]

    return 'OK'
end

aux( tickets )
