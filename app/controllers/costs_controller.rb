class CostsController < ApplicationController
  make_resource_controller do
    belongs_to :product, :manufacturer

    response_for :create do |format|
      format.html { redirect_to costs_path }
      format.js
    end

    response_for :update do |format|
      format.html { redirect_to costs_path }
      format.js
    end
  end
  
  def resourceful_name
    t(:cost, :scope => [ :marketplace ])
  end

  before_filter :check_editor_of_indexed, :only => [ :index ]
  before_filter :check_editor_of_product, :only => [ :new, :create ]
  before_filter :check_editor_of_cost, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :product
      options[:headers] = [
        { :name => t(:product, :scope => [ :marketplace ]), :sort => :product, :include => :product, :order => "#{Product.table_name}.name" },
        { :name => t(:country, :scope => [ :contacts, :addresses ]), :sort => :country, :include => :country, :order => "#{Country.table_name}.name" },
        { :name => t(:amount, :scope => [ :marketplace ]), :sort => :amount }
      ]

      if @product
        options[:conditions] = [ "product_id = ?", @product.id ]
      elsif @manufacturer
        options[:include] = { :product => { :model => { :make => :manufacturer } } }
        options[:conditions] = [ "#{Manufacturer.table_name}.id = ?", @manufacturer.id ]
      end
    end
  end
  
  
  private

  def check_editor_of_indexed
    check_administrator_role || check_editor_of(@manufacturer || @product)
  end

  def check_editor_of_product
    check_editor_of(@product)
  end

  def check_editor_of_cost
    check_editor_of(@cost)
  end
end
