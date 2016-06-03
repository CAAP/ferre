local fd = require'carlos.fold'
local url = require'socket.url'
local socket = require'socket'

local hostn = 'www.sepomex.gob.mx'
local host = '177.234.32.60'
local file = '/lservicios/servicios/descarga.aspx'

local ppties = {
	'__EVENTTARGET',
	'__EVENTARGUMENT',
	'__LASTFOCUS',
	'__VIEWSTATE', -- 4
	'__EVENTVALIDATION', -- 5
	'DdlEstado',
	'DdlMuni',
	'txtAsentami',
	'txtcp', -- 9
	'btnFind.x',
	'btnFind.y'
}

local vals = { '', '', '', '', '', '00', '000', '', '', '0', '0' }

local function encode()
    return table.concat( fd.reduce(ppties, fd.map(function(x, i) return (x .. '=' .. vals[i]) end), fd.into, {}), '&' )
end

local function request(args)
    local c = assert( socket.connect(host, 80) ) -- establish an http connection
    c:settimeout(0) -- do not block
    c:send("GET " .. file .. " HTTP/1.1\r\nHost: " .. hostn .. "\r\nConnection: keep-alive\r\nAccept: text/html\r\n\r\n" .. args)
    local s, msg = c:receive() -- status line
    if msg or not(s:match'200') then c:close(); return nil end
    local ret = {}
    while true do
	local s, status, partial = c:receive()
	ret[#ret+1] = s or partial
	if not(s or partial) then break end
    end
    c:close()
    return table.concat(ret, '') -- '\n'
end

local function zipcode( cp )
    local ret = assert( request'', 'Error connecting to ' .. host )

    local function getvalue( p ) return ret:match('id="' .. p ..'"[%s\n\r\f]+value="(%g+)"') end

    local function values( s )
	local a = {}
	for x in s:gmatch'<td>([^<]+)' do a[#a+1] = x end
	return a
    end

    -- cp, asentamiento, tipo_asentamiento, municipio, estado, ciudad
    local function order( a ) return { a[1], a[2], a[4], a[5] } end

    vals[4] = url.escape( getvalue'__VIEWSTATE' )
    vals[5] = url.escape( getvalue'__EVENTVALIDATION' )
    vals[9] = cp

    ret = http.request(sepomex .. '?' .. encode()):match('(<tr class="dgNormal".*)<tr class="dgotro"'):gsub('<a href%g*</a>', ''):gsub('[\t\r\n]*', ''):gsub('([%s\t\r\n]*)(</td>)','%2')

    return fd.reduce(st.split(ret, '</tr>'), fd.map(values), fd.map(order), fd.into, {})
end

return request, zipcode

