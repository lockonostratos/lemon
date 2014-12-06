Apps.Merchant.importInit.push (scope) ->
  scope.availableProducts    = Product.insideWarehouse(Session.get('myProfile').currentWarehouse)
  scope.availableSkulls      = Skull.insideMerchant(Session.get('myProfile').parentMerchant)
  scope.availableProviders   = Provider.insideMerchant(Session.get('myProfile').parentMerchant)
  scope.branchProviders      = Provider.insideBranch(Session.get('myProfile').currentMerchant)
  scope.availableDistributor = Distributor.insideMerchant(Session.get('myProfile').currentMerchant)
  scope.myHistory            = Import.myHistory(Session.get('myProfile').user, Session.get('myProfile').currentWarehouse, Session.get('myProfile').currentMerchant)
  scope.myCreateProduct      = Product.canDeleteByMeInside()
  scope.myCreateProvider     = Provider.canDeleteByMe()
  scope.myCreateDistributor  = Distributor.canDeleteByMe()