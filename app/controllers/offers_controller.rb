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

  before_filter :check_editor_of_offer_provider, :only => [ :index ]
  before_filter :check_editor_of_offer, :only => [ :show ]
  before_filter :check_for_product, :only => [ :new, :create ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :starts_on
      options[:headers] = [
        { :name => tp(:name), :sort => :name },
        { :name => tp(:date, :scope => [ :datetimes ]), :sort => :starts_on },
        t(:offer, :scope => [ :marketplace ]),
        tp(:product, :scope => [ :marketplace ]),
        t(:offer_provider, :scope => [ :marketplace ])
      ]
      options[:search] = true
    
      if @product
        options[:include] = :products
        options[:conditions] = [ "#{Product.table_name}.id = ?", @product.id ]
      elsif @offer_provider
        options[:conditions] = [ "offer_provider_type = ? AND offer_provider_id = ?", @offer_provider.class.to_s, @offer_provider.id ]
      end
    end
  end
  
  def edit_products
    respond_with_indexer(Product) do |options|
      options[:row] = 'offers/product_row'
      options[:locals] = { :offer => @offer }
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name, :order => "#{Product.table_name}.name" },
        t(:sku, :scope => [ :marketplace ]),
        { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => { :model => { :make => :manufacturer } }, :order => "#{Manufacturer.table_name}.name" },
        { :name => t(:make, :scope => [ :marketplace ]), :sort => :make, :include => { :model => :make }, :order => "#{Make.table_name}.name" },
        { :name => t(:model, :scope => [ :marketplace ]), :sort => :model, :include => :model, :order => "#{Model.table_name}.name" },
        tp(:model, :scope => [ :marketplace ])
      ]

      case @offer.offer_provider
      when Manufacturer
        options[:include] = { :model => :make }
        options[:conditions] = [ "#{Make.table_name}.manufacturers_id = ?", @offer.offer_provider.id ]
      when Vendor
        options[:include] = :prices
        options[:conditions] = ["#{Price.table_name}.vendor_id = ?", @offer.offer_provider.id]
      end
    end
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
 
  def check_editor_of_offer_provider
    check_editor_of(@offer_provider)
  end
 
  def check_editor_of_offer
    check_editor_of(@offer)
  end
  
  def check_for_product
    check_condition(@product = Product.find(params[:for_product_id])) if params[:for_product_id]
  end
end
