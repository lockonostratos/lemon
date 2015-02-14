navigateNewTab=(currentImportId, profile)->
  allTabs = Import.myHistory(profile.user, profile.currentWarehouse, profile.currentMerchant).fetch()
  currentSource = _.findWhere(allTabs, {_id: currentImportId})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length

  if currentLength > 1
    nextIndex = if currentIndex == currentLength - 1 then currentIndex - 1 else currentIndex + 1
    UserSession.set('currentImport', allTabs[nextIndex]._id)
  else
    if newImport = Import.createdNewBy(null, null, profile)
      UserSession.set('currentImport', newImport._id)
      Schema.imports.findOne(newImport._id)


updateImportAndDistributor = (currentImport, distributor)->
  distributorOption = {
    importDebt     : currentImport.totalPrice
    importTotalCash: currentImport.totalPrice
  }
  Schema.distributors.update distributor._id, $inc: distributorOption, $set: {allowDelete: false, lastImport: currentImport._id}

  importOption = {
    beforeDebtBalance   : distributor.importDebt
    debtBalanceChange   : currentImport.totalPrice
    latestDebtBalance   : distributor.importDebt + currentImport.totalPrice
    finish              : true
    submitted           : true
    status              : 'success'
    'version.createdAt' : new Date()
  }
  Schema.imports.update currentImport._id, $set: importOption

updateImportAndPartner = (currentImport, partnerSales, partner, profile, listData, status = 'success')->
  importOption =
    beforeDebtBalance   : partner.importDebt
    debtBalanceChange   : currentImport.totalPrice
    latestDebtBalance   : partner.importDebt + currentImport.totalPrice
    finish              : true
    submitted           : true
    partnerSale         : partnerSales._id
    'version.createdAt' : new Date()
  importOption.status = status
  Schema.imports.update currentImport._id, $set: importOption



  partnerAddToSet =
    importList        : currentImport._id
    productDetailList : { $each: _.uniq(listData.productDetailList) }
    productList       : { $each: _.uniq(listData.productList) }
    branchProductList : { $each: _.uniq(listData.branchProductList) }
  if listData.productUnitList.length > 0
    partnerAddToSet.productUnitList = { $each: _.uniq(listData.productUnitList) }
  if listData.branchProductUnitList.length > 0
    partnerAddToSet.branchProductUnitList = { $each: _.uniq(listData.branchProductUnitList) }

  if currentImport.deposit > 0
    transactionOption =
      parentMerchant    : profile.parentMerchant
      merchant          : profile.currentMerchant
      warehouse         : profile.currentWarehouse
      creator           : profile.user
      owner             : partner._id
      group             : 'import'
      description       : 'Trả Tiền'
      receivable        : false
      totalCash         : currentImport.deposit
      debtDate          : new Date()
      debtBalanceChange : currentImport.deposit
      beforeDebtBalance : partner.importDebt
      latestDebtBalance : partner.importDebt - currentImport.deposit
    transactionOption.status = status
    Schema.transactions.insert transactionOption

  partnerOptionUpdate = { $addToSet: partnerAddToSet , $set: {allowDelete: false} }
  if status is 'success'
    partnerIncOption =
      importDebt      : currentImport.totalPrice
      importTotalCash : currentImport.totalPrice
    if currentImport.deposit > 0
      partnerIncOption.importDebt = -currentImport.deposit
      partnerIncOption.importPaid = currentImport.deposit
    partnerOptionUpdate.$inc = partnerIncOption
  Schema.partners.update partner._id, partnerOptionUpdate
  Schema.partners.update partner.partner, $set: {allowDelete: false}

updateBuiltInOfDistributor = (distributorId, importDetails)->
  productIds = _.uniq(_.pluck(importDetails, 'product'))
  Schema.distributors.update(distributorId, $push: {builtIn:{ $each: productIds, $slice: -50 }, importProductList:{ $each: productIds}})

Meteor.methods
  importEnabledEdit: (importId) ->
    currentImport = Schema.imports.findOne({_id: importId, finish: false, submitted: true})
    if currentImport
      importDetails = Schema.importDetails.find({import: importId}).fetch()
      if importDetails.length > 0
        for importDetail in importDetails
          Schema.importDetails.update importDetail._id, $set: {submitted: false}
        Schema.imports.update importId, $set:{submitted: false}
        return 'Phieu Co The Duoc Chinh Sua'

  importSubmit: (importId)->
    currentImport = Schema.imports.findOne({_id: importId, finish: false, submitted: false})
    if currentImport and (currentImport.distributor or currentImport.partner)
      importDetails = Schema.importDetails.find({import: importId}).fetch()
      if importDetails.length > 0
        for importDetail in importDetails
          Schema.importDetails.update importDetail._id, $set: {submitted: true}
        Schema.imports.update importId, $set:{submitted: true}
        return 'Duoc Xac Nhan, Cho Duyet Cua Quan Ly'

  importFinish: (importId)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
