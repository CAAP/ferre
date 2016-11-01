#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'
local mx = reequire'ferre.timezone'

local week = os.date('W%U', mx())

local function quot(x)
    if 'table' == type(x) then return string.format('[%s]', table.concat(fd.reduce(x, fd.map(quot), fd.into, {}), ', ')) end
    return tonumber(x) and (math.tointeger(x) or x) or string.format('%q', x)
end 

local JSON = { 'clave', 'desc', 'fecha', 'faltante', 'obs', 'version', 'precio1', 'u1', 'precio2', 'u2', 'precio3', 'u3' }

local function tovec(a)
    local ret = fd.reduce( JSON, fd.map(function(k) return quot(a[k] or '') end), fd.into, {} )
    return string.format('[%s]', table.concat(ret, ', '))
end


local stores

local function events(k, v)
end

local QRY = 'SELECT * FROM updates %s'

local function push(conn, clause, ret)
    fd.reduce(conn.qry(string.format(QRY, clause)), fd.into, ret)
end

local function records(w)
    local ret = {}
    local clause = 'WHERE vers > %d'
    local vers = w.vers
    if w.week < week then -- XXX should NOT be valid for more than a week old | can define a new variable holding one week ago
	local conn = assert( sql.connect(string.format('/db/%s.db', w.week)) )
	if conn.count('updates', string.format(clause, vers)) > 0 then
	    push( conn, clause, ret )
	end
	vers = 0
    end

    local conn = assert( sql.connect(string.format('/db/%s.db', week)) )
    if conn.count('updates', string.format(clause, vers)) > 0 then
	push( conn, clause, ret )
    end
    return ret
end

aux( records )

