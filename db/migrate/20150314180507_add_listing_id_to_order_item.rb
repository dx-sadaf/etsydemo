class AddListingIdToOrderItem < ActiveRecord::Migration
  def change
    add_reference :order_items, :listing, index: true
  end
end
