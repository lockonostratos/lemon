lemon.dependencies.add 'userInfo', ['myOption', 'myProfile', 'mySession']
lemon.dependencies.add 'essentials', ['userInfo', 'myPurchase']#, 'fake']

lemon.dependencies.add 'home', ['essentials']
lemon.dependencies.add 'merchantPurchase', ['essentials']

#lemon.dependencies.add 'merchantInfo', ['myMerchant', 'myWarehouse']
lemon.dependencies.add 'merchantEssential', ['essentials', 'myMetroSummaries', 'myMerchantAndWarehouse', 'myMerchantProfiles', 'currentMerchantRoles']
lemon.dependencies.add 'merchantMessenger', ['myMerchantUserProfiles', 'unreadMessages']
lemon.dependencies.add 'merchantNotification', ['unreadNotifications']
lemon.dependencies.add 'merchantEssentialOnce', ['merchantEssential', 'merchantNotification', 'merchantMessenger']

lemon.dependencies.add 'merchantHome', ['merchantEssential']
lemon.dependencies.add 'customerManagement', ['availableCustomers', 'availableCustomerAreas']
lemon.dependencies.add 'importManagement', ['myImportHistory', 'allProducts', 'skulls', 'providers', 'availableDistributors']
lemon.dependencies.add 'productManagement', ['availableProducts']
lemon.dependencies.add 'saleManagement', ['myOrderHistory', 'mySaleAndDetail', 'products', 'skulls', 'providers', 'availableCustomers']
lemon.dependencies.add 'distributorManagement', ['availableDistributors']
lemon.dependencies.add 'merchantReport', ['merchantReportData', 'availableBranch']

lemon.dependencies.add 'staffManagement', ['merchantEssential', 'myMerchantUserProfiles', 'currentMerchantRoles', 'availableBranch', 'allWarehouse']

lemon.dependencies.add 'providerManagement', ['merchantEssential', 'providers']
lemon.dependencies.add 'roleManager', ['merchantEssential']
lemon.dependencies.add 'staffManager', ['merchantEssential', 'myMerchantUserProfiles', 'currentMerchantRoles', 'availableBranch', 'allWarehouse']
lemon.dependencies.add 'customerManager', ['merchantEssential', 'availableCustomers', 'availableCustomerAreas']
lemon.dependencies.add 'transactionManager', ['merchantEssential', 'availableReceivable' ,'availableCustomers']

lemon.dependencies.add 'accountingManager', ['merchantEssential', 'saleBillAccounting']
lemon.dependencies.add 'billManager', ['merchantEssential', 'billManagerSales']
lemon.dependencies.add 'deliveryManager', ['merchantEssential', 'availableDeliveries']
lemon.dependencies.add 'returnManager', ['merchantEssential', 'availableSales']
lemon.dependencies.add 'salesReport', ['merchantEssential', 'saleBills']

lemon.dependencies.add 'branchManager', ['merchantEssential', 'availableBranch']
lemon.dependencies.add 'warehouseManager', ['merchantEssential', 'availableWarehouse']
lemon.dependencies.add 'stockManager', ['merchantEssential', 'allProducts']
lemon.dependencies.add 'importHistory', ['merchantEssential', 'importHistoryInWarehouse', 'availableBranch', 'allWarehouse']

lemon.dependencies.add 'inventoryHistory', ['merchantEssential', 'allInventory']
lemon.dependencies.add 'inventoryManager', ['merchantEssential', 'allInventoryAndDetail', 'availableBranch', 'allWarehouse']

lemon.dependencies.add 'transportHistory', ['merchantEssential', 'allInventoryAndDetail', 'availableBranch', 'allWarehouse']
