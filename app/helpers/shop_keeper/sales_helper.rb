module ShopKeeper
  module SalesHelper
    def payment_badge_class(method)
      case method&.downcase
      when "cash" then "bg-emerald-50 text-emerald-600"
      when "card" then "bg-blue-50 text-blue-600"
      else "bg-purple-50 text-purple-600"
      end
    end
  end
end
