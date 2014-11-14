checkValidationFileImport = (data)->
  productColumn = {}
  productColumn.barcode        = data.indexOf("Mã Code")
  productColumn.name           = data.indexOf("Tên Sản Phẩm")
  productColumn.skull          = data.indexOf("Qui Cách")
  productColumn.quality        = data.indexOf("Số Lượng")
  productColumn.price          = data.indexOf("Giá Nhập")
  productColumn.priceSale      = data.indexOf("Giá Bán")
  productColumn.productionDate = data.indexOf("Ngày Sản Xuất")
  productColumn.expireDate     = data.indexOf("Ngày Hết Hạn")
  productColumn.providerName   = data.indexOf("Nhà Cung Cấp")

  for key, value of productColumn
    return productColumn = {} if value is -1

  productColumn


checkAndAddNewProvider = (column, data, profile)->
  for item in data
    if !Schema.providers.findOne({parentMerchant: profile.parentMerchant, name: item[column.providerName]})
      Provider.createNew(item[column.providerName])

checkAndAddNewProduct = (column, data, profile)->
  for item in data
    if !Schema.products.findOne({
      merchant    : profile.currentMerchant
      warehouse   : profile.currentWarehouse
      productCode : item[column.barcode]
      skulls      : item[column.skull]
    }) then Product.createNew(item[column.barcode], item[column.name], [item[column.skull]], profile.currentWarehouse)

addDetailInImport1 = (column, data, profile)->
  for item in data
    imports = logics.import.currentImport
    provider = Schema.providers.findOne({parentMerchant: profile.parentMerchant, name: item[column.providerName]})
    product = Schema.products.findOne({
      merchant    : profile.currentMerchant
      warehouse   : profile.currentWarehouse
      productCode : item[column.barcode]
      skulls      : item[column.skull]
    })

    importDetail =
      merchant      : imports.merchant
      warehouse     : imports.warehouse
      import        : imports._id
      product       : product._id
      provider      : provider._id
      importQuality : item[column.quality]
      importPrice   : item[column.price]
      salePrice     : item[column.priceSale]
      totalPrice    : item[column.quality] * item[column.price]
      productionDate: moment(item[column.productionDate], "DD/MM/YYYY")._d
      expire        : moment(item[column.expireDate], "DD/MM/YYYY")._d

    findImportDetail = Schema.importDetails.findOne({
      import          : importDetail.import
      product         : importDetail.product
      importPrice     : Number(importDetail.importPrice)
      provider        : importDetail.provider if importDetail.provider
      productionDate  : importDetail.productionDate if importDetail.productionDate
      timeUse         : importDetail.timeUse if importDetail.timeUse
      expire          : importDetail.expire if importDetail.expire
    })

    if findImportDetail
      option = $inc:{importQuality:importDetail.importQuality, totalPrice: importDetail.importQuality * findImportDetail.importPrice}
      Schema.importDetails.update findImportDetail._id, option, (error, result) -> console.log error if error
    else
      Schema.importDetails.insert importDetail, (error, result) -> console.log error if error

addDetailInImport = (column, data, profile)->
  for item in data
    importId = logics.import.currentImport._id
    productId = Schema.products.findOne({
      merchant    : profile.currentMerchant
      warehouse   : profile.currentWarehouse
      productCode : item[column.barcode]
      skulls      : item[column.skull]
    })._id
    providerId = Schema.providers.findOne({parentMerchant: profile.parentMerchant, name: item[column.providerName]})._id
    quality = item[column.quality]
    price = item[column.price]
    priceSale = item[column.priceSale]
    #    timeUse = null
    productionDate = moment(item[column.productionDate], "DD/MM/YYYY")._d
    expireDate = moment(item[column.providerName], "DD/MM/YYYY")._d

    ImportDetail.new(importId, productId, quality, price, providerId)
#    ImportDetail.new(importId, productId, quality, price, providerId, priceSale, productionDate, timeUse)

Apps.Merchant.exportFileImport = (data)->
  profile = Schema.userProfiles.findOne({user: Meteor.userId()})
  productColumn = checkValidationFileImport(data[0])
  if _.keys(productColumn).length > 0
    data = _.without(data, data[0])
    checkAndAddNewProvider(productColumn, data, profile)
    checkAndAddNewProduct(productColumn, data, profile)
    addDetailInImport1(productColumn, data, profile)

