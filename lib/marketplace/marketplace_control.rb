module Marketplace
  def self.billing_gateway
    return @billing_gateway if defined?(@billing_gateway)
    @billing_gateway = if defined?(ActiveMerchant)
      ActiveMerchant::Billing::Base.mode = :test unless ENV['RAILS_ENV'] == 'production'
  
      if Configuration.billing_gateway.is_a?(Hash)
        if gateway_class = ActiveMerchant::Billing::Base.gateway(Configuration.billing_gateway[:type])
          unless ENV['RAILS_ENV'] == 'test'
            gateway_class.new(Configuration.billing_gateway[:params])
          else
            ActiveMerchant::Billing::BogusGateway.new
          end
        end
      end
    end
    @billing_gateway
  end

  module  MarketplaceControl
    def is_consumer?
      !logged_in? || current_user.is_consumer?
    end
    
    def is_supplier?
      logged_in? && current_user.is_supplier?
    end
  
    def is_manufacturer?
      logged_in? && current_user.is_manufacturer?
    end

    def current_manufacturer
      return @current_manufacturer if defined?(@current_manufacturer)
      @current_manufacturer = current_organizable(Manufacturer)
    end
  
    def membered_manufacturers
      logged_in? ? current_user.membered_manufacturers : []
    end
  
    def moderated_manufacturers
      logged_in? ? current_user.moderated_manufacturers : []
    end
  
    def is_manufacturer_representative?
      logged_in? && current_user.is_manufacturer_representative?
    end
  
    def is_vendor?
      logged_in? && current_user.is_vendor?
    end
  
    def current_vendor
      return @current_vendor if defined?(@current_vendor)
      @current_vendor = current_organizable(Vendor)
    end
  
    def membered_vendors
      logged_in? ? current_user.membered_vendors : []
    end
  
    def moderated_vendors
      logged_in? ? current_user.moderated_vendors : []
    end
  
    def is_vendor_representative?
      logged_in? && current_user.is_vendor_representative?
    end
    
    def current_order
      return @current_order if defined?(@current_order)
      @current_order = if Configuration.shopping_cart == false
        nil
      elsif session[:current_order_id].is_a?(Fixnum)
        Order.find(session[:current_order_id]) if Order.exists?(session[:current_order_id])
      elsif logged_in?
        Order.first(:conditions => { :user_id => current_user }, :order => 'created_at DESC')
      end
      if @current_order.nil? || @current_order.purchased?
        @current_order = Order.new(:user => current_user, :order_status => OrderStatus[:pending])
      end
      session[:current_order_id] = @current_order.id unless @current_order.nil?
      @current_order
    end
    
    alias_method :current_cart, :current_order

    def self.included(base)
      base.send :helper_method, :is_consumer?, :is_supplier?, :current_order,
        :is_manufacturer?, :current_manufacturer, :membered_manufacturers, :moderated_manufacturers, :is_manufacturer_representative?,
        :is_vendor?, :current_vendor, :membered_vendors, :moderated_vendors, :is_vendor_representative? if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Marketplace:: MarketplaceControl) if defined?(ActionController::Base)