# kiem tra phan quyen
# Role.hasPermission(profile.user, Apps.Merchant.Permissions.su.key)
      currentImport = Schema.imports.findOne({_id: importId, submitted: true, finish: false, merchant: profile.currentMerchant})
      if currentImport and (currentImport.distributor or currentImport.partner)
        importDetails = Schema.importDetails.find({import: importId}).fetch()
        for importDetail in importDetails
          if !Schema.products.findOne importDetail.product
            throw new Meteor.Error('importError', 'Không tìm thấy sản phẩm id:'+ importDetail.product); return

        if currentImport.distributor
          for importDetail in importDetails
            productDetail = ProductDetail.newProductDetail(currentImport, importDetail)
            productDetail.status = 'success'
            Schema.productDetails.insert productDetail, (error, result) ->
              if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return

            incOption =
              totalQuality    : importDetail.importQuality
              availableQuality: importDetail.importQuality
              inStockQuality  : importDetail.importQuality

            setOption =
              provider    : importDetail.provider
              importPrice : Math.ceil(importDetail.importPrice)
              allowDelete : false
            setOption.price = importDetail.salePrice if importDetail.salePrice

            Schema.providers.update(productDetail.provider, $set:{allowDelete: false})
            Schema.products.update productDetail.product, $inc: incOption, $set: setOption, (error, result) ->
              if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return
            Schema.branchProductSummaries.update productDetail.branchProduct, $inc: incOption, $set: setOption, (error, result) ->
              if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return

          navigateNewTab(currentImport._id, profile)
          if distributor = Schema.distributors.findOne(currentImport.distributor)
            updateBuiltInOfDistributor(distributor._id, importDetails)
            updateImportAndDistributor(currentImport, distributor)
            if currentImport.deposit > 0
              Meteor.call('createNewReceiptCashOfImport', distributor._id, currentImport.deposit)

#          warehouseImport = Schema.imports.findOne(importId)
#          transaction = Transaction.newByImport(warehouseImport)
#          transactionDetail = TransactionDetail.newByTransaction(transaction)
          MetroSummary.updateMetroSummaryByImport(importId)
          MetroSummary.updateMyMetroSummaryBy(['createdImport'],  importId)

        if currentImport.partner
          if myPartner = Schema.partners.findOne(currentImport.partner)
            listDataOfPartner =
              productDetailList: []
              productList      : []
              productUnitList  : []
              branchProductList     : []
              branchProductUnitList : []

            if myPartner.buildIn
              if myPartner.status is 'success'
                partnerSales =
                  parentMerchant: myPartner.buildIn
                  partner       : myPartner.partner
                  partnerImport : currentImport._id
                  totalPrice    : currentImport.totalPrice
                  deposit       : currentImport.deposit
                  debit         : currentImport.debit
                  status        : 'unSubmit'
                  beforeDebtBalance: myPartner.saleDebt
                  debtBalanceChange: currentImport.totalPrice
                  latestDebtBalance: myPartner.saleDebt + currentImport.totalPrice

                if partnerSales._id = Schema.partnerSales.insert partnerSales
                  for importDetail in importDetails
                    productDetail = ProductDetail.newProductDetail(currentImport, importDetail)
                    productDetail.status = 'unSubmit'
                    Schema.productDetails.insert productDetail, (error, result) ->
                      if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return
                      else
                        listDataOfPartner.productDetailList.push result
                        listDataOfPartner.productList.push productDetail.product
                        listDataOfPartner.branchProductList.push productDetail.branchProduct
                        listDataOfPartner.productUnitList.push productDetail.unit if productDetail.unit
                        listDataOfPartner.branchProductUnitList.push productDetail.branchUnit if productDetail.branchUnit

                        partnerSaleDetail =
                          partnerSales      : partnerSales._id
                          buildInProduct    : productDetail.buildInProduct
                          quality           : productDetail.importQuality
                          price             : productDetail.importPrice
                          unitQuality       : productDetail.unitQuality
                          unitPrice         : productDetail.unitPrice
                          conversionQuality : productDetail.conversionQuality
                        partnerSaleDetail.buildInProductUnit = productDetail.buildInProductUnit if productDetail.unit
                        Schema.partnerSaleDetails.insert partnerSaleDetail

                  navigateNewTab(currentImport._id, profile)
                  updateImportAndPartner(currentImport, partnerSales, myPartner, profile, listDataOfPartner, 'unSubmit')
              else throw new Meteor.Error('importError', 'Doi tac chua ket noi'); return

            else
              for importDetail in importDetails
                productDetail = ProductDetail.newProductDetail(currentImport, importDetail)
                productDetail.status = 'success'
                Schema.productDetails.insert productDetail, (error, result) ->
                  if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return
                  else
                    listDataOfPartner.productDetailList.push result
                    listDataOfPartner.productList.push productDetail.product
                    listDataOfPartner.branchProductList.push productDetail.branchProduct
                    listDataOfPartner.productUnitList.push productDetail.unit if productDetail.unit
                    listDataOfPartner.branchProductUnitList.push productDetail.branchUnit if productDetail.branchUnit

                incOption =
                  totalQuality    : importDetail.importQuality
                  availableQuality: importDetail.importQuality
                  inStockQuality  : importDetail.importQuality

                setOption =
                  provider    : importDetail.provider
                  importPrice : Math.ceil(importDetail.importPrice)
                  allowDelete : false
                setOption.price = importDetail.salePrice if importDetail.salePrice

                Schema.providers.update(productDetail.provider, $set:{allowDelete: false})
                Schema.products.update productDetail.product, $inc: incOption, $set: setOption, (error, result) ->
                  if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return
                Schema.branchProductSummaries.update productDetail.branchProduct, $inc: incOption, $set: setOption, (error, result) ->
                  if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return

              navigateNewTab(currentImport._id, profile)
              updateImportAndPartner(currentImport, partnerSales, myPartner, profile, listDataOfPartner, 'success')
              MetroSummary.updateMetroSummaryByImport(currentImport._id)
              MetroSummary.updateMyMetroSummaryBy(['createdImport'],  currentImport._id)

        return ('Phiếu nhập kho đã được duyệt')
    else
      throw new Meteor.Error('importError', 'Đã có lỗi trong quá trình xác nhận')