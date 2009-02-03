module Marketplace
  module ActsAsMarketer
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_marketer(*args)
        class_eval do
          has_many :quote_requests, :order => 'created_at DESC', :dependent => :destroy

          def has_requested_quote?(vendor, product)
            QuoteRequest.count(:conditions => { :user_id => self, :vendor_id => vendor, :product_id => product }) > 0
          end

          def is_consumer?
            return @is_consumer if defined?(@is_consumer)
            @is_consumer = !self.is_supplier?
          end

          def is_supplier?
            return @is_supplier if defined?(@is_supplier)
            @is_supplier = self.is_manufacturer? || self.is_manufacturer_representative? || self.is_vendor? || self.is_vendor_representative?
          end
  
          def membership_suppliers
            self.membered_manufacturers + self.membered_vendors
          end
  
          def moderated_suppliers
            self.moderated_manufacturers + self.moderated_vendors
          end
  
          def is_manufacturer?(with_company = false)
            return @is_manufacturer if defined?(@is_manufacturer) && defined?(@is_manufacturer[with_company])
            @is_manufacturer ||= {}
            @is_manufacturer[with_company] = self.is_member_of?(Group.find_by_name(Configuration.manufacturer_group_name), false) && (!with_company || self.moderated_manufacturer.any?)
          end
  
          def membered_manufacturers
            # FIXME - The following line is the correct implementation, but it fails for :group through models in current Rails
            #@membered_manufacturers ||= self.membered(Manufacturer)
            @membered_manufacturers ||= Manufacturer.all(:include => { :organization => { :group => :memberships } }, :conditions => { "#{Membership.table_name}.user_id" => self })
          end
  
          def moderated_manufacturers
            #@moderated_manufacturers ||= self.moderated(Manufacturer)
            @moderated_manufacturers ||= Manufacturer.all(:include => { :organization => { :group => :memberships } }, :conditions => { "#{Membership.table_name}.user_id" => self, "#{Membership.table_name}.role_id" => Role.administrator.id })
          end
  
          def is_manufacturer_representative?(with_company = false)
            return @is_manufacturer_representative[with_company] if defined?(@is_manufacturer_representative) &&  defined?(@is_manufacturer_representative[with_company])
            @is_manufacturer_representative ||= {}
            @is_manufacturer_representative[with_company] = self.is_member_of?(Group.find_by_name(Configuration.manufacturer_representative_group_name), true) && (!with_company || self.membered_manufacturers.any?)
          end
  
          def is_vendor?(with_company = false)
            return @is_vendor[with_company] if defined?(@is_vendor) && defined?(@is_vendor[with_company])
            @is_vendor ||= {}
            @is_vendor[with_company] = self.is_member_of?(Group.find_by_name(Configuration.vendor_group_name), false) && (!with_company || self.moderated_vendors.any?)
          end
  
          def membered_vendors
            #@membered_vendors ||= self.groups_of(Vendor)
            @membered_vendors ||= Vendor.all(:include => { :organization => { :group => :memberships } }, :conditions => { "#{Membership.table_name}.user_id" => self })
          end
  
          def moderated_vendors
            #@moderated_vendors ||= self.moderated_groups_of(Vendor)
            @moderated_vendors ||= Vendor.all(:include => { :organization => { :group => :memberships } }, :conditions => { "#{Membership.table_name}.user_id" => self, "#{Membership.table_name}.role_id" => Role.administrator.id })
          end
  
          def is_vendor_representative?(with_company = false)
            return @is_vendor_representative[with_company] if defined?(@is_vendor_representative) && defined?(@is_vendor_representative[with_company])
            @is_vendor_representative ||= {}
            @is_vendor_representative[with_company] = self.is_member_of?(Group.find_by_name(Configuration.vendor_representative_group_name), true) && (!with_company || self.membered_vendors.any?)
          end
          
          def identities_with_marketer
            identities_without_marketer + self.membership_suppliers.map { |supplier| supplier.organization.name }
          end
          alias_method_chain :identities, :marketer
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Marketplace::ActsAsMarketer) if defined?(ActiveRecord::Base)