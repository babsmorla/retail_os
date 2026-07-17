puts "📂 Creating categories..."


categories = [

  {
    name: "Electronics",
    description: "Electronic devices and gadgets",
    icon: "cpu",
    color: "#0052F6",
    category_type: "product"
  },

  {
    name: "Mobile Accessories",
    description: "Phone chargers, cables, cases and accessories",
    icon: "smartphone",
    color: "#10B981",
    category_type: "product"
  },

  {
    name: "Computer Accessories",
    description: "Computer peripherals and accessories",
    icon: "monitor",
    color: "#F59E0B",
    category_type: "product"
  },

  {
    name: "Printing Services",
    description: "Printing and document services",
    icon: "printer",
    color: "#EF4444",
    category_type: "service"
  },

  {
    name: "Stationery",
    description: "Office and school stationery",
    icon: "book",
    color: "#8B5CF6",
    category_type: "product"
  },

  {
    name: "Furniture",
    description: "Office and home furniture",
    icon: "chair",
    color: "#14B8A6",
    category_type: "product"
  },

  {
    name: "Networking",
    description: "Routers, cables and networking equipment",
    icon: "wifi",
    color: "#0EA5E9",
    category_type: "product"
  }

]


categories.each do |data|
  Category.find_or_create_by!(name: data[:name]) do |category|
    category.description = data[:description]
    category.icon = data[:icon]
    category.color = data[:color]
    category.category_type = data[:category_type]
    category.active = true
  end
end


puts "✅ Categories created"
