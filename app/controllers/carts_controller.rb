class CartsController < ApplicationController

  def add
    @cart.add_item params[:id]
    session["cart"] = @cart.serialize
    product = Listing.find params[:id]
    redirect_to :back, notice: "Added #{product.name} to cart."
  end

  def show
  end

  def checkout
    @order_form = OrderForm.new user: User.new
    @client_token = Braintree::ClientToken.generate
  end

  def clear
    @cart.clear(params[:user_id])
    session["cart"] = @cart.serialize
    if session[:checking_out]
      session[:checking_out] = false
      redirect_to thankyou_path
    else
      redirect_to root_url, notice: "Cart Cleared"
    end

  end
end