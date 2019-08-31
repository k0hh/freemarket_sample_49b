class ProductsController < ApplicationController

  before_action :authenticate_user!,only: :new
  
  def index
    parent_ids = @parent.pluck(:id)

    child_ids = []
    @parent.each { |parent| child_ids.concat(parent.children.pluck(:id))}

    all_products = Product.includes(category:{parent: :parent}).where.not(category_id: parent_ids + child_ids).order("created_at desc")

    @new_products = parent_ids.map { |parent_id| get_four_new_items(all_products,parent_id) }
  end


  def create
    @product = Product.create(product_params)
  end


  def edit
    @product = Product.find(params[:id])
    @images = @product.images if @product.images.attached?
    @children_categories = @product.category.parent.parent.children
    @grandchildren_categories = @product.category.parent.children

    redirect_to (root_path) unless @product.user_id == current_user.id
  end  


  def update
    product = Product.find(params[:id])
    product.update(product_params) if product.user_id == current_user.id
    redirect_to detail_user_path(product)
  end


  def show
    @product = Product.find(params[:id])
  end


  def new
    @product = Product.new
    @children = []
    @grand_children = []

    respond_to do |format|
      format.html
      format.json do
        if params[:parent_id]
          Category.find(params[:parent_id]).children.each do |child|
            @children << child
          end
        else
          Category.find(params[:child_id]).children.each do |child|
            @grand_children << child
          end
        end
      end
    end
  end


  def buy_confirmation
    @product = Product.find(params[:id])
    @user = User.find(current_user.id)

    redirect_to (root_path) if @product.user_id == current_user.id

# if カードがあれば
  if current_user.card

#カードがなければ
  else
    redirect_to new_card_path
  end

  end

  def search
    @products = Product.where('name LIKE(?)', "%#{params[:keyword]}%").order("created_at desc").limit(24)
  end
  
  private
  
  def product_params
    params.require(:product).permit(:name, :description, :category_id, :size, :state, :postage, :prefecture_id, :shipping_date, :price, images:[]).merge(user_id: current_user.id)
  end

  def get_four_new_items(all_products, parent_id)
    all_products.select { |product| product.category.parent.parent.id == parent_id }.slice(0,4)
  end
end

