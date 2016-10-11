#!/usr/local/bin/lua

local sql = require'carlos.sqlite'

local aux = require'ferre.aux'

local function records( q )
    local conn = sql.connect'/db/inventario.db'

    assert(conn.exec(string.format('UPDATE proveedores SET proveedor = %q WHERE clave LIKE %q', q.proveedor, q.clave)))

    return 'OK'
end

aux( records )



