-- Make this file's filepath ../addons/homepoints/homepoints.lua
-- Load it (//lua l homepoints), use whatever homepoint you want,
-- and then I recommend unloading it if you're going to do something else.

windower.register_event('incoming chunk',function(id,original,modified,is_blocked,is_injected)
    if  id == 0x34 then
        if windower.ffxi.get_items().gil == original:byte(0x1D)+original:byte(0x1E)*256+original:byte(0x1F)*256^2+original:byte(0x20)*256^3 then
            return original:sub(1,12)..string.char(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF)..original:sub(25,32)..string.char(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF)..original:sub(41)
        end
    end
end)