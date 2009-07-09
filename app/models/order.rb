class Order < ActiveRecord::Base
  belongs_to :user
  acts_as_contactable :address => :billing_address, :emails => false, :phones => false, :urls => false
  acts_as_contactable :address => :shipping_address, :emails => false, :phones => :shipping_phones, :urls => false
  has_many :line_items, :class_name => 'OrderLineItem', :dependent => :destroy
  # FIXME - :(
  #has_many :products, :through => :line_items
  has_many :transactions, :class_name => 'OrderTransaction'
  has_enumeration :order_status
  
  attr_accessor :card_number, :card_verification, :ip_address
  
  def products
    line_items.map(&:product).uniq
  end
  
  def product_quantity(product)
    line_items.all(:include => :price, :conditions => { "#{Price.table_name}.product_id" => product }).inject(0) { |product_quantity, order_line_item| product_quantity + order_line_item.quantity }
  end
  
  def include_product?(product)
    line_items.count(:include => :price, :conditions => { "#{Price.table_name}.product_id" => product }) > 0
  end
  
  def empty_products?
    line_items.empty?
  end
  
  def create_line_item(options = {})
    saved = self.save if self.new_record?
    self.line_items.create(options)
  end
  
  def total_price
    line_items.inject(0) { |total_price, order_line_item| total_price + order_line_item.total_price }
  end
  
  def total_price_in_cents
    (total_price * 100).round
  end
  
  def total_weight
    line_items.inject(0) { |total_weight, order_line_item| total_weight + order_line_item.total_weight }
  end
  
  def working_billing_address
    @working_billing_address ||= billing_address.nil? ? (user.nil? ? nil : user.address) : billing_address
  end
    
  def working_shipping_name
    @working_shipping_name ||= shipping_name.blank? ? (user.nil? || user.persona.nil? ? nil : user.persona.full_name) : shipping_name
  end

  def working_shipping_address
    @working_shipping_address ||= shipping_address.nil? ? working_billing_address : shipping_address
  end
  
  def purchase
    unless purchased?
      unless empty_products?
        if Marketplace.billing_gateway
          validate_billing_address
          validate_credit_card
          unless credit_card.errors.any?
            response = Marketplace.billing_gateway.purchase(total_price_in_cents, credit_card, purchase_options)
            transactions.create!(:action => OrderAction[:purchase], :amount => total_price_in_cents, :response => response)
            self.update_attribute(:status, OrderStatus[:purchased]) if response.success?
            return response.success?
          else
            errors.add_to_base I18n.t(:invalid_credit_card, :scope => [ :marketplace, :orders ])
          end
        else
          errors.add_to_base I18n.t(:error_processing, :scope => [ :marketplace, :orders ])
          logger.warn("Order purchase requested without valid gateway (#{Configuration.billing_gateway[:type]})!")
        end
      else
        errors.add_to_base I18n.t(:empty_order, :scope => [ :marketplace, :orders ])
      end
    else
      errors.add_to_base I18n.t(:order_already_purchased, :scope => [ :marketplace, :orders ])
    end
    return false
  end
  
  def purchased?
    order_status.position >= OrderStatus[:purchased].position
  end
  
  def purchased_at
    transactions.first(:conditions => { :order_action => OrderAction[:purchase] }).try(:created_at)
  end
  
  def ship
    # TODO
  end
  
  def shipped?
    order_status.position >= OrderStatus[:shipped].position
  end
  
  def shipped_at
    line_items.first(:conditions => { :order_action => OrderAction[:ship] }).try(:created_at)
  end
  
  def deliver
    # TODO
  end
  
  def delivered?
    order_status.position >= OrderStatus[:delivered].position
  end
  
  def delivered_at
    line_items.first(:conditions => { :order_action => OrderAction[:deliver] }).try(:created_at)
  end
  
  
  private
  
  def purchase_options
    case Configuration.billing_gateway[:type]
    when :paypal
      {
        :ip => ip_address,
        :billing_address => {
          :name => "#{card_first_name} #{card_last_name}",
          :address1 => working_billing_address.street_1,
          :city => working_billing_address.city,
          :state => working_billing_address.region.name,
          :country => working_billing_address.country.name,
          :zip => working_billing_address.postal_code
        }
      }
    else
      errors.add_to_base I18n.t(:error_processing, :scope => [ :marketplace, :orders ])
      logger.warn("Order purchase requested without valid gateway (#{Configuration.billing_gateway[:type]})!")
    end
  end
  
  def validate_billing_address
    if working_billing_address.nil?
      errors.add_to_base I18n.t(:invalid_billing_address, :scope => [ :marketplace, :orders ])
    # elsif !billing_address.valid?
    end
  end
  
  def validate_credit_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end
  
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type => card_type,
      :number => card_number,
      :verification_value => card_verification,
      :month => card_expires_on.month,
      :year => card_expires_on.year,
      :first_name => card_first_name,
      :last_name => card_last_name
    )
  end
end