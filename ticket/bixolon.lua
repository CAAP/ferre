#!/usr/local/bin/lua

local socket = require'socket'
local fd = require'carlos.fold'

local width = 38
local forth = {7, 7, 4, 10, 10}

local function centrado(s)
    local m = s:len()
    local n = math.floor((width-m)/2 + 0.5) + m
    return string.format('%'..n..'s', s)
end

local function campos(w)
    return table.concat(fd.reduce(w, fd.map(function(x,j) return string.format('%'..forth[j]..'s', x) end), fd.into, {}), '')
end

local head = {centrado('FERRETERIA AGUILAR'),
	centrado('FERRETERIA Y REFACCIONES EN GENERAL'),
	centrado('Benito Juárez 1-C, Ocotlán, Oaxaca'),
	centrado('Tel. (951) 57-10076'),
	centrado(os.date'%FT%TP'),
	'',
	campos({'CLAVE', 'CNT', '%', 'PRECIO', 'TOTAL'}),
	''}

local function procesar(w)
    head[#head+1] = w.desc
    head[#head+1] = campos(w.clave, w.qty, w[w.precio], w.rea, w[w.unidad], w.subtotal)
end

--{centrado('GRACIAS POR SU COMPRA')}

print( table.concat(head, '\n') )

