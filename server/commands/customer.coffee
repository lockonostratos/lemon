Meteor.methods
  updateCustomerDebitAndPurchase: ->
    for customer in Schema.customers.find({}).fetch()
      Schema.customers.update(customer._id, $set:{totalPurchases: 0,  totalDebit: 0})
    for transaction in Schema.transactions.find({group: {$in:['sale', 'customer']}, receivable: true }).fetch()
      Schema.customers.update transaction.owner, $inc:{totalPurchases: transaction.totalCash,  totalDebit: transaction.debitCash}

  createNewReceiptCashOfCustomSale: (customerId, debtCash, description, paidDate)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
      customer = Schema.customers.findOne({_id: customerId, parentMerchant: profile.parentMerchant})
      if customer and customer.customSaleModeEnabled is true
        customSale = Schema.customSales.findOne({buyer: customer._id},{sort: {'version.createdAt': -1}})

        option =
          parentMerchant: profile.parentMerchant
          merchant      : profile.currentMerchant
          warehouse     : profile.currentWarehouse
          creator       : profile.user
          owner         : customer._id
          latestSale    : customSale._id if customSale
          group         : 'customSale'
          debtDate      : paidDate if paidDate
          totalCash     : debtCash

        incCustomerOption = {customSaleDebt: -debtCash }
        if debtCash > 0
          option.description = if description?.length > 0 then description else 'Thu Tiền'
          option.receivable  = true
          incCustomerOption.customSalePaid= debtCash
        else
          option.description = if description?.length > 0 then description else 'Cho Mượn Tiền'
          option.receivable  = false
          incCustomerOption.customSaleTotalCash = -debtCash

        option.debtBalanceChange = debtCash
        option.beforeDebtBalance = customer.customSaleDebt
        option.latestDebtBalance = customer.customSaleDebt - debtCash

        latestTransaction = Schema.transactions.findOne({owner: customer._id, latestSale: customSale._id, parentMerchant: profile.parentMerchant}, {sort: {debtDate: -1}})
        Schema.transactions.update latestTransaction._id, $set:{allowDelete: false} if latestTransaction

        Schema.transactions.insert option
        Schema.customSales.update customSale._id, $set:{allowDelete: false}
        Schema.customers.update customer._id, $inc: incCustomerOption

  createNewReceiptCashOfSales: (customerId, debtCash, description, paidDate)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
      if customer = Schema.customers.findOne({_id: customerId, parentMerchant: profile.parentMerchant})
        sale = Schema.sales.findOne({buyer: customer._id},{sort: {'version.createdAt': -1}})

        option =
          parentMerchant: profile.parentMerchant
          merchant      : profile.currentMerchant
          warehouse     : profile.currentWarehouse
          creator       : profile.user
          owner         : customer._id
          latestSale    : sale._id if sale
          group         : 'sales'
          debtDate      : paidDate if paidDate
          totalCash     : debtCash

        incCustomerOption = {customSaleDebt: -debtCash }
        if debtCash > 0
          option.description = if description?.length > 0 then description else 'Thu Tiền'
          option.receivable  = true
          incCustomerOption.customSalePaid = debtCash
        else
          option.description = if description?.length > 0 then description else 'Cho Mượn Tiền'
          option.receivable  = false
          incCustomerOption.customSaleTotalCash = -debtCash

        option.debtBalanceChange = debtCash
        option.beforeDebtBalance = customer.debtBalance
        option.latestDebtBalance = customer.debtBalance - debtCash
        
        Schema.transactions.insert option
        Schema.customers.update customer._id, $inc: incCustomerOption
