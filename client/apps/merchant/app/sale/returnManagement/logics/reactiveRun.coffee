Apps.Merchant.returnManagementReactiveRun.push (scope) ->
  if Session.get("myProfile")
    products = Schema.products.find().fetch()
    scope.managedReturnProductList = []
    if Session.get("salesCurrentProductSearchFilter")?.length > 0
      salesProductList = []
      salesProductList = _.filter products, (item) ->
        unsignedTerm = Helpers.RemoveVnSigns Session.get("salesCurrentProductSearchFilter")
        unsignedName = Helpers.RemoveVnSigns item.name
        unsignedName.indexOf(unsignedTerm) > -1 || item.productCode?.indexOf(unsignedTerm) > -1
      for product in salesProductList
        scope.managedReturnProductList.push {product: product}
        Schema.productUnits.find({product: product._id}).forEach((unit)-> scope.managedReturnProductList.push {product: product, unit: unit})
    else
#      if Session.get('currentImportDistributor')?.builtIn?.length > 0
#        products = Schema.products.find({_id: $in: Session.get('currentImportDistributor').builtIn}).fetch()
      groupedProducts = _.groupBy products, (product) -> product.name.substr(0, 1).toLowerCase()
      for key, childs of groupedProducts
        productList = []
        for product in childs
          productList.push {product: product}
          Schema.productUnits.find({product: product._id}).forEach((unit)-> productList.push {product: product, unit: unit})
        scope.managedReturnProductList.push {key: key, childs: productList}
      scope.managedReturnProductList = _.sortBy(scope.managedReturnProductList, (num)-> num.key)


#    if Session.get("salesCurrentProductSearchFilter")?.trim().length > 1 and scope.managedReturnProductList.length is 0
#      Session.set("salesCurrentProductCreationMode", true)
#    else
#      Session.set("salesCurrentProductCreationMode", false)
