$(document).ready hideBuyInfo
$(document).on "dimensionChanged", hideBuyInfo

$(document).on "skuSelected", (evt, sku) ->
	window.FireSkuChangeImage?(sku.sku)
	#window.FireSkuDataReceived?(sku.sku)
	window.FireSkuSelectionChanged?(sku.sku)