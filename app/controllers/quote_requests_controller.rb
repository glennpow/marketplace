class QuoteRequestsController < ApplicationController
  make_resource_controller(:actions => [ :index, :show, :new, :create, :destroy ]) do
    belongs_to :user, :vendor
      
    before :new do
      @quote_request.vendor = @vendor
      @quote_request.product = Product.find(params[:product_id]) if @quote_request.product.nil?
      @quote_request.user = current_user
    end

    response_for :create do |format|
      format.html { redirect_to user_quote_requests_path(current_user) }
      format.js
    end
  end
  
  def resourceful_name
    t(:quote_request, :scope => [ :marketplace ])
  end

  before_filter :check_logged_in, :only => [ :show, :new, :create, :destroy ]
  before_filter :check_owner_of, :only => [ :show, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :created_at
      options[:headers] = [
        { :name => t(:date, :scope => [ :datetimes ]), :sort => :created_at },
        t(:product, :scope => [ :marketplace ]),
        t(:vendor, :scope => [ :marketplace ]),
      ]
    
      if @user
        add_breadcrumb h(@user.name), @user

        options[:conditions] = ['user_id = ?', @user.id]
      elsif @vendor
        add_breadcrumb h(@vendor.name), @vendor

        options[:conditions] = ['vendor_id = ?', @vendor.id]
      end
    end
  end

  
  private
  
  def check_owner_of
    check_condition(is_editor_of?(@quote_request) || is_member_of?(@quote_request.vendor))
  end
end
