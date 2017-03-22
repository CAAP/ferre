#!/usr/local/bin/lua

local json = require'ferre.json'

print( json{dbname='/db/ferre.db', tbname='tags', clause='', QRY='SELECT * FROM tags'} )

