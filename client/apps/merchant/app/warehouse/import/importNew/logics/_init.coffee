logics.import = {}
Apps.Merchant.importInit = []
Apps.Merchant.importReload = []
Apps.Merchant.importReactive = []

Apps.Merchant.importReactive.push (scope) ->
  if productId = Session.get("mySession")?.currentImportProductManagementSelection
    Session.set("importManagementCurrentProduct", Schema.products.findOne(productId))


  if Session.get('mySession') and Session.get('myProfile')
    scope.currentImport = Import.findBy(Session.get('mySession').currentImport,
      Session.get('myProfile').currentWarehouse,
      Session.get('myProfile').currentMerchant)

  if currentImport = scope.currentImport
    Session.set('currentImport', scope.currentImport)
    Meteor.subscribe('importDetails', scope.currentImport._id)
    scope.currentImportDetails = ImportDetail.findBy(scope.currentImport._id)

    scope.hidePriceSale = scope.currentImport.currentPrice > 0
    scope.showCreateDetail = !currentImport.submitted
    scope.showEdit   = currentImport.submitted
    permission = Role.hasPermission(Session.get('myProfile')._id, Apps.Merchant.Permissions.su.key)
    scope.showSubmit = currentImport.distributor and scope.currentImportDetails.count() > 0 and !currentImport.submitted and !permission
    scope.showFinish = currentImport.distributor and scope.currentImportDetails.count() > 0 and !scope.showSubmit






