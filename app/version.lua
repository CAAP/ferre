#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'
local ex = require'ferre.extras'

local ups = ex.version{}

print(string.format('Content-Type: text/json\r\n\r\n{"week":%q, "vers":%d}\n', ups.week, ups.vers))

