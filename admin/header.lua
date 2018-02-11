#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local conn = sql.connect'/db/ferre.db'

local del = {rebaja=true, costol=true, fecha=true}
local datos = conn.header'datos'
assert(datos, 'Table "datos" not found in "/db/ferre.sql"')
datos = fd.reduce(datos, fd.filter(function(x) return not(del[x]) end), fd.into, {})
table.insert(datos, 6,'rebaja')

local function quot(x) return string.format('%q', x) end

local head = table.concat(fd.reduce( datos, fd.map( quot ), fd.into, {} ), ',')

print(string.format('Content-Type: text/html\r\n\r\n[%s]\n', head))

