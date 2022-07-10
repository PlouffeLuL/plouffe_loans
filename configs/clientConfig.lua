Bank = {}
BankFnc = {} 
TriggerServerEvent("plouffe_banking:sendConfig")

RegisterNetEvent("plouffe_banking:getConfig",function(list)
	if list == nil then
		CreateThread(function()
			while true do
				Wait(0)
				Bank = nil
				BankFnc = nil
			end
		end)
	else
		Bank = list
		BankFnc:Start()
	end
end)