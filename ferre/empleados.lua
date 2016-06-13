#!/usr/local/bin/lua

local json = require'ferre.json'

print( json{dbname='/db/ferre.sql', tbname='empleados', clause='', QRY='SELECT * FROM empleados'} )

