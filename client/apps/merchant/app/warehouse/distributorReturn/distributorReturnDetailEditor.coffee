scope = logics.distributorReturn

lemon.defineHyper Template.distributorReturnDetailEditor,
  productName: -> Schema.products.findOne(@product)?.name
  unitName: -> if @unit then Schema.productUnits.findOne(@unit)?.unit else Schema.products.findOne(@product)?.basicUnit
  crossReturnAvailableQuality: ->
    if currentReturn = Session.get('currentReturn')
      returnDetail   = @
      currentProduct = Schema.productDetails.find({distributor: currentReturn.distributor, product: @product}).fetch()
      sameProducts = Schema.returnDetails.find({return: returnDetail.return, product: returnDetail.product}).fetch()
      crossProductQuality = 0
      currentProductQuality = 0
      crossProductQuality += item.returnQuality for item in sameProducts
      currentProductQuality += item.availableQuality for item in currentProduct

      crossAvailable = currentProductQuality - crossProductQuality
      if crossAvailable < 0
        crossAvailable = Math.ceil(Math.abs(crossAvailable/returnDetail.conversionQuality))*(-1)
      else
        Math.ceil(Math.abs(crossAvailable/returnDetail.conversionQuality))

      return {
        crossAvailable: crossAvailable
        isValid: crossAvailable > 0
        invalid: crossAvailable < 0
        errorClass: if crossAvailable >= 0 then '' else 'errors'
      }

  rendered: ->
    @ui.$editQuality.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}
    @ui.$editPrice.inputmask "numeric",
        {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: false}

    @ui.$editQuality.val Session.get("returnEditingRow").unitReturnQuality
    @ui.$editPrice.val Session.get("returnEditingRow").unitReturnsPrice

    @ui.$editQuality.select()


  events:
    "keyup input[name]": (event, template) ->
      unitQuality = Math.abs(Number(template.ui.$editQuality.inputmask('unmaskedvalue')))
      unitPrice   = Math.abs(Number(template.ui.$editPrice.inputmask('unmaskedvalue')))
      totalPrice = unitQuality * unitPrice

      optionDetail =
        unitReturnQuality: unitQuality
        unitReturnsPrice: unitPrice
        returnQuality: @conversionQuality * unitQuality
        price: unitPrice/@conversionQuality
        totalPrice: totalPrice
        finalPrice: totalPrice

      Schema.returnDetails.update @_id, $set: optionDetail
      scope.reCalculateReturn(@return)

    "click .deleteReturnDetail": (event, template) ->
      Schema.returnDetails.remove @_id
      scope.reCalculateReturn(@return)