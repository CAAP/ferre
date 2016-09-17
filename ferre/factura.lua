#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local conn = sql.connect'/db/ferre.db'

local datos = conn.header'clientes'
assert(datos, 'Table "clientes" not found in "/db/ferre.sql"')

local function quot(x) return string.format('%q', x) end

local head = table.concat(fd.reduce( datos, fd.map( quot ), fd.into, {} ), ',')

print(string.format('Content-Type: text/html\r\n\r\n[%s]\n', head))

