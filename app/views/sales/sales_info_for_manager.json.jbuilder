json.total_price @sales.sum(:total_price)
json.total_paid @sales.sum(:total_paid)
json.sales @sales do |sale|
  json.id sale.id
  json.total_price sale.total_price
  json.total_paid sale.total_paid
  json.created_at sale.created_at.strftime("%Y-%m-%d %H:%M")

  json.buyer sale.buyer.name

  json.agent_user sale.agent_user&.name

  json.diller_user sale.diller_user&.name
end
