#!/bin/ferre/lua

local function sendSSE(id, data)
    print "Access-Control-Allow-Origin: *"
    print "Content-Type: text/event-stream"
    print "Cache-Control: no-cache\r\n\r"
    print("id: ", id)
    print('data: ', data, '\n')
end

local getenv = os.getenv

local lastID = getenv'HTTP_LAST_EVENT_ID' or 0

lastID = lastID + 1

sendSSE(lastID, 'my id is: ' .. lastID)


