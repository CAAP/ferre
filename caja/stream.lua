#!/bin/ferre/lua

-- NO QUERY STRING
local json = require'ferre.stream'

local uid = os.getenv'HTTP_LAST_EVENT_ID'

local function getAll(w)
    local tbname = os.date'W%U'
    local clause = uid and or "WHERE id_tag NOT LIKE '%Z'"
    local clause = "WHERE (strftime('%s',substr(uid,1,19)) - strftime('%s','" .. (os.date('%FT%T',uid) or os.date'%F') .. "')) > 0 AND id_tag NOT LIKE '%Z'" -- ORDER BY uid DESC
    local w = { tbname= tbname,
		clause= clause,
		dbname= '/db/caja.sql',
		QRY= string.format('SELECT * FROM %q %s', tbname, clause) }
    return json( w )
end

getAll( w )
