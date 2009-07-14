module MarketplaceHelper
  def marketplace_header(options = {})
    stylesheet_link_tag_theme('layout/marketplace')
  end
  
  def offer_amount(offer)
    case offer.offer_type
    when OfferType[:discount_amount]
      render_currency(offer.amount)
    when OfferType[:discount_percent]
      number_to_percentage(offer.amount, :precision => 2)
    when OfferType[:refund_amount]
      render_currency(offer.amount)
    end
  end
  
  def offer_icon(vendor, product)
    offers = product.offers_with_offer_provider(vendor)
    offers.any? ?
      (offers.length == 1 ?
        icon_link_to(:offer, h(offers.first.name), offers.first) :
        icon_link_to(:offer, tp(:offer, :scope => [ :marketplace ]), product_offers_path(product))) :
      ""
  end

  def render_currency(number, options = {})
    # TODO - account for international currency conversions
    number_to_currency(number, options)
  end

  def render_price(product, vendor, options = {})
    price = Price.first(:conditions => { :product_id => product, :vendor_id => vendor })
    locals = {
      :vendor => vendor,
      :product => product,
      :price => (price.nil? ? 0 : price.rank)
    }
    render :partial => 'prices/show', :locals => locals
  end
  
  def render_weight(weight)
    # TODO
    "#{weight} lbs"
  end
  
  def render_technology_level(product_or_model, options = {})
    model = case product_or_model
    when Model
      product_or_model
    when Product
      product_or_model.model
    end
    locals = {
      :technology_level => model.technology_level
    }
    render :partial => 'products/technology_level', :locals => locals
  end
  
  def render_features(featurable, options = {})
    locals = {
      :feature_tree => featurable.feature_tree,
      :featurable => featurable,
      :options => options
    }
    render :partial => 'features/list', :locals => locals
  end

  def feature_select(form_builder, name, options = {}, html_options = {})
    featurable = form_builder.object
    features_attribute = Marketplace::HasManyFeatures::FeaturesAttribute.new(featurable)
    capture do
      form_builder.fields_for(name, features_attribute) do |f|
        locals = {
          :features => Feature.find_all_for_featurable(featurable),
          :f => f,
          :featurable => featurable,
          :features_attribute => features_attribute,
          :options => options,
          :html_options => html_options
        }
        render :partial => 'features/select', :locals => locals
      end
    end
  end

  def feature_search_select(name, options = {}, html_options = {})
    capture do
      fields_for(name) do |f|
        locals = {
          :features => options.delete(:features) || Feature.searchable_roots,
          :f => f,
          :options => options,
          :html_options => html_options,
          :root_tabs => defined?(options[:root_tabs]) ? options[:root_tabs] : true
        }
        render :partial => 'features/search_select', :locals => locals
      end
    end
  end
  
  def card_type_select(form_builder, name, options = {}, html_options = {})
    form_builder.select(name, [ [ 'Visa', 'visa' ], [ 'MasterCard', 'master' ], [ 'Discover', 'discover' ], [ 'American Express', 'american_express' ] ], options, html_options)
  end
end