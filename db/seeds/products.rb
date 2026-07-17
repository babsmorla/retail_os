puts "📦 Creating products..."


def create_product(category_name, data)
  category = Category.find_by!(name: category_name)

  Product.find_or_create_by!(sku: data[:sku]) do |product|
    product.name = data[:name]
    product.category = category
    product.unit_price = data[:unit_price]
    product.cost_price = data[:cost_price]
    product.quantity_on_hand = data[:quantity]
    product.reorder_level = data[:reorder_level]
  end
end



products = [

  [
    "Mobile Accessories",
    {
      name: "Samsung Charger",
      sku: "MOB-001",
      unit_price: 80,
      cost_price: 55,
      quantity: 25,
      reorder_level: 5
    }
  ],

  [
    "Mobile Accessories",
    {
      name: "USB Type C Cable",
      sku: "MOB-002",
      unit_price: 40,
      cost_price: 20,
      quantity: 50,
      reorder_level: 10
    }
  ],


  [
    "Computer Accessories",
    {
      name: "Wireless Mouse",
      sku: "COM-001",
      unit_price: 150,
      cost_price: 100,
      quantity: 15,
      reorder_level: 5
    }
  ],


  [
    "Computer Accessories",
    {
      name: "Keyboard",
      sku: "COM-002",
      unit_price: 220,
      cost_price: 160,
      quantity: 8,
      reorder_level: 5
    }
  ],


  [
    "Networking",
    {
      name: "TP-Link Router",
      sku: "NET-001",
      unit_price: 350,
      cost_price: 280,
      quantity: 12,
      reorder_level: 3
    }
  ],


  [
    "Stationery",
    {
      name: "A4 Paper Pack",
      sku: "STA-001",
      unit_price: 70,
      cost_price: 50,
      quantity: 100,
      reorder_level: 20
    }
  ],


  [
    "Printing Services",
    {
      name: "Black and White Printing",
      sku: "PRINT-001",
      unit_price: 2,
      cost_price: 0.5,
      quantity: 9999,
      reorder_level: 0
    }
  ],


  [
    "Printing Services",
    {
      name: "Colour Printing",
      sku: "PRINT-002",
      unit_price: 5,
      cost_price: 2,
      quantity: 9999,
      reorder_level: 0
    }
  ]

]


products.each do |category, product|
  create_product(category, product)
end


puts "✅ Products created"
