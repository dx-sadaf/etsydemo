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
    @listing = Listing.find(params[:listing_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])

    @seller = @listing.user

    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.seller_id = @seller.id

    if(params[:pay_using] == 'cc')

      Stripe.api_key = ENV["STRIPE_API_KEY"]
      token = params[:stripeToken]

      begin
        charge = Stripe::Charge.create(
            :amount => (@listing.price * 100).floor,  # amount in cents
            :currency => "usd",
            :card => token
        )
        flash[:notice] = "Thanks for ordering!"
      rescue Stripe::CardError => e
        flash[:danger] = e.message
      end

    end

    if @order.save
      if(params[:pay_using] == 'pp')
        redirect_to OrdersHelper.paypal_url(listings_url, {"amount_1" => @listing.price,"item_name_1" => @listing.name,"item_number_1" => @listing.id,"quantity_1" => '1'} )
        #render text: OrdersHelper.paypal_url(listings_url, {"amount_1" => @listing.price,"item_name_1" => @listing.name,"item_number_1" => @listing.id,"quantity_1" => '1'} )
      else
        redirect_to @listing, notice: 'Order was successfully created.'
      end
    else
      render :new
    end

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
