#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local aux = require'ferre.aux'
local mx = require'ferre.timezone'

local week = os.date('Y%YW%U', mx())

local conn = assert( sql.connect(string.format('/db/%s.db', week)) )

local vers = conn.exists'updates' and conn.count'updates'

print(string.format('Content-Type: text/json\r\n\r\n{"week":%q, "vers":%d}\n', week, vers))

