module Dashboard

class ShopKeeperDashboard


def initialize(user)
 @user=user
end


def today_sales

 @user.sales
 .where(
 created_at: Date.today.all_day
 )
 .sum(:grand_total)

end


def transactions

 @user.sales
 .where(
 created_at: Date.today.all_day
 )
 .count

end


end

end