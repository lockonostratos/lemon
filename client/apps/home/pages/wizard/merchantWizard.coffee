currentIndex = 0
colors = [
  '#54c8eb', # light blue
  '#4ea9de', # med blue
  '#4b97d2', # dark blue
  '#92cc8f', # light green
  '#41bb98', # mint green
  '#c9de83', # yellowish green
  '#dee569', # yellowisher green
  '#c891c0', # light purple
  '#9464a8', # med purple
  '#7755a1', # dark purple
  '#f069a1', # light pink
  '#f05884', # med pink
  '#e7457b', # dark pink
  '#ffd47e', # peach
  '#f69078'  # salmon
]

registerErrors = [
  incorrectPassword  = { reason: "Incorrect password",  message: "tài khoản tồn tại"}
]

animateBackgroundColor = ->
  $(".merchant-wizard-wrapper").css("background-color", colors[currentIndex])
  currentIndex++
  currentIndex = 0 if currentIndex > colors.length

#packageOption = (option)->
#  packageClass          : option.packageClass
#  price                 : option.price
#  duration              : option.duration
#  defaultAccountLimit   : option.accountLim
#  defaultBranchLimit    : option.branchLim
#  defaultWarehouseLimit : option.warehouseLim
#  extendAccountPrice    : option.extendAccountPrice
#  extendBranchPrice     : option.extendBranchPrice
#  extendWarehousePrice  : option.extendBranchPrice
#
#runInitMerchantWizardTracker = (context) ->
#  return if Sky.global.merchantWizardTracker
#  Sky.global.merchantWizardTracker = Tracker.autorun ->
#    Router.go('/') if Meteor.userId() is null
#    unless Session.get('merchantPackages')?.user is Meteor.userId() then Router.go('/dashboard')
#    if Session.get('merchantPackages')?.merchantRegistered then Router.go('/dashboard')
#
#    if Session.get("merchantPackages")
#      Session.set 'extendAccountLimit',   Session.get("merchantPackages").extendAccountLimit ? 0
#      Session.set 'extendBranchLimit',    Session.get("merchantPackages").extendBranchLimit ? 0
#      Session.set 'extendWarehouseLimit', Session.get("merchantPackages").extendWarehouseLimit ? 0
#
#      if Template.merchantWizard.trialPackageOption.packageClass is Session.get("merchantPackages").packageClass
#        Session.set('merchantPackage', Template.merchantWizard.trialPackageOption)
#
#      if Template.merchantWizard.oneYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
#        Session.set('merchantPackage', Template.merchantWizard.oneYearsPackageOption)
#
#      if Template.merchantWizard.threeYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
#        Session.set('merchantPackage', Template.merchantWizard.threeYearsPackageOption)
#
#      if Template.merchantWizard.fiveYearsPackageOption.packageClass is Session.get("merchantPackages").packageClass
#        Session.set('merchantPackage', Template.merchantWizard.fiveYearsPackageOption)
#
#      if Session.get("merchantPackages").companyName?.length > 0 then Session.set('companyNameValid', 'valid')
#      else Session.set('companyNameValid', 'invalid')
#
#      if Session.get("merchantPackages").companyPhone?.length > 0 then Session.set('companyPhoneValid', 'valid')
#      else Session.set('companyPhoneValid', 'invalid')
#
#      if Session.get("merchantPackages").merchantName?.length > 0 then Session.set('merchantNameValid', 'valid')
#      else Session.set('merchantNameValid', 'invalid')
#
#      if Session.get("merchantPackages").warehouseName?.length > 0 then Session.set('warehouseNameValid', 'valid')
#      else Session.set('warehouseNameValid', 'invalid')
#
lemon.defineWidget Template.merchantWizard,
  rendered: ->
    self = @
    Meteor.setTimeout ->
      animateBackgroundColor()
      self.bgInterval = Meteor.setInterval(animateBackgroundColor, 15000)
    , 5000
  destroyed: -> Meteor.clearInterval(@bgInterval)
  events:
    "click .package-block": (event, template) -> Session.set('currentMerchantPackage', @options)
#
#  merchantPackage: -> Session.get('merchantPackages')
#  updateValid: ->
#    if Session.get('companyNameValid') is 'invalid' then return 'invalid'
#    if Session.get('companyPhoneValid') is 'invalid' then return 'invalid'
#    if Session.get('merchantNameValid') is 'invalid' then return 'invalid'
#    if Session.get('warehouseNameValid') is 'invalid' then return 'invalid'
#    return 'valid'
#
#  created: ->
#    Router.go('/') if Meteor.userId() is null
#    if Session.get("currentProfile")
#      Router.go('/dashboard') if Session.get("currentProfile").merchantRegistered
#
#    Session.setDefault('companyNameValid', 'invalid')
#    Session.setDefault('companyPhoneValid', 'invalid')
#    Session.setDefault('merchantNameValid', 'invalid')
#    Session.setDefault('warehouseNameValid', 'invalid')
#
#    Session.setDefault('extendAccountLimit', 0)
#    Session.setDefault('extendBranchLimit', 0)
#    Session.setDefault('extendWarehouseLimit', 0)
#
#  rendered: -> runInitMerchantWizardTracker()
#
#  events:
#    "blur #companyName"  : (event, template) ->
#      $companyName = $(template.find("#companyName"))
#      if $companyName.val().length > 0
#        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {companyName: $companyName.val()}
#      else
#        $companyName.notify('tên công ty không được để trống', {position: "right"})
#
#    "blur #companyPhone" : (event, template) ->
#      $companyPhone = $(template.find("#companyPhone"))
#      if $companyPhone.val().length > 0
#        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {companyPhone: $companyPhone.val()}
#      else
#        $companyPhone.notify('số điện thoại không được để trống!', {position: "right"})
#
#    "blur #merchantName" : (event, template) ->
#      $merchantName = $(template.find("#merchantName"))
#      if $merchantName.val().length > 0
#        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {merchantName: $merchantName.val()}
#      else
#        $merchantName.notify('tên chi nhánh không được để trống!', {position: "right"})
#
#    "blur #warehouseName": (event, template) ->
#      $warehouseName = $(template.find("#warehouseName"))
#      if $warehouseName.val().length > 0
#        Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: {warehouseName: $warehouseName.val()}
#      else
#        $warehouseName.notify('tên kho hàng không để trống!', {position: "right"})
#
#    "click .package-block.free": (event, template)->
#      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.trialPackageOption)
#
#    "click .package-block.basic": (event, template)->
#      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.oneYearsPackageOption)
#
#    "click .package-block.premium": (event, template)->
#      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.threeYearsPackageOption)
#
#    "click .package-block.advance": (event, template)->
#      Schema.merchantPackages.update Session.get("merchantPackages")._id, $set: packageOption(Template.merchantWizard.fiveYearsPackageOption)
#
#    "click #merchantUpdate.valid": (event, template)->
#      UserProfile.findOne(Session.get('currentProfile')?._id).updateNewMerchant()
#      Router.go('/dashboard')
#
#
#
#
#
#
