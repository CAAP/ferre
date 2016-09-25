#!/usr/local/bin/lua

local aux = require'ferre.aux'
local letra = require'ferre.enpesos'

local function pesos2letra( q )
    return letra(q.pesos)
end

aux( pesos2letra )
