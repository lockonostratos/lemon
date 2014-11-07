Meteor.publishComposite 'receivableAndRelates', -> #No phai thu
  self = @
  return {
    find: ->
      myProfile = Schema.userProfiles.findOne({user: self.userId})
      return EmptyQueryResult if !myProfile
      Schema.transactions.find({merchant: myProfile.currentMerchant, warehouse: myProfile.currentWarehouse, group: 'sale'})
    children: [
      find: (transaction) -> Schema.customers.find {_id: transaction.owner}
      children: [
        find: (customer, transaction) -> AvatarImages.find {_id: customer.avatar}
      ]
    ]
  }
#Meteor.publishComposite 'myMerchantContacts',
#  find: ->
#    currentProfile = Schema.userProfiles.findOne({user: @userId})
#    return [] if !currentProfile
#    Schema.userProfiles.find { currentMerchant: currentProfile.currentMerchant }
#  children: [
#    find: (profile) -> Meteor.users.find {_id: profile.user}
#  ,
#    find: (profile) -> AvatarImages.find {_id: profile.avatar}
#  ]

Schema.transactions.allow
  insert: -> true
  update: -> true
  remove: -> true

Schema.transactionDetails.allow
  insert: -> true
  update: -> true
  remove: -> true