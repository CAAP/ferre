    local function collect( q )
	local t = { '', '' } -- uid & id_tag
	for k,v in q:gmatch'([^|]+)|([^|]+)' do if keys[k] then t[keys[k]] = v end end
	return t
    end

    local function ids( uid, tag ) return fd.map( function(t) t[1] = uid; t[2] = tag; return t end ) end

    local function subTotal( w )
	w.subTotal = string.format( '%.2f', w.totalCents / 100 )
	return w
    end

    local function asTable( s )
	local t = {}
	for k,v in s:gmatch'([^|]+)|([^|]+)' do t[k] = v end
	return t
    end

    local tkt = require'ferre.ticket'
    local lpr = require'ferre.bixolon'
    local function forPrinting( w )
	w.total = string.format( '%.2f', w.totalCents / 100 )
	w.fecha = w.uid:match'([^P]+)P'
	w.datos = fd.reduce( w.args, fd.map( asTable ), fd.map( MM.tickets.addDescPrc ), fd.map( subTotal ), fd.into, {} )
        lpr( tkt( w ) )
	w.datos = nil
    end


