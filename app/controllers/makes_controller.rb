class MakesController < ApplicationController
  make_resource_controller do
    belongs_to :manufacturer
    
    before :show do
      add_breadcrumb h(@make.manufacturer.name), @make.manufacturer
      add_breadcrumb h(@make.name)

      load_comments(@make)
      load_reviews(@make)
    end
    
    before :new do
      add_breadcrumb h(@manufacturer.name), @manufacturer
    end
    
    before :edit do
      add_breadcrumb h(@make.manufacturer.name), @make.manufacturer
      add_breadcrumb h(@make.name), @make
    end
  end
  
  def resourceful_name
    t(:make, :scope => [ :marketplace ])
  end

  before_filter :load_vendor, :only => [ :index ]
  before_filter :check_editor_of_manufacturer, :only => [ :new, :create ]
  before_filter :check_editor_of_make, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => :manufacturer, :order => 'manufacturers.name' },
        tp(:model, :scope => [ :marketplace ]),
        tp(:product, :scope => [ :marketplace ])
      ]
      options[:search] = true
      options[:include] = [ { :manufacturer => :organization }, :models, :products ]

      options[:conditions] = {}
      options[:include] = []
      if @vendor
        add_breadcrumb h(@vendor.name), @vendor
        
        options[:include] << { :products => :prices }
        options[:conditions]["#{Price.table_name}.vendor_id"] = @vendor
      end
      if @manufacturer
        add_breadcrumb h(@manufacturer.name), @manufacturer

        options[:conditions]["#{Make.table_name}.manufacturer_id"] = @manufacturer
      end
      unless has_administrator_role? || is_editor_of?(@manufacturer)
        options[:conditions]["#{Make.table_name}.production_status"] = ProductionStatus[:available]
      end
    end
  end
 
  
  private
    
  def load_vendor
    @vendor = params[:vendor_id] ? Vendor.find(params[:vendor_id]) : current_portal(Vendor)
  end

  def check_editor_of_manufacturer
    check_editor_of(@manufacturer)
  end
  
  def check_editor_of_make
    check_editor_of(@make)
  end
end
