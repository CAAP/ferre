#!/usr/local/bin/lua

local aux = require'ferre.aux'
local mx = require'ferre.timezone'
local hdr = require'ferre.header'

local socket = require'socket'

local fd = require'carlos.fold'
local sql = require'carlos.sqlite'

local function encode(s)
    return string.gsub(s, '[^%w_]', function(c) return string.format('%%%02x', string.byte(c)) end)
end

local function asstr( w )
    return table.concat(fd.reduce( fd.keys(w), fd.map(function(x,k) return encode(k)..'='..(math.tointeger(x) or encode(x)) end), fd.into, {} ), '&')
end

local function sendmsg( conn, query )
    local c = assert(socket.tcp(), 'Error creating tcp socket.')
    assert( c:settimeout(60) )
    assert( c:connect('127.0.0.1', 8081) )

    local ret =  fd.first( conn.query( query ), function(x) return x end )
    ret.id_tag = 'u'

    local request = 'GET /update?%s HTTP/1.1\r\nOrigin: %s\r\n\r\n'
    local ip = c:getpeername():match'%g+'
    c:send( string.format(request, asstr(ret), ip) )
    c:close()
end

local function record( q )
    local dbname = '/db/ferre.db'
    local tbname = 'datos'
    local vwname = 'precios'
--    local upname = 'cambios' XXX
    local clave = q.clave
    local clause = string.format("WHERE clave LIKE %q", clave)

-- could add:    pos => pos < 0 ? 0 : pos

    q.args = nil; q.clave = nil; q.fecha = os.date('%d-%b-%y', mx())
    local ret = {}
    for k,v in pairs(q) do
	local vv = (k == 'desc' or k == 'fecha' or k:match'^u') and string.format('%q',v) or (math.tointeger(v) or tonumber(v) or 0)
	ret[#ret+1] = k..' = '..vv
    end

    local QRY = string.format('UPDATE %q SET %s %s', tbname, table.concat(ret, ', '), clause)

    local conn = assert( sql.connect( dbname ), 'Error connecting to '..dbname )

    assert( conn.exec(QRY), 'Error executing '..QRY )

    if q.costo or q.impuesto or q.descuento then
	QRY = string.format('UPDATE %q SET costol = costo*(100+impuesto)*(100-descuento) %s', tbname, clause)
	assert( conn.exec(QRY), 'Error executing '..QRY )
    end

    sendmsg( conn, string.format('SELECT * FROM %q %s', vwname, clause) )

    return 'Content-Type: text/plain\r\n\r\n'..clave
end

aux( record )

