class OrdersController < ApplicationController

  before_action :set_order, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
  end

  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
  end

  # GET /orders/new
  def new
    @order = Order.new
    @seller = User.find(params[:user_id])
    @items = @cart.seller_items(params[:user_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @seller = User.find(params[:user_id])
    @items = @cart.seller_items(params[:user_id])

    total_amount = @items.inject(0) { |sum, item| sum + item.total_price }


    #@order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.seller_id = @seller.id

    if(params[:pay_using] == 'cc')

      Stripe.api_key = ENV["STRIPE_API_KEY"]
      token = params[:stripeToken]

      begin
        charge = Stripe::Charge.create(
            :amount => (total_amount * 100).floor,  # amount in cents
            :currency => "usd",
            :card => token
        )
        flash[:notice] = "Thanks for ordering!"
      rescue Stripe::CardError => e
        flash[:danger] = e.message
      end

    end

    if @order.save

      pp_hash = {}
      i=1
      @items.each do |item|
        # save order items

        OrderItem.new({order_id: @order.id, listing_id: item.product.id, quantity: item.quantity}).save!

        # create has to be used with paypal...
        pp_hash["amount_#{i}"] = item.product.price
        pp_hash["item_name_#{i}"] = item.product.name
        pp_hash["item_nunmber_#{i}"] = item.product.id
        pp_hash["quantity_#{i}"] = item.quantity
        i = i+1
      end

      session[:checking_out] = true

      if(params[:pay_using] == 'pp')
        redirect_to OrdersHelper.paypal_url(clear_cart_path(user_id: params[:user_id]), pp_hash )
        #render text: OrdersHelper.paypal_url(listings_url, pp_hash )
      else
        redirect_to clear_cart_path(user_id: params[:user_id]), notice: 'Order was successfully created.'
      end
    else
      render :new
    end

  end

  def thankyou

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
