class Cart
  attr_reader :items

  def self.build_from_hash hash
    items = if hash["cart"] then
              hash["cart"]["items"].map do |item_data|
                CartItem.new item_data["product_id"], item_data["quantity"]
              end
            else
              []
            end

    new items
  end

  def initialize items = []
    @items = items
  end

  def add_item product_id
    item = @items.find { |item| item.product_id == product_id }
    if item
      item.increment
    else
      @items << CartItem.new(product_id)
    end
  end

  def empty?
    @items.empty?
  end

  def count
    @items.length
  end

  def serialize
    items = @items.map do |item|
      {
          "product_id" => item.product_id,
          "quantity" => item.quantity,
          "seller" => item.seller
      }
    end

    {
        "items" => items
    }
  end

  def total_price
    @items.inject(0) { |sum, item| sum + item.total_price }
  end

  def clear(seller)
    if seller
      @items = @items.map { |seller_item |
        seller_item if seller.to_s != seller_item.seller.to_s
      }
      @items.compact!
    else
      @items.clear
    end
  end


  def by_sellers
    sellers = {}
    @items.each do |item|
      tmp = @items.map { |seller_item |
          if item.seller == seller_item.seller
              seller_item
          end
      }
      tmp.compact!
      sellers[item.seller] = tmp
    end
    sellers
  end

  def seller_items (seller)
    tmp = @items.map { |seller_item |
      seller_item if seller.to_s == seller_item.seller.to_s
    }
    tmp.compact
  end

end