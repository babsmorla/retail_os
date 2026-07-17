# db/seeds.rb
puts "Cleaning..."
Membership.destroy_all
User.destroy_all
Store.destroy_all

puts "Creating foundation..."
store = Store.create!(name: "Main Branch", location: "Accra", active: true)
user = User.create!(
  email: "admin@retail.com", 
  full_name: "Admin User", 
  password: "password123", 
  role: 0
)

# CRITICAL: This is what your ApplicationController is looking for!
Membership.create!(user: user, store: store)

puts "Membership created. Store and User linked."