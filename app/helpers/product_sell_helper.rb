module ProductSellHelper
  def calculate_sale_price_in_usd(rate, product_sell)
    if product_sell.price_in_usd
      number_to_currency(product_sell.sell_price * product_sell.amount)
    else
      number_to_currency((product_sell.sell_price / rate) * product_sell.amount)
    end
  end

  def amount_in_string(pack_name, amount, amount_per_pack = nil)
    ProductSells::CalculateAmountPerPack.run(
      pack_name: pack_name,
      amount: amount,
      amount_per_pack: amount_per_pack
    ).result
  end

  def calculate_sale_price_in_uzs(rate, product_sell)
    final_price = nil
    if product_sell.price_in_usd
      final_price = product_sell.sell_price * rate * product_sell.amount
    else
      final_price = product_sell.sell_price * product_sell.amount
    end

    final_price = ProductSells::RoundPrice.run(number: final_price).result
    number_to_currency(final_price, unit: '')
  end

  def show_rounded_total_price(price)
    price = ProductSells::RoundPrice.run(number: price).result
    number_to_currency(price, unit: '')
  end
end