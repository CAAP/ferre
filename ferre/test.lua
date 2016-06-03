#!/bin/ferre/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local zips = dofile'/cgi-bin/ferre/ferre/correo.lua'

local tbname = 'zipcodes'

local conn = sql.connect'/db/ferre.sql'
local qry = conn.query'SELECT cp FROM clientes GROUP BY cp'
local valid = fd.filter( function(x) local a = math.tointeger(x.cp); return (a and a > 0) end )

local function notexists(x) 
    local clause = string.format('WHERE cp = %q', x.cp)
    return not(conn.count(tbname, clause) > 0)
end

-- make sure the db and tb exist
conn.exec( string.format(sql.newTable, tbname, 'cp, colonia, ciudad, estado') )

fd.reduce( qry, valid, fd.filter(notexists), fd.map(function(x) return x.cp end), zips, sql.into(tbname), conn )

