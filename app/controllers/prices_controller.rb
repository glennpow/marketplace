class PricesController < ApplicationController
  make_resource_controller do
    belongs_to :product, :vendor
    
    before :create do
      @price.product = @product
    end

    response_for :create do |format|
      format.html { redirect_to products_path }
      format.js
    end
  end
  
  def resourceful_name
    t(:price, :scope => [ :marketplace ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_for_product, :only => [ :new, :create ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = @product ? :amount : :product
      options[:headers] = [
        { :name => t(:product, :scope => [ :marketplace ]), :sort => :product, :include => :product, :order => 'products.name' },
        { :name => t(:price, :scope => [ :marketplace ]), :sort => :amount },
        t(:vendor, :scope => [ :marketplace ]),
        tp(:offer, :scope => [ :marketplace ])
      ]
    
      if @product
        options[:conditions] = [ "product_id = ?", @product.id ]
      elsif @vendor
        options[:conditions] = [ "vendor_id = ?", @vendor.id ]
      end
    end
  end
 
  
  private
  
  def check_for_product
    check_condition(params[:for_product_id] && @product = Product.find(params[:for_product_id]))
  end
  
  def check_editor_of
    check_editor(@vendor || @price)
  end
end
