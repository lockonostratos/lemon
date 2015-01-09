scope = logics.productManagement

lemon.defineHyper Template.productManagementSalesHistorySection,
  isShowDisableMode: -> if @basicDetailModeEnabled is true and @totalQuality >= @salesQuality then true else false
  buyerName: -> Schema.customers.findOne(Schema.sales.findOne(@sale)?.buyer)?.name
  unitSaleQuality: -> Math.round(@quality/@conversionQuality*100)/100


  basicDetail: ->
    if product = Session.get("productManagementCurrentProduct")
      productDetailFound = Schema.productDetails.find({product: product._id, import: {$exists: false}})
      return {
        isShowDetail: if @basicDetailModeEnabled then true else productDetailFound.count() > 0
        detail: productDetailFound
      }

  newImport: ->
    if product = Session.get("productManagementCurrentProduct")
      allProductDetail = Schema.productDetails.find({product: product._id, import: {$exists: true}}).fetch()
      currentImport = Schema.imports.find({_id: {$in: _.union(_.pluck(allProductDetail, 'import'))}}, {sort: {'version.createdAt': 1}})
      return {
        isShowDetail: if currentImport.count() > 0 then true else false
        detail: currentImport
      }

  allSaleDetails: -> Schema.saleDetails.find({product: @_id})

  events:
    "click .basicDetailModeDisable": ->
      if product = Session.get("productManagementCurrentProduct")
        if product.basicDetailModeEnabled is true
          Meteor.call 'updateProductBasicDetailMode', product._id, (error, result) ->
            Meteor.subscribe('productManagementData', product._id)
          Session.set("productManagementDetailEditingRowId")
          Session.set("productManagementDetailEditingRow")
          Session.set("productManagementUnitEditingRowId")
          Session.set("productManagementUnitEditingRow")