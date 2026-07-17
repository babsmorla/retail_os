puts "👥 Creating users..."

users = [
  {
    email: "admin@retailos.com",
    full_name: "RetailOS Admin",
    password: "password123",
    role: :admin
  },
  {
    email: "cashier@retailos.com",
    full_name: "Main Shop Keeper",
    password: "password123",
    role: :shop_keeper
  },
  {
    email: "cashier2@retailos.com",
    full_name: "Second Shop Keeper",
    password: "password123",
    role: :shop_keeper
  },
  {
    email: "inventory@retailos.com",
    full_name: "Inventory Officer",
    password: "password123",
    role: :inventory_officer
  }
]


users.each do |data|
  User.find_or_create_by!(email: data[:email]) do |user|
    user.full_name = data[:full_name]
    user.password = data[:password]
    user.role = data[:role]
    user.active = true
  end
end


puts "✅ Users created"
