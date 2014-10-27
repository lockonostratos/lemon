formatPaymentMethodSearch = (item) -> "#{item.display}" if item

logics.sales.paymentMethodSelectOptions = ->
  query: (query) -> query.callback
    results: Sky.system.paymentMethods
    text: 'id'
  initSelection: (element, callback) -> callback _.findWhere(Sky.system.paymentMethods, {_id: logics.sales.currentOrder?.paymentMethod})
  formatSelection: formatPaymentMethodSearch
  formatResult: formatPaymentMethodSearch
  placeholder: 'CHỌN SẢN PTGD'
  minimumResultsForSearch: -1
  changeAction: (e) ->
    if e.added._id == 0
      option =
        paymentMethod  : e.added._id
        currentDeposit : logics.sales.currentOrder.finalPrice
        deposit        : logics.sales.currentOrder.finalPrice
        debit          : 0
    if e.added._id == 1
      option =
        paymentMethod  : e.added._id
        currentDeposit : 0
        deposit        : 0
        debit          : logics.sales.currentOrder.finalPrice
    Schema.orders.update(logics.sales.currentOrder._id, {$set: option})
  reactiveValueGetter: -> _.findWhere(Sky.system.paymentMethods, {_id: logics.sales.currentOrder?.paymentMethod})

