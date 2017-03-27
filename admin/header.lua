#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local conn = sql.connect'/db/ferre.db'

local datos = conn.header'datos'
assert(datos, 'Table "datos" not found in "/db/ferre.sql"')
datos[#datos] = nil -- remove rebaja
datos[#datos] = nil -- remove costol
datos[#datos] = nil -- remove fecha
table.insert(datos, 6,'rebaja')

local function quot(x) return string.format('%q', x) end

local head = table.concat(fd.reduce( datos, fd.map( quot ), fd.into, {} ), ',')

print(string.format('Content-Type: text/html\r\n\r\n[%s]\n', head))

