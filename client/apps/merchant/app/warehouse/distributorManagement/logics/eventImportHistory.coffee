Apps.Merchant.distributorManagementInit.push (scope) ->
  scope.customImportModeDisable = ()->

  scope.createCustomImport = (template)->
    if distributor = Session.get("distributorManagementCurrentDistributor")
      latestCustomImport = Schema.customImports.findOne({seller: distributor._id}, {sort: {debtDate: -1}})
      $description = template.ui.$customImportDescription

      $debtDate = $(template.find("[name='customImportDebtDate']")).inputmask('unmaskedvalue')
      tempDate = moment($debtDate, 'DD/MM/YYYY')._d
      debtDate = new Date(tempDate.getFullYear(), tempDate.getMonth(), tempDate.getDate(), (new Date).getHours(), (new Date).getMinutes(), (new Date).getSeconds())
      limitDebtDate = new Date(tempDate.getFullYear() - 20, tempDate.getMonth(), tempDate.getDate())
      isValidDate = $debtDate.length is 8 and moment($debtDate, 'DD/MM/YYYY').isValid() and debtDate > limitDebtDate and debtDate < (new Date)

      if isValidDate and (latestCustomImport is undefined || debtDate >= latestCustomImport.debtDate)
        option =
          parentMerchant   : Session.get('myProfile').currentMerchant
          creator          : Session.get('myProfile').user
          seller           : distributor._id
          debtDate         : debtDate
          beforeDebtBalance: distributor.customImportDebt ? 0
          latestDebtBalance: distributor.customImportDebt ? 0
        option.description = $description.val() if $description.val().length > 0

        Meteor.call('createNewCustomImport', option)
        $(template.find("[name='customImportDebtDate']")).val(''); $description.val('')
      else
        console.log isValidDate , latestCustomImport is undefined, debtDate >= latestCustomImport.debtDate

  scope.createCustomImportDetail = (template, customImport) ->
    console.log template
    $productName = $(template.find("[name='productName']"))
    $price       = $(template.find("[name='price']"))
    #    $totalPrice  = $(template.find("[name='totalPrice']"))
    $quality     = $(template.find("[name='quality']"))
    $skulls      = $(template.find("[name='skulls']"))

    price        = parseInt($price.inputmask('unmaskedvalue'))
    #    totalPrice   = parseInt($totalPrice.inputmask('unmaskedvalue'))

    console.log customImport, $productName.val().length > 0, $skulls.val().length > 0, price > 0, $quality.val() > 0

    if customImport and $productName.val().length > 0 and $skulls.val().length > 0 and price > 0 and $quality.val() > 0
      customImportDetail =
        parentMerchant: Session.get('myProfile').parentMerchant
        creator       : Session.get('myProfile').user
        seller        : customImport.seller
        customImport  : customImport._id
        productName   : $productName.val()
        skulls        : $skulls.val()
        quality       : $quality.val()
        price         : price
        finalPrice    : $quality.val()*price

      latestCustomImport = Schema.customImports.findOne({buyer: customImport.buyer}, {sort: {debtDate: -1}})
      if customImport._id is latestCustomImport._id
        Meteor.call('updateCustomImportByCreateCustomImportDetail', customImportDetail)
      $productName.val(''); $price.val(''); $quality.val(''); $skulls.val('')
      $productName.focus()

  scope.createTransactionOfCustomImport = (template)->
    $payDescription = template.ui.$payDescription

    $paidDate   = template.ui.$paidDate.inputmask('unmaskedvalue')
    paidDate    = moment($paidDate, 'DD/MM/YYYY')._d
    isValidDate = $paidDate.length is 8 and moment($paidDate, 'DD/MM/YYYY').isValid()

    $payAmount  = template.ui.$payAmount
    payAmount   = $($payAmount).inputmask('unmaskedvalue')

    if distributor = Session.get("distributorManagementCurrentDistributor")
      if latestCustomImport = Schema.customImports.findOne({seller: distributor._id}, {sort: {debtDate: -1}})
        if latestTransaction = Schema.transactions.findOne({latestImport: latestCustomImport._id}, {sort: {debtDate: -1}})
          customImportCreatedAt = new Date(
            latestTransaction.debtDate.getFullYear()
            latestTransaction.debtDate.getMonth()
            latestTransaction.debtDate.getDate()
          )
        else
          customImportCreatedAt = new Date(
            latestCustomImport.debtDate.getFullYear()
            latestCustomImport.debtDate.getMonth()
            latestCustomImport.debtDate.getDate()
          )

      if isValidDate and !isNaN(payAmount) and Number(payAmount) != 0 and (latestCustomImport is undefined || paidDate >= customImportCreatedAt)
        Meteor.call('createNewReceiptCashOfCustomImport', distributor._id, Number(payAmount), $payDescription.val(), paidDate)
        Session.set("allowCreateTransactionOfCustomImport", false)
        $payDescription.val(''); $payAmount.val('')


  scope.createTransactionOfImport = (template, distributor)->
    $payDescription = template.ui.$paySaleDescription

    if latestImport = Schema.imports.findOne({distributor: distributor._id, finish: true, submitted: true}, {sort: {'version.createdAt': -1}})
      importCreatedAt = new Date(latestImport.version.createdAt.getFullYear(), latestImport.version.createdAt.getMonth(), latestImport.version.createdAt.getDate())

    $paidDate = $(template.find("[name='paidSaleDate']")).inputmask('unmaskedvalue')
    paidDate  = moment($paidDate, 'DD/MM/YYYY')._d
    limitCurrentPaidDate = new Date(paidDate.getFullYear() - 20, paidDate.getMonth(), paidDate.getDate())
    isValidDate = $paidDate.length is 8 and moment($paidDate, 'DD/MM/YYYY').isValid() and paidDate > limitCurrentPaidDate and paidDate >= importCreatedAt

    $payAmount = template.ui.$paySaleAmount
    payAmount = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))

    if latestImport and isValidDate and !isNaN(payAmount) and payAmount != 0
      Meteor.call('createNewReceiptCashOfImport', distributor._id, payAmount, $payDescription.val(), paidDate)
      Session.set("allowCreateTransactionOfImport", false)
      $payDescription.val(''); $payAmount.val('')