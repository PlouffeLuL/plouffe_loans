RegisterNetEvent("plouffe_banking:sendConfig",function()
    local playerId = source
    local registred, key = Auth:Register(playerId)

    if registred then
        local cbArray = Bank
        cbArray.Utils.MyAuthKey = key
        TriggerClientEvent("plouffe_banking:getConfig",playerId,cbArray)
    else
        TriggerClientEvent("plouffe_banking:getConfig",playerId,nil)
    end
end)

RegisterNetEvent("plouffe_banking:askforloan",function(loanId,authkey)
    local playerId = source
    if Auth:Validate(playerId,authkey) then
        if Auth:Events(playerId,"plouffe_banking:askforloan") then
            BankFnc:GenerateLoadForPlayerFromLoanId(playerId,loanId)
        end
    end
end)

Callback:RegisterServerCallback("plouffe_banking:getCurrentLoanData", function(source,cb,authkey)
    if Auth:Validate(source,authkey) then
        if Auth:Events(source,"plouffe_banking:getCurrentLoanData") then
            BankFnc:GetPlayerCurrentLoan(exports.ooc_core:getPlayerFromId(source),"total_amount,paid_amount,remaining_amount,payment",function(exists)
                cb(exists)
            end)
        end
    end
end)