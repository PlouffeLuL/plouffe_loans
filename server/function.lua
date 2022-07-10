function BankFnc:GetPlayerCurrentLoan(xPlayer,str,cb)
    MySQL.query("SELECT "..str.." FROM banking_loan WHERE state_id = @state_id", {
        ["@state_id"] = xPlayer.state_id,
    }, function(exists)
        cb(exists[1])
    end)
end

function BankFnc:GenerateLoadForPlayerFromLoanId(playerId,loanId)
    local loanData = Bank.LoanList[loanId]

    if loanData then
        local xPlayer = exports.ooc_core:getPlayerFromId(playerId)
        local bankMoney = xPlayer.getAccount("bank").money
    
        if bankMoney >= loanData.bankMin then
            MySQL.query("SELECT playtime FROM users_characters WHERE state_id = @state_id",
            {
                ["@state_id"] = xPlayer.state_id
            }, function(userData)
                if userData[1].playtime >= Server.MinPlaytime then
                    self:GetPlayerCurrentLoan(xPlayer,"id",function(exists)
                        if exists then
                            TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'error', text = "vous avez deja un prêt a rembourser", length = 5000})
                        else
                            MySQL.query("INSERT INTO banking_loan (state_id,total_amount,remaining_amount,payment,player_name,date_taken) VALUES (@state_id,@total_amount,@remaining_amount,@payment,@player_name,@date_taken)", {
                                ["@state_id"] = xPlayer.state_id,
                                ["@total_amount"] = loanData.amount + loanData.interest,
                                ["@remaining_amount"] = loanData.amount + loanData.interest,
                                ["@payment"] = loanData.payment,
                                ["@player_name"] = xPlayer.name,
                                ["@date_taken"] = os.time()
                            }, function(inserted)
                                MySQL.query("INSERT INTO banking_loan_history (state_id,total_amount,payment,player_name,date_taken) VALUES (@state_id,@total_amount,@payment,@player_name,@date_taken)", {
                                    ["@state_id"] = xPlayer.state_id,
                                    ["@total_amount"] = loanData.amount + loanData.interest,
                                    ["@payment"] = loanData.payment,
                                    ["@player_name"] = xPlayer.name,
                                    ["@date_taken"] = os.time()
                                }, function(inserted)
                                    xPlayer.addAccountMoney("bank",loanData.amount)
                                    TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'success', text = "Vous avez recu un montant de "..tostring(loanData.amount).." $", length = 10000})
                                end)
                            end)
                        end
                    end)
                else
                    TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'error', text = "Vous avez besoin de minimum 7 jours de temp de jeux pour avoir un prêt", length = 5000})
                end
            end)
        else
            TriggerClientEvent('plouffe_lib:notify', playerId, { type = 'error', text = "Vous n'avez pas le montant minimal en banque pour avoir ce prêt", length = 5000})
        end
    end
end

function BankFnc:DoLoanPayments()
    MySQL.query("SELECT * FROM banking_loan",{}, function(results)
        for i = 1, #results, 1 do
            local xPlayer = ESX.GetPlayerFromStateId(results[i].state_id)
            local payment = results[i].payment
            local remaingAmount = results[i].remaining_amount
            local paidAmount = results[i].paid_amount

            if payment > remaingAmount then
                payment = remaingAmount
            end

            remaingAmount = remaingAmount - payment

            paidAmount = paidAmount + payment
            
            if xPlayer and xPlayer.characterId == results[i].charid then
                xPlayer.removeAccountMoney("bank",payment)
            else
				MySQL.query('UPDATE users_characters SET bank = bank - :amount WHERE state_id = @state_id',
				{
					['@amount'] = payment,
					['@identifier'] = results[i].state_id
				})
            end

            if remaingAmount > 0 then
                MySQL.query('UPDATE banking_loan SET paid_amount = @paid_amount, remaining_amount = @remaining_amount WHERE id = @id',
                {
                    ['@remaining_amount'] = remaingAmount,
                    ['@paid_amount'] = paidAmount,
                    ['@id'] = results[i].id
                })
            else
                MySQL.query('DELETE FROM banking_loan WHERE id = @id',
                {
                    ['@id'] = results[i].id
                })
            end
        end
    end)
end

function DoLoanPayments()
    BankFnc:DoLoanPayments()
end

CreateThread(function()
	TriggerEvent('cron:runAt', 7, 0, DoLoanPayments)
end)