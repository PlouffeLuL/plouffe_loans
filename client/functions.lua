local Callback = exports.plouffe_lib:Get("Callback")
local Utils = exports.plouffe_lib:Get("Utils")

function BankFnc:Start()    
    TriggerEvent('ooc_core:getCore', function(Core) 
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        Bank.Player = Core.Player:GetPlayerData()

        self:ExportsAllZones()
        self:RegisterEvents()
    end)
end

function BankFnc:ExportsAllZones()
    for k,v in pairs(Bank.Zones) do
        exports.plouffe_lib:ValidateZoneData(v)
    end
end

function BankFnc:RegisterEvents()
    RegisterNetEvent("plouffe_banking:zone_action", function(p)
        if BankFnc[p.fnc] then
            BankFnc[p.fnc]("",p)
        end
    end)
end

function BankFnc:SelfCoolDown(time)
    if Bank.Utils.coolDown then
        return
    end

    CreateThread(function()
        Bank.Utils.coolDown = true
        Wait(time)
        Bank.Utils.coolDown = false
    end)
end

function BankFnc:FormatAmountNumber(n)
    local strAmount = tostring(n)    
    local str,match = strAmount:gsub("000", "")
    if match == 1 then
        return strAmount:gsub("000", "").." 000 $"
    end
    return strAmount.." $"
end

function BankFnc:InteractionMenu()
    if Bank.Utils.coolDown then
        return 
    end

    BankFnc:SelfCoolDown(500)
    
    exports.ooc_menu:Open(Bank.Menu.interaction, function(p)
        if not p then
            return
        end

        if BankFnc[p.fnc] then
            BankFnc[p.fnc]("",p)
        end
    end)
end

function BankFnc:ShowPersonnalLoans()
    Callback:Await("plouffe_banking:getCurrentLoanData",function(loanData)
        if loanData then
            BankFnc:ShowPersonnalLoanInfo(loanData)
        else
            Utils:Notify("error", "Vous n'avez pas de prêt actif présentement", 5000)
        end
    end, Bank.Utils.MyAuthKey)
end

function BankFnc:SeeLoansList()
    local data = {}
    local id = 0
    for k,v in pairs(Bank.LoanList) do
        id = id + 1

        table.insert(data, {
            id = id,
            header = "Montant: "..BankFnc:FormatAmountNumber(v.amount),
            txt = "Voir plus d'informations sur ce prêt",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = k
                }
            }
        })
    end

    exports.ooc_menu:Open(data, function(p)
        if not p then
            return
        end

        if BankFnc[p.fnc] then
            BankFnc[p.fnc]("",p)
        end
    end)
end

function BankFnc:ShowDetailedLoanList(p)
    local data = {
        {
            id = 1,
            header = "Montant: "..BankFnc:FormatAmountNumber(Bank.LoanList[p.key].amount),
            txt = "Montant total du prêt avec les intérêts",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = p.key
                }
            }
        },

        {
            id = 2,
            header = "Intérêt: "..BankFnc:FormatAmountNumber(Bank.LoanList[p.key].interest),
            txt = "Montant supplémentaire qui sera ajouter a votre prêt",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = p.key
                }
            }
        },

        {
            id = 3,
            header = "Minimal en banque: "..BankFnc:FormatAmountNumber(Bank.LoanList[p.key].bankMin),
            txt = "Montant minimal que vous devez avoir en banque",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = p.key
                }
            }
        },

        {
            id = 4,
            header = "Paiments: "..BankFnc:FormatAmountNumber(Bank.LoanList[p.key].payment),
            txt = "Montant qui sera retirer de votre compte chaques 24 heurs",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = p.key
                }
            }
        },

        {
            id = 5,
            header = "Montant total: "..BankFnc:FormatAmountNumber(Bank.LoanList[p.key].amount + Bank.LoanList[p.key].interest),
            txt = "Montant total du prêt avec les intérêts",
            params = {
                event = "",
                args = {
                    fnc = "ShowDetailedLoanList",
                    key = p.key
                }
            }
        },

        {
            id = 6,
            header = "Prendre ce prêt",
            txt = "Demander a avoir ce prêt",
            params = {
                event = "",
                args = {
                    fnc = "GenerateNewLoan",
                    key = p.key
                }
            }
        },

        {
            id = 7,
            header = "Retour",
            txt = "Voir les autres prêts",
            params = {
                event = "",
                args = {
                    fnc = "SeeLoansList"
                }
            }
        }
    }

    exports.ooc_menu:Open(data, function(p)
        if not p then 
            return
        end
        
        if BankFnc[p.fnc] then
            BankFnc[p.fnc]("",p)
        end
    end)
end

function BankFnc:ShowPersonnalLoanInfo(data)
    local data = {
        {
            id = 1,
            header = "Montant: "..BankFnc:FormatAmountNumber(data.total_amount),
            txt = "Montant total du prêt sans les intérêts",
            params = {
                event = "",
                args = {
                    penis = "penis"
                }
            }
        },

        {
            id = 2,
            header = "Paiments: "..BankFnc:FormatAmountNumber(data.payment),
            txt = "Montant retirer de votre compte chaques 24 heurs",
            params = {
                event = "",
                args = {
                    penis = "penis"
                }
            }
        },

        {
            id = 3,
            header = "Montant rembourser: "..BankFnc:FormatAmountNumber(data.paid_amount),
            txt = "Montant que vous avez deja payer",
            params = {
                event = "",
                args = {
                    penis = "penis"
                }
            }
        },

        {
            id = 4,
            header = "Montant restant: "..BankFnc:FormatAmountNumber(data.remaining_amount),
            txt = "Montant restant a payer",
            params = {
                event = "",
                args = {
                    penis = "penis"
                }
            }
        }
    }

    exports.ooc_menu:Open(data, function(p) end)
end

function BankFnc:GenerateNewLoan(p)
    TriggerServerEvent("plouffe_banking:askforloan",p.key,Bank.Utils.MyAuthKey)
end