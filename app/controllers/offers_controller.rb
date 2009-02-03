class OffersController < ApplicationController
  make_resource_controller do
    belongs_to :offer_provider, :product
    
    member_actions :edit_products, :update_products
    
    before :create do
      @offer.products << @product if @product
    end
 end
  
  def resourceful_name
    t(:offer, :scope => [ :marketplace ])
  end

  before_filter :login_required, :except => [ :index, :show ]
  before_filter :check_editor_of, :except => [ :index, :show ]
  before_filter :check_for_product, :only => [ :new, :create ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :start_date
      options[:headers] = [
        { :name => tp(:name), :sort => :name },
        { :name => tp(:date, :scope => [ :datetimes ]), :sort => :start_date },
        t(:offer, :scope => [ :marketplace ]),
        tp(:product, :scope => [ :marketplace ]),
        t(:offer_provider, :scope => [ :marketplace ])
      ]
      options[:search] = true
    
      if @product
        options[:include] = :products
        options[:conditions] = [ "products.id = ?", @product.id ]
      elsif @offer_provider
        options[:conditions] = [ "offer_provider_type = ? AND offer_provider_id = ?", @offer_provider.class.to_s, @offer_provider.id ]
      end
    end
  end
  
  def edit_products
    options = Indexer.parse_options(params)
    options[:row] = 'offers/product_row'
    options[:locals] = { :offer => @offer }
    options[:default_sort] = :name
    options[:headers] = [
      { :name => t(:name), :sort => :name, :order => 'products.name' },
      t(:sku, :scope => [ :marketplace ]),
      { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => { :model => { :make => :manufacturer } }, :order => 'manufacturers.name' },
      { :name => t(:make, :scope => [ :marketplace ]), :sort => :make, :include => { :model => :make }, :order => 'makes.name' },
      { :name => t(:model, :scope => [ :marketplace ]), :sort => :model, :include => :model, :order => 'models.name' },
      tp(:model, :scope => [ :marketplace ])
    ]

    case @offer.offer_provider
    when Manufacturer
      options[:include] = { :model => :make }
      options[:conditions] = [ "makes.manufacturers_id = ?", @offer.offer_provider.id ]
    when Vendor
      options[:include] = :prices
      options[:conditions] = ["prices.vendor_id = ?", @offer.offer_provider.id]
    end
    
    @indexer = Indexer.new(Product, options)
  end
  
  def update_products
    params[:offer] ||= {}
    params[:offer][:product_ids] ||= @offer.products.map { |product| product.id }
    params[:add_product_ids].split(",").each { |product_id| params[:offer][:product_ids] << product_id } if params[:add_product_ids]
    params[:remove_product_ids].split(",").each { |product_id| params[:offer][:product_ids].reject! { |product_id2| product_id2 == product_id.to_i } } if params[:remove_product_ids]
    params[:offer][:product_ids].uniq!
    
    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        flash[:notice] = t(:object_updated, :object => t(:offer, :scope => [ :marketplace ]))
        format.html { redirect_to(:action => 'edit_products') }
        format.xml  { head :ok }
      else
        flash[:error] = t(:object_not_updated, :object => t(:offer, :scope => [ :marketplace ]))
        format.html { redirect_to(:action => 'edit_products') }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  
  private
  
  def check_for_product
    check_condition(@product = Product.find(params[:for_product_id])) if params[:for_product_id]
  end
 
  def check_editor_of
    check_editor(@offer_provider || @offer)
  end
end
