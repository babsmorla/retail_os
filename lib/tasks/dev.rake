namespace :dev do
  desc "Wipe sales history and regenerate test data"
  task reseed_history: :environment do
    puts "--- Wiping transaction data ---"
    
    # Corrected Model names per your schema
    AccountingEntry.destroy_all
    StockMovement.destroy_all
    Receipt.destroy_all
    SaleItem.destroy_all
    Sale.destroy_all
    StockAdjustment.destroy_all
    
    puts "--- Transactional data cleared. Running seeds ---"
    
    # Correct way to load seeds in a Rake task
    load(Rails.root.join('db', 'seeds.rb'))
    
    puts "--- Done! ---"
  end
end