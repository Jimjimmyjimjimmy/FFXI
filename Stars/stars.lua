windower.register_event('incoming text',function(org,mod,omode,mmode,block)
    if (org:match(string.char(0x81,0x99)) or org:match(string.char(0x81,0x9A))) then 
        return true 
    elseif (windower.convert_auto_trans(org):lower():match("job points") or org:lower():match('job point') or org:lower():match('jp')) and org:match(2100) then
        return true
    end
end)