local fd = require'carlos.fold'
local url = require'socket.url'
local socket = require'socket'

local hostn = 'www.correosdemexico.gob.mx'
local host = '177.234.32.60'
local port = 80
local uri = '/lservicios/servicios/descarga.aspx'

local pties = {
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

local vals = { '', '', '', '', '', '00', '000', '', '', '23', '1' }

local function encode()
    return table.concat( fd.reduce(pties, fd.map(function(x, i) return (x .. '=' .. vals[i]) end), fd.into, {}), '&' )
end

local query = '$method $uri HTTP/1.1\r\nHost: $host\r\nAccept: text/html\r\n$extra\r\n$args'

local function request(ops)
    local u = query:gsub('%$(%w+)', {method=ops.method, uri=ops.uri, host=ops.host, args=(ops.args or ''), extra=(ops.extra or '')})
    local c = assert( socket.connect(host, port) )
    c:settimeout(0) -- do not block

print(u, '\n')

    c:send( u )
    socket.sleep(1)
    local s, msg = c:receive() -- status line
    if msg or not(s:match'200') then c:close(); return nil, msg or s end
    local ret = { s }
    repeat
	local s, status, partial = c:receive()
	ret[#ret+1] = s or partial
    until not(s)
    c:close()
    return ret -- table.concat(ret, '') -- '\n'
end

local function zipcode( cp )
--    local ret = assert( request'GET', 'Error connecting to ' .. host )
    local ret = assert( request{method='GET', uri=uri, host=hostn, extra='', args=''} )

---[[
    local function getvalue( j ) return ret[j]:match('value="(%g+)"') end

    local function values( s )
	local a = {}
	for x in s:gmatch'<td>([^<]+)' do a[#a+1] = x end
	return a
    end

    -- cp, asentamiento, tipo_asentamiento, municipio, estado, ciudad
    local function order( a ) return { a[1], a[2], a[4], a[5] } end

-- 'id="' .. p ..'"
    vals[4] = url.escape( getvalue(28) )
    vals[5] = url.escape( getvalue(30) )
    vals[9] = cp
    local cookie = ret[7]:match('Cookie: ([^%s]+)')
    cookie = cookie .. ' ' ..ret[11]:match('Cookie: ([^%s]+);')
,11

    local q = 'Content-type: aplication/x-www-form-urlencoded\r\nContent-length: %d\r\nCookie: %s\r\nUser-Agent: Mozilla/5.0 Chrome/51.0.2704.103'

    local data = encode()

--    ret = assert( request{method='POST', uri=uri, host=hostn, extra=string.format(q, #data, cookie), args=data} )

    socket.sleep(3)

    ret = assert( request{method='GET', uri=uri..'?'..data, host=hostn, extra=string.format(q, #data, cookie), args=''} )

    return ret
--    ret = http.request(sepomex .. '?' .. encode()):match('(<tr class="dgNormal".*)<tr class="dgotro"'):gsub('<a href%g*</a>', ''):gsub('[\t\r\n]*', ''):gsub('([%s\t\r\n]*)(</td>)','%2')

--    return fd.reduce(st.split(ret, '</tr>'), fd.map(values), fd.map(order), fd.into, {})
--]]
end

return zipcode

