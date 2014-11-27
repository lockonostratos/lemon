scope = logics.customerManagement

lemon.defineWidget Template.customerManagementCustomSaleDetails,
  isEditing: -> Session.get("customerManagementCurrentCustomSale")?._id is @_id
  customSaleDetails: ->
    customSaleId = UI._templateInstance().data._id
    Schema.customSaleDetails.find({customSale: customSaleId})
  latestPaids: -> Schema.transactions.find({latestSale: @_id})

  events:
    "click .enter-edit" : (event, template) -> Session.set("customerManagementCurrentCustomSale", @)
    "click .cancel-edit": (event, template) -> Session.set("customerManagementCurrentCustomSale")
    "click .createCustomSaleDetail": (event, template) -> scope.createCustomSaleDetail(@, template)
    "click .deleteCustomSaleDetail": (event, template) -> scope.deleteCustomSaleDetail(@_id) 
    "click .deleteCustomSale": (event, template) -> scope.deleteCustomSale(@_id)