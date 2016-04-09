#!/bin/ferre/lua

local aux = require'ferre.aux'

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local dbname = '/db/tickets.sql'
local tbname = os.date'W%U' -- WEEK of the YEAR
local schema = 'uid, clave, precio, qty INTEGER, rea INTEGER, totalCents INTEGER'
local header = {'uid', 'clave', 'precio', 'qty', 'rea', 'totalCents'}
local keys = fd.reduce( header, fd.rejig( function(x,i) return i,x end ), fd.merge, {} )

local function caja(w)
    w.uid = os.date'%FT%TP' .. w.id_person
    local vals = string.format('%q, %d, %s', w.uid, w.count, w.id_tag)
    local qry = string.format('INSERT INTO %q VALUES(%s)', tbname, vals)
    local conn = sql.connect'/db/caja.sql'
    local schema = "uid PRIMARY KEY, count INTEGER, id_tag"
    conn.exec( string.format(sql.newTable, tbname, schema) )
    return conn.exec( qry )
end

local function collect(q)
    local t = {}
    for k,v in q:gmatch'([^%s]+)%s([^%s]+)' do if keys[k] then t[keys[k]] = v end end
    return t
end

local function add(w)
    caja(w)
    if not w.args then return 'Content-Type: text/plain\r\n\r\nERROR: Empty Query\n' end
    local z = (type(w.args) == 'table') and w.args or { w.args }
    local conn = sql.connect(dbname)
    conn.exec( string.format( sql.newTable, tbname, schema ) )
    fd.reduce( z, fd.map(collect), sql.into(tbname), conn )
    return 'Content-Type: text/plain\r\n\r\nOK\n'
end

aux(add)

