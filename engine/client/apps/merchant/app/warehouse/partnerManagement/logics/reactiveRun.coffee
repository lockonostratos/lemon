Apps.Merchant.partnerManagementReactive.push (scope) ->
  if profile = Session.get("myProfile")
    scope.managedMyPartnerList = []; scope.managedUnSubmitPartnerList = []; scope.managedMerchantPartnerList = []
    scope.myPartnerList = Schema.partners.find({parentMerchant: profile.parentMerchant})
    if merchantProfile = Schema.merchantProfiles.findOne({merchant: profile.parentMerchant})
      scope.merchantPartnerList = Schema.merchantProfiles.find(
        _id:      { $nin: [merchantProfile._id] }
        merchant: { $nin: merchantProfile.merchantPartnerList }
      )

    if Session.get("partnerManagementSearchFilter")?.length > 0
      unsignedSearch = Helpers.RemoveVnSigns Session.get("partnerManagementSearchFilter")
      scope.myPartnerList.forEach(
        (myPartner)->
          unsignedName = Helpers.RemoveVnSigns myPartner.name
          if unsignedName.indexOf(unsignedSearch) > -1
            switch myPartner.status
              when 'myMerchant' then scope.managedMyPartnerList.push myPartner
              when 'successPartner' then scope.managedMyPartnerList.push myPartner
              when 'submitPartner' then scope.managedUnSubmitPartnerList.push myPartner
              when 'unSubmitPartner' then scope.managedUnSubmitPartnerList.push myPartner
      )

      scope.merchantPartnerList.forEach(
        (merchantPartner)->
          if merchantPartner.companyName
            unsignedName = Helpers.RemoveVnSigns merchantPartner.companyName
            scope.managedMerchantPartnerList.push merchantPartner if unsignedName.indexOf(unsignedSearch) > -1
      )

      scope.managedMyPartnerList = _.sortBy(scope.managedMyPartnerList, (num)-> num.name)
      scope.managedUnSubmitPartnerList = _.sortBy(scope.managedUnSubmitPartnerList, (num)-> num.name)
      scope.managedMerchantPartnerList = _.sortBy(scope.managedMerchantPartnerList, (num)-> num.name)

    else
      scope.myPartnerList.forEach(
        (myPartner)->
          switch myPartner.status
            when 'myMerchant' then scope.managedMyPartnerList.push myPartner
            when 'successPartner' then scope.managedMyPartnerList.push myPartner
            when 'submitPartner' then scope.managedUnSubmitPartnerList.push myPartner
            when 'unSubmitPartner' then scope.managedUnSubmitPartnerList.push myPartner
      )
      scope.managedMyPartnerList = _.sortBy(scope.managedMyPartnerList, (num)-> num.name)
      scope.managedUnSubmitPartnerList = _.sortBy(scope.managedUnSubmitPartnerList, (num)-> num.name)



    if Session.get("partnerManagementSearchFilter")?.trim().length > 1
      if (scope.managedMyPartnerList.length + scope.managedMerchantPartnerList + scope.managedUnSubmitPartnerList) > 0
        myPartnerNames       = _.pluck(scope.managedMyPartnerList, 'name')
        submitPartnerNames   = _.pluck(scope.managedUnSubmitPartnerList, 'name')
        merchantPartnerNames = _.pluck(scope.managedMerchantPartnerList, 'name')

        partnerNameLists = myPartnerNames.concat(submitPartnerNames).concat(merchantPartnerNames)
        Session.set("partnerManagementCreationMode", !_.contains(partnerNameLists, Session.get("partnerManagementSearchFilter").trim()))
      else
        Session.set("partnerManagementCreationMode", true)
    else
      Session.set("partnerManagementCreationMode", false)