lemon.defineWidget Template.customerManagementCustomSaleDetails,
  isEditing: -> Session.get("customerManagementCurrentCustomSale")?._id is @_id
  customSaleDetails: ->
    customSaleId = UI._templateInstance().data._id
    Schema.customSaleDetails.find({customSale: customSaleId})

  events:
    "click .enter-edit": (event, template) -> Session.set("customerManagementCurrentCustomSale", @)
    "click .cancel-edit": (event, template) -> Session.set("customerManagementCurrentCustomSale")