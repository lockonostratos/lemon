scope = logics.customerManagement

lemon.defineWidget Template.customerManagementDebitSection,
  oldTransaction: ->
    Schema.transactions.find({
      owner : Session.get("customerManagementCurrentCustomer")._id
      group : 'customer'
      status: 'tracking'
    })

  newTransaction: ->
    Schema.transactions.find({
      owner : Session.get("customerManagementCurrentCustomer")._id
      group : 'sale'
      status: 'tracking'
    })

  events:
  #click xem chi tiet
    "click .transactionDetail": (event, template) ->
#      Meteor.subscribe('transactionDetails', Session.get("currentTransaction")._id)