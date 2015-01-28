Apps.Merchant.importReactive.push (scope) ->
  if Session.get("myProfile")
    scope.managedImportProductList = []
    products = []; cursorProduct = Schema.products.find({merchant: Session.get("myProfile").currentMerchant})
    Helpers.searchProduct(cursorProduct, products)

    if Session.get("importManagementSearchFilter")?.length > 0
      importProductList = []
      importProductList = _.filter products, (item) ->
        unsignedTerm = Helpers.RemoveVnSigns Session.get("importManagementSearchFilter")
        unsignedName = Helpers.RemoveVnSigns item?.name
        unsignedName.indexOf(unsignedTerm) > -1
      Helpers.searchProductUnit(product, scope.managedImportProductList) for product in importProductList

    else
      if Session.get('currentImportDistributor')?.builtIn?.length > 0
        products = []; cursorProduct = Schema.products.find({_id: $in: Session.get('currentImportDistributor').builtIn})
        Helpers.searchProduct(cursorProduct, products)

      groupedProducts = _.groupBy products, (product) -> product.name.substr(0, 1).toLowerCase() if product.name
      for key, childs of groupedProducts
        productList = []
        Helpers.searchProductUnit(product, productList) for product in childs
        scope.managedImportProductList.push {key: key, childs: productList}

      scope.managedImportProductList = _.sortBy(scope.managedImportProductList, (num)-> num.key)

    if Session.get("importManagementSearchFilter")?.trim().length > 1
      if scope.managedImportProductList.length > 0
        productNameLists = _.pluck(scope.managedImportProductList, 'name')
        Session.set("importCreationMode", !_.contains(productNameLists, Session.get("importManagementSearchFilter").trim()))
      else
        Session.set("importCreationMode", true)
    else
      Session.set("importCreationMode", false)

