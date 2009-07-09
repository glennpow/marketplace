class OrdersController < ApplicationController
  make_resource_controller(:actions => [ :index, :show ]) do
    before :new do
      @cart = current_cart
    end

    before :create do
      @order.cart = current_cart
    end
    
    before :show do
      @order_line_items_indexer = create_indexer(OrderLineItem) do |options|
        options[:default_sort] = :name
        options[:headers] = [
          # { :name => t(:product, :scope => [ :marketplace ]), :sort => :name, :include => :product, :order => "#{Product.table_name}.name" },
          t(:product, :scope => [ :marketplace ]),
          { :name => t(:quantity, :scope => [ :marketplace ]), :sort => :quantity, :order => "quantity" },
          { :name => t(:unit_price, :scope => [ :marketplace ]), :sort => :unit_price, :include => :price, :order => "#{Price.table_name}.amount" },
          { :name => t(:total_price, :scope => [ :marketplace ]), :sort => :total_price, :include => :price, :order => "#{Price.table_name}.amount * #{OrderLineItem.table_name}.quantity" }
        ]
      
        options[:conditions] = { :order_id => @order.id }
      end
    end
  end
  
  def resourceful_name
    t(:order, :scope => [ :marketplace ])
  end

  before_filter :check_logged_in, :only => [ :index ]
  before_filter :check_editor_of_order, :only => [ :show ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :created_at },
        { :name => t(:amount, :scope => [ :marketplace ]), :sort => :amount, :include => :transactions, :order => "#{OrderTransaction.table_name}.amount" },
        { :name => t(:status), :sort => :order_status }
      ]

      if has_administrator_role?
        options[:headers].unshift({ :name => t(:user, :scope => [ :authentication ]), :sort => :user, :include => :user, :order => "#{User.table_name}.name" })
      else
        options[:conditions] = { :user_id => current_user.id }
      end
    end
  end

  def current
    @order = current_order
    
    @order_line_items_indexer = create_indexer(OrderLineItem) do |options|
      options[:default_sort] = :name
      options[:headers] = [
        # { :name => t(:product, :scope => [ :marketplace ]), :sort => :name, :include => :product, :order => "#{Product.table_name}.name" },
        t(:product, :scope => [ :marketplace ]),
        { :name => t(:quantity, :scope => [ :marketplace ]), :sort => :quantity, :order => "quantity" },
        { :name => t(:unit_price, :scope => [ :marketplace ]), :sort => :unit_price, :include => :price, :order => "#{Price.table_name}.amount" },
        { :name => t(:total_price, :scope => [ :marketplace ]), :sort => :total_price, :include => :price, :order => "#{Price.table_name}.amount * #{OrderLineItem.table_name}.quantity" }
      ]

      options[:conditions] = { :order_id => @order.id }
    end

    respond_to do |format|
      format.html { render :action => 'show' }
      format.xml  { render :xml => @order }
    end
  end
  
  def checkout
    @order = current_order
    
    respond_to do |format|
      format.html # checkout.html.erb
      format.xml  { render :xml => @order }
    end
  end
  
  def purchase
    @order = current_order
    
    respond_to do |format|
      params[:order][:ip_address] = request.remote_ip
      if @order.update_attributes(params[:order]) && @order.purchase
        flash[:notice] = t(:purchased, :scope => [ :marketplace, :orders ])
        
        format.html { redirect_to(purchased_order_path(@order)) }
        format.xml  { head :ok }
      else
        flash[:error] = "<p class='error-heading'>#{t(:failed_processing, :scope => [ :marketplace, :orders ])}</p>" +
          @template.render_list(@order.errors.full_messages)

        format.html { render :action => 'checkout' }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def purchased
    @order = current_order
    
    respond_to do |format|
      format.html # purchased.html.erb
      format.xml  { render :xml => @order }
    end
  end
  
  def add_to_cart
    if current_order
      if @price = Price.find(params[:price_id])
        @item = current_order.create_line_item(:price => @price)
        flash[:notice] = t(:added_to_cart, :scope => [ :marketplace, :orders ])
      else
        # TODO - better messages...
        flash[:error] = t(:failed_processing, :scope => [ :marketplace, :orders ])
      end
    else
      flash[:error] = t(:failed_processing, :scope => [ :marketplace, :orders ])
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
 
  
  private
  
  def check_editor_of_order
    check_editor_of(@order, true)
  end
end
