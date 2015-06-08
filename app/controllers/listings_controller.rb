class ListingsController < ApplicationController

  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_filter :check_user, only: [:edit, :update, :destroy]

  before_action :get_current_user_reviews


  # GET /listings
  # GET /listings.json
  def index
    if(params[:category].blank?)
      @listings = Listing.order("created_at DESC").paginate(:page => params[:page], :per_page => 9)
    else
      @category_id = Category.find_by(name: params[:category]).id
      @listings = Listing.where(category_id: @category_id).order("created_at DESC").paginate(:page => params[:page], :per_page => 9)
    end
  end

  def seller
    @listings = Listing.where(user: current_user).order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
  end

  def search
    terms = params[:s].split(/ /)
    categories = []
    lists = []
    terms.each do |term|
      Category.where("name like '%#{term}%'").all.each do |cat|
        categories << cat.id
      end

      Listing.where("name like '%#{term}%' OR description like '%#{term}%'").all.each do |item|
        lists << item.id
      end
    end

    categories.uniq!
    lists.uniq!

    @listings = Listing.where("category_id in (#{categories.join(',')}) OR id in (#{lists.join(',')})").order("created_at DESC").paginate(:page => params[:page], :per_page => 9)

    render 'index'
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
    @reviews = Review.where(listing_id: @listing.id).order("created_at DESC")
    if @reviews.blank?
      @avg_rating = 0
    else
      @avg_rating = @reviews.average(:rating).round(2)
    end
    @review = Review.new
  end

  # GET /listings/new
  def new
    @listing = Listing.new
  end

  # GET /listings/1/edit
  def edit
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)
    @listing.user_id = current_user.id

    respond_to do |format|
      if @listing.save
        format.html { redirect_to @listing, notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:name, :category_id, :description, :price, :image)
    end

    def check_user
      if current_user != @listing.user
        redirect_to root_url, alert: "Sorry, this listing belongs to someone else"
      end
    end

  def get_current_user_reviews
    @user_reviews = []
    if user_signed_in?
      Review.where(user_id: current_user.id).all.each do |review|
        @user_reviews << review.listing_id
      end
    end
    @user_reviews
  end

end
