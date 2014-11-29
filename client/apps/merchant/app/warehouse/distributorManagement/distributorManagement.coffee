scope = logics.distributorManagement

lemon.defineApp Template.distributorManagement,
  showFilterSearch: -> Session.get("distributorManagementSearchFilter").length > 0
  avatarUrl: -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined
  currentDistributor: -> Session.get("distributorManagementCurrentDistributor")
  activeClass:-> if Session.get("distributorManagementCurrentDistributor")?._id is @._id then 'active' else ''
#  rendered: -> $(".nano").nanoScroller()
  created: ->
    Session.setDefault('allowCreateDistributor', false)

  events:
    "input input": (event, template) -> scope.checkAllowCreateDistributor(template)
    'click .create-distributor': (event, template)-> scope.createDistributor(template)

    "input .search-filter": (event, template) ->
      Session.set("distributorManagementSearchFilter", template.ui.$searchFilter.val())
    "click .inner.caption": (event, template) ->
      Schema.userSessions.update(Session.get("mySession")._id, {$set: {currentDistributorManagementSelection: @_id}})


    "click .excel-distributor": (event, template) -> $(".excelFileSource").click()
    "change .excelFileSource": (event, template) ->
      if event.target.files.length > 0
        console.log 'importing'
        $excelSource = $(".excelFileSource")
        $excelSource.parse
          config:
            complete: (results, file) ->
              console.log file, results
              Apps.Merchant.importFileDistributorCSV(results.data)
        $excelSource.val("")