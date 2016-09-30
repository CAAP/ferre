#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'
local fs = require'carlos.files'

local aux = require'ferre.aux'

local function vals(s)
     local c,p = s:match('clave|([^|]+)|proveedor|([^|]+)')
     return c and {string.format('%q', c), string.format('%q', (p or ''))} or false
end

local function records( q )
    local stmt = 'CREATE TABLE IF NOT EXISTS proveedores (clave, proveedor)'
    local conn = sql.connect'/db/inventario.db'

    assert( conn.exec(stmt), string.format('Error executing: %s', stmt) )

    assert( #q.args > 0, 'No data received!' )

    fd.reduce( q.args, fd.map(function(s) return vals(s) end), fd.filter(function(x) return x end), sql.into'proveedores', conn)

    return 'OK'
end

aux( records )



