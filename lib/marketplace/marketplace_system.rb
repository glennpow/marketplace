module Marketplace
  module MarketplaceSystem
    def is_consumer?
      !logged_in? || current_user.is_consumer?
    end
    
    def is_supplier?
      logged_in? && current_user.is_supplier?
    end
  
    def is_manufacturer?(with_company = false)
      logged_in? && current_user.is_manufacturer?(with_company)
    end

    def current_manufacturer
      return current_organization_of(Manufacturer)
    end
  
    def membered_manufacturers
      logged_in? ? current_user.membered_manufacturers : []
    end
  
    def moderated_manufacturers
      logged_in? ? current_user.moderated_manufacturers : []
    end
  
    def is_manufacturer_representative?(with_company = false)
      logged_in? && current_user.is_manufacturer_representative?(with_company)
    end
  
    def is_vendor?(with_company = false)
      logged_in? && current_user.is_vendor?(with_company)
    end
  
    def current_vendor
      return current_organization_of(Vendor)
    end
  
    def membered_vendors
      logged_in? ? current_user.membered_vendors : []
    end
  
    def moderated_vendors
      logged_in? ? current_user.moderated_vendors : []
    end
  
    def is_vendor_representative?(with_company = false)
      logged_in? && current_user.is_vendor_representative?(with_company)
    end

    def self.included(base)
      base.send :helper_method, :is_consumer?, :is_supplier?,
        :is_manufacturer?, :current_manufacturer, :membered_manufacturers, :moderated_manufacturers, :is_manufacturer_representative?,
        :is_vendor?, :current_vendor, :membered_vendors, :moderated_vendors, :is_vendor_representative? if base.respond_to? :helper_method
    end
  end
end

ActionController::Base.send(:include, Marketplace::MarketplaceSystem) if defined?(ActionController::Base)