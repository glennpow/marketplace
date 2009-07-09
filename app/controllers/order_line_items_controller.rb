class OrderLineItemsController < ApplicationController
  make_resource_controller(:actions => [ :index, :show, :create, :destroy ]) do
    belongs_to :order
    
    before :create do
      @cart_item.cart = @cart
    end

    response_for :create do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
  
  def resourceful_name
    t(:order_line_item, :scope => [ :marketplace ])
  end

  before_filter :check_for_order, :only => [ :index, :create ]
  before_filter :check_editor_of_order
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        # FIXME - again the woes of rails' half-assed associations
        # { :name => t(:product, :scope => [ :marketplace ]), :sort => :name, :include => :product, :order => "#{Product.table_name}.name" },
        t(:product, :scope => [ :marketplace ]),
        { :name => t(:quantity, :scope => [ :marketplace ]), :sort => :quantity, :order => "quantity" },
        { :name => t(:unit_price, :scope => [ :marketplace ]), :sort => :unit_price, :include => :price, :order => "#{Price.table_name}.amount" },
        { :name => t(:total_price, :scope => [ :marketplace ]), :sort => :total_price, :include => :price, :order => "#{Price.table_name}.amount * #{OrderLineItem.table_name}.quantity" }
      ]

      options[:conditions] = { :order_id => @order.id }
    end
  end
 
  
  private
  
  def check_for_order
    check_condition(@order)
  end
  
  def check_editor_of_order
    check_editor_of(@order || @order_line_item.order)
  end
end
