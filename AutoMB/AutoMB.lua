require 'tables'
require 'sets'
config = require 'config'
file = require 'files'
res = require 'resources'

_addon.version = '2.00'
_addon.name = 'AutoMB'
_addon.author = 'Havion'
_addon.commands = {'amb','automb'}

defaults = T{}
defaults.Light = T{mb1="Thunder IV", mb2="Thunder III"}
defaults.Darkness = T{mb1="Water IV", mb2="Water III"}
defaults.Gravitation = T{mb1="Stone IV", mb2="Stone IV"}
defaults.Fragmentation = T{mb1="Thunder IV", mb2="Thunder III"}
defaults.Distortion = T{mb1="Water IV",  mb2="Water III"}
defaults.Fusion = T{mb1="Fire IV",  mb2="Fire III"}
defaults.Compression = T{mb1="NoctoHelix II"}
defaults.Liquefaction = T{mb1="Fire IV",  mb2="Fire III"}
defaults.Induration = T{mb1="Blizzard IV", mb2="Blizzard III"}
defaults.Reverberation = T{mb1="Water IV",  mb2="Water III"}
defaults.Transfixion = T{mb1="Thunder IV", mb2="Thunder III"}
defaults.Scission = T{mb1="Stone IV", mb2="Stone III"}
defaults.Detonation = T{mb1="Aero IV", mb2="Aero III"}
defaults.Impaction = T{mb1="Thunder IV", mb2="Thunder III"}

settings = T{}

language = 'english'
debugging = false
auto = 'on'

-- Statuses that stop you from casting.
statusblock = T{'Dead','Event','Charmed'}

-- Nuking jobs
nuking_main_jobs = T{'BLM','RDM','SCH','GEO','DRK'}
nuking_sub_jobs = T{'BLM'}

-- Aliases for tellback mode.
on = T{'on', 'yes', 'true'}
off = T{'off', 'no', 'false'}

-- Skillchains that result in damage to the target
skillchains = T{[288]="Light",[289]="Darkness",[290]="Gravitation",[291]="Fragmentation",[292]="Distortion",[293]="Fusion",[294]="Compression",[295]="Liquefaction",[296]="Induration",[297]="Reverberation",[298]="Transfixion",[299]="Scission",[300]="Detonation",[301]="Impaction",[302]="Cosmic Elucidation"}

windower.register_event('load',function()
	if debugging then windower.debug('load') end
	initialize()
end)

windower.register_event('login',function (name)
	if debugging then windower.debug('login') end
end)

function initialize()
	settings = config.load(defaults)
	config.save(settings, 'global')
end

windower.register_event('action',function (act)
	local player = windower.ffxi.get_player()
	
	if statusblock:contains(player['status_id']) or (auto == 'off') then return end
	if not nuking_main_jobs:contains(player.main_job) and not nuking_sub_jobs:contains(player.sub_job) then return end
	
	magicBurst(act)
end)

windower.register_event('addon command',function (command, ...)
	if debugging then windower.debug('addon command') end
	local args = T{...}
	
    -- Turns status on or off
	if command == 'auto' then
		local status = args[1]
		status = status:lower()
		if on:contains(status) then
			auto = 'on'
			windower.add_to_chat(4,'AutoMB turned on.')
		elseif off:contains(status) then
			auto = 'off'
			windower.add_to_chat(4,'AutoMB turned off.')
		else
			error('Invalid status:', args[1])
			return
		end
	end
end)

function magicBurst(act)
	-- category 3 is Finish weaponskill, category 4 is Finish spell casting, category 11 is Finish TP move (npcs)
	if T{3,4,11,13}:contains(act.category) and act.target_count > 0 then
		local actor = windower.ffxi.get_mob_by_id(act.actor_id)
		if not checkInParty(actor) then return end
		
		if act.targets[1].actions ~= nil then
			local action = act.targets[1].actions[1]
			if action.has_add_effect then
				local msgId = action.add_effect_message
				--windower.add_to_chat(4, 'Category: '..act.category..' | Msg ID: '..msgId)
				if skillchains[msgId] then
					local skillchain = skillchains[msgId]
					local spellcount = 0
					for _ in pairs(settings[skillchain]) do
						spellcount = spellcount + 1
					end
					for i=1,spellcount,1 do
						if settings[skillchain]['mb'..i] then
							local spell = res.spells:with('en', settings[skillchain]['mb'..i])
							
							castSpell(spell.name, act.targets[1].id)
							if settings[skillchain]['mb'..(i + 1)] then
								coroutine.sleep(spell.cast_time + 1.5)
							end
						else
							break
						end
					end
				end
			end
		end
	end
end

function castSpell(spell_name, target_id)
	windower.send_command('input /ma "'..spell_name..'" '..target_id)
end

function checkInParty(target)
	if target.in_party or target.in_alliance then
		return true
	else
		if target.is_npc then
			return checkPetInParty(target)
		end
	end
end

function checkPetInParty(target)
	local petIndex = target.index
	local party = windower.ffxi.get_party()
	for i=0,5 do
		if party['p'..i] then
			if party['p'..i].mob then
				if party['p'..i].mob.pet_index == petIndex then
					return true
				end
			end
		end
	end
	for i=10,15 do
		if party['a'..i] then
			if party['a'..i].mob then
				if party['a'..i].mob.pet_index == petIndex then
					return true
				end
			end
		end
	end
	for i=20,25 do
		if party['a'..i] then
			if party['a'..i].mob then
				if party['a'..i].mob.pet_index == petIndex then
					return true
				end
			end
		end
	end
	
	return false
end