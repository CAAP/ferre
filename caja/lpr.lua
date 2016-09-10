#!/usr/local/bin/lua53

local width = 38
local forth = {7, 7, 4, 10, 10}

local function centrado(s)
    local m = s:len()
    local n = math.floor((width-m)/2 + 0.5) + m
    return string.format('%'..n..'s', s)
end

local function campos(w)
    local ret = {}
    for j,x in ipairs(w) do ret[#ret+1] = string.format('%'..forth[j]..'s',x) end
    return table.concat(ret, '')
end

local head = {'',
	centrado('FERRETERIA AGUILAR'),
	centrado('FERRETERIA Y REFACCIONES EN GENERAL'),
	centrado('Benito Juárez 1-C, Ocotlán, Oaxaca'),
	centrado('Tel. (951) 57-10076'),
	centrado(os.date'%FT%TP'),
	'',
	campos({'CLAVE', 'CNT', '%', 'PRECIO', 'TOTAL'}),
	''}

local function procesar(s)
    head[#head+1] = w.desc
    head[#head+1] = campos(w.clave, w.qty, w[w.precio], w.rea, w[w.unidad], w.subtotal)
end

local function get(s)
    for ss in s:gmatch'[^&]+' do end
    head[#head+1] = centrado'GRACIAS POR SU COMPRA'
end

local cmd, data = io.read():match'/(%g+)%?(%g+)'

head[1] = centrado(cmd:upper())

get(data)

print( table.concat(head, '\n') )

print(uid)
