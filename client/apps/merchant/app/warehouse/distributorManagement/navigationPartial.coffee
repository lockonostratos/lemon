lemon.defineApp Template.distributorManagementNavigationPartial,
  events:
    "click .distributorToImport": (event, template) ->
      if distributor = Session.get("distributorManagementCurrentDistributor")
        Meteor.call 'distributorToImport', distributor, Session.get('myProfile'), (error, result) ->
          if error then console.log error else Router.go('/import')