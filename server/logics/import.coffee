navigateNewTab=(currentImportId, profile)->
  allTabs = Import.myHistory(profile.user, profile.currentWarehouse, profile.currentMerchant).fetch()
  currentSource = _.findWhere(allTabs, {_id: currentImportId})
  currentIndex = allTabs.indexOf(currentSource)
  currentLength = allTabs.length

  if currentLength > 1
    nextIndex = if currentIndex == currentLength - 1 then currentIndex - 1 else currentIndex + 1
    UserSession.set('currentImport', allTabs[nextIndex]._id)
  else
    importId = Import.createdNewBy('01-05-2015', profile)
    UserSession.set('currentImport', importId)
    Schema.imports.findOne(importId)


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
    if currentImport
      importDetails = Schema.importDetails.find({import: importId}).fetch()
      if importDetails.length > 0
        for importDetail in importDetails
          Schema.importDetails.update importDetail._id, $set: {submitted: true}
        Schema.imports.update importId, $set:{submitted: true}
        return 'Duoc Xac Nhan, Cho Duyet Cua Quan Ly'

  importFinish: (importId)->
    if profile = Schema.userProfiles.findOne({user: Meteor.userId()})
# kiem tra phan quyen
#      Role.hasPermission(profile.user, Apps.Merchant.Permissions.su.key)
      currentImport = Schema.imports.findOne({_id: importId, submitted: true, finish: false, merchant: profile.currentMerchant})
      if currentImport
        importDetails = Schema.importDetails.find({import: importId}).fetch()
        for importDetail in importDetails
          if !Schema.products.findOne importDetail.product
            throw new Meteor.Error('importError', 'Không tìm thấy sản phẩm id:'+ importDetail.product); return

        for importDetail in importDetails
          productDetail= ProductDetail.newProductDetail(currentImport, importDetail)
          Schema.productDetails.insert productDetail, (error, result) ->
            if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return

          product = Schema.products.findOne importDetail.product
          option1=
            totalQuality    : importDetail.importQuality
            availableQuality: importDetail.importQuality
            inStockQuality  : importDetail.importQuality

          option2=
            provider    : importDetail.provider
            importPrice : importDetail.importPrice
          option2.price = importDetail.salePrice if importDetail.salePrice

          Schema.products.update product._id, $inc: option1, $set: option2, (error, result) ->
            if error then throw new Meteor.Error('importError', 'Sai thông tin sản phẩm nhập kho'); return

        navigateNewTab(currentImport._id, profile)
        Schema.imports.update currentImport._id, $set:{finish: true, submitted: true}
        warehouseImport = Schema.imports.findOne(importId)
        transaction = Transaction.newByImport(warehouseImport)
        transactionDetail = TransactionDetail.newByTransaction(transaction)
        MetroSummary.updateMetroSummaryByImport(importId)
      return ('Phiếu nhập kho đã được duyệt')
    else
      throw new Meteor.Error('importError', 'Đã có lỗi trong quá trình xác nhận')