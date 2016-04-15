#!/bin/ferre/lua

local fd = require'carlos.fold'
local sql = require'ferre.sql'
local aux = require'ferre.aux'
local tbname = os.date'W%U' -- WEEK of the YEAR
local schema = "uid PRIMARY KEY, count INTEGER, id_tag"
local header = {'uid', 'count', 'id_tag'}

local function imprimir(w)
    w.method = 'into'
    w.dbname = '/db/caja.sql'
    w.tbname = tbname
    w.uid = os.date'%FT%TP' .. w.id_person
    w.args = tbname
    w.schema = schema
    w.x = fd.reduce( header, fd.map( function(k) return w[k] or '' end ), fd.into, {} )
    sql(w)
    return string.format('Content-Type: text/plain\r\n\r\n{"uid": %q }\n', w.uid)
end

aux( imprimir )

