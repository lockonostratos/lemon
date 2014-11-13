lemon.defineWidget Template.transactionManagerDetail,
  groupType: (group) ->
    switch group
      when 'sale' then 'Phiếu bán hàng'
      when 'import' then 'Phiếu nhập hàng'
      when 'customer' then 'Phiếu do nhân viên tạo'

  status      : -> if @transaction?.debitCash > 0 then 'Phiếu còn nợ' else 'Phiếu hết nợ'
  formatDate  : (date) -> moment(date).format("DD/MM/YYYY")
  countDetail : -> @transactionDetail?.count() ? 0

  allowAddDetail          : -> if @transaction?.debitCash > 0 then true
  showAddDetail           : -> !Session.get('showAddTransactionDetail')
  showDeleteTransaction   : -> if @transactionDetail?.count() is 0 and !Session.get('showAddTransactionDetail') then true
  createTransactionDetail : -> if Session.get('showAddTransactionDetail') then 'display: block' else 'display: none'

  rendered: -> Session.set('transactionDetailPaymentDate', new Date())
  events:
    "click .cancelCreateTransactionDetail": (event, template) -> Session.set('showAddTransactionDetail', false)
    "click .showTransactionDetail"        : (event, template) -> logics.transactionManager.showTransactionDetail()
    "click .createTransactionDetail"      : (event, template) -> logics.transactionManager.createNewTransactionDetail()
    "click .deleteTransaction"            : (event, template) ->
      Meteor.call 'deleteTransaction', @transaction._id, (error, result) -> if error then console.log error.error
    "change [name ='createDebtDate']"     : (event, template) ->
      Session.set('transactionDetailPaymentDate', $("[name=createDebtDate]").datepicker().data().datepicker.dates[0])


  depositCashOptions:
    reactiveSetter: (val) -> Session.set('depositCashNewTransactionDetail', val)
    reactiveValue: -> Session.get('depositCashNewTransactionDetail') ? 0
    reactiveMax: -> Session.get('currentTransaction')?.debitCash ? 0
    reactiveMin: -> 0
    reactiveStep: -> 10000