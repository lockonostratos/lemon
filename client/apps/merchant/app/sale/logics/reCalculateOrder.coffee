calculateDepositAndDebitByProduct = (currentOrder, orderUpdate)->
  if currentOrder.currentDeposit > orderUpdate.finalPrice
    orderUpdate.currentDeposit = currentOrder.currentDeposit
  else
    orderUpdate.currentDeposit = orderUpdate.finalPrice

  orderUpdate.deposit = orderUpdate.finalPrice
  orderUpdate.debit = 0
  orderUpdate

calculateDepositAndDebitByBill = (currentOrder, orderUpdate)->
  if currentOrder.currentDeposit >= orderUpdate.finalPrice
    orderUpdate.paymentMethod = 0
    orderUpdate.deposit = orderUpdate.finalPrice
    orderUpdate.debit = 0
  else
    orderUpdate.deposit = currentOrder.currentDeposit
    orderUpdate.debit = orderUpdate.finalPrice - currentOrder.currentDeposit
  orderUpdate

calculateOrderDeposit= (currentOrder, orderOptionDefault)->
  switch currentOrder.paymentMethod
    when 0 then calculateDepositAndDebitByProduct(currentOrder, orderOptionDefault) #Tính theo từng sp
    when 1 then calculateDepositAndDebitByBill(currentOrder, orderOptionDefault) #Tính theo tổng bill

calculateDefaultOrder = (currentOrder, orderDetails)->
  orderUpdate =
    saleCount       :0
    discountCash    :0
    discountPercent :0
    totalPrice      :0

  for detail in orderDetails
    orderUpdate.totalPrice += detail.quality * detail.price
    orderUpdate.saleCount += detail.quality
    if currentOrder.billDiscount
      orderUpdate.discountCash = orderUpdate.discountCash
    else
      orderUpdate.discountCash += detail.discountCash
  orderUpdate.discountPercent = orderUpdate.discountCash/orderUpdate.totalPrice*100
  orderUpdate.finalPrice      = orderUpdate.totalPrice - orderUpdate.discountCash
  orderUpdate

updateOrderByOrderDetail = (currentOrder, orderDetails)->
  orderOptionDefault = calculateDefaultOrder(currentOrder, orderDetails)
  updateOrder = calculateOrderDeposit(currentOrder, orderOptionDefault)
  Order.update currentOrder._id, $set: updateOrder

updateOrderByOrderDetailEmpty = (currentOrder)->
  updateOrder =
    saleCount       : 0
    discountCash    : 0
    discountPercent : 0
    totalPrice      : 0
    finalPrice      : 0
    paymentMethod   : 0
    currentDeposit  : 0
    deposit         : 0
    debit           : 0

  Schema.orders.update currentOrder._id, $set: updateOrder

logics.sales.reCalculateOrder = (orderId) ->
  zone.run =>
    currentOrder = Order.findOne(orderId).data
    if currentOrder
      orderDetails = Schema.orderDetails.find({order: orderId}).fetch()
      if orderDetails.length > 0
        updateOrderByOrderDetail(currentOrder, orderDetails)
      else
        updateOrderByOrderDetailEmpty(currentOrder)





