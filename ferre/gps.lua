#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'
local fs = require'carlos.files'

local aux = require'ferre.aux'

local function records( q )
    local conn = sql.connect'/db/inventario.db'

    assert( q.clave and q.gps )

    assert(conn.exec(string.format('UPDATE inventario SET gps = %q WHERE clave LIKE %q', w.gps, w.clave)))

    return 'OK'
end

aux( records )



