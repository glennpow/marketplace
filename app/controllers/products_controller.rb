class ProductsController < ApplicationController
  make_resource_controller do
    belongs_to :model, :offer
    
    member_actions :watch
    
    before :new do
      if params[:duplicate_id]
        @duplicate = Product.find(params[:duplicate_id])
        @product.attributes=(@duplicate.attributes.except('id', 'created_at', 'updated_at', 'image_file_name', 'image_content_type', 'image_file_size', 'image_updated_at'))
        @duplicate.features_featurings.each do |featuring|
          @product.features_featurings << Featuring.new(:feature_id => featuring.feature_id)
          @product.features << Feature.find(featuring.feature_id)
        end
      end
    end
  end
  
  def resourceful_name
    t(:product, :scope => [ :marketplace ])
  end

  before_filter :login_required, :only => [ :watch ]
  before_filter :check_editor_of_model, :only => [ :new, :create ]
  before_filter :check_editor_of_product, :only => [ :edit, :update, :destroy ]
  
  def index
    if params[:user_id]
      respond_to do |format|
        format.html { redirect_to :action => :results, :user_id => params[:user_id] }
        format.xml  { redirect_to :format => :xml, :action => :results, :user_id => params[:user_id] }
      end
    else
      respond_with_indexer do |options|
        # FIXME - This won't work until eager loading of has_one_through associations work
        # options[:search_include] = [ :model ] # << :make << :manufacturer
        options[:default_sort] = :name
        options[:headers] = [
          { :name => t(:name), :sort => :name },
          t(:sku, :scope => [ :marketplace ]),
          { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => { :model => { :make => :manufacturer } }, :order => "#{Manufacturer.table_name}.name" },
          { :name => t(:make, :scope => [ :marketplace ]), :sort => :make, :include => { :model => :make }, :order => "#{Make.table_name}.name" },
          { :name => t(:model, :scope => [ :marketplace ]), :sort => :model, :include => :model, :order => "#{Model.table_name}.name" }
        ]
        options[:search] = true
        options[:include] = [ :model, { :make => { :manufacturer => :organization } }, :prices ]

        options[:conditions] = {}
        if @model
          options[:conditions]["#{Product.table_name}.model_id"] = @model
        elsif @offer
          options[:include] << :offers
          options[:conditions]["#{Offer.table_name}.id"] = @offer
        end
        
        unless has_administrator_role? || is_editor_of?(@model)
          options[:conditions]["#{Product.table_name}.production_status"] = ProductionStatus[:available]
        end
      end
    end
  end
  
  def search
    respond_to do |format|
      format.html # search.html.erb
      format.xml  { head :ok }
    end
  end
  
  def results
    respond_with_indexer do |options|
      options[:per_page] ||= 10
      options[:selectable] = true
      options[:row] = 'products/results_row'
    
      options[:conditions] = { "#{Product.table_name}.production_status" => ProductionStatus[:available] }
      options[:conditions]["#{Product.table_name}.model_id"] = params[:models].keys if params[:models]
      if params[:features]
        options[:include] = :features_featurings_with_include
        options[:conditions]["#{Featuring.table_name}.feature_id"] = params[:features].keys
      end
    end
  end
  
  def compare
    @products = params[:product].select { |product_id, selected| selected == '1' }.collect { |pair| Product.find_by_id(pair.first) }
    
    respond_to do |format|
      format.html # compare.html.erb
      format.xml  { render :xml => @products }
    end
  end
  
  
  private

  def check_editor_of_model
    check_editor_of(@model)
  end

  def check_editor_of_product
    check_editor_of(@product)
  end
end
