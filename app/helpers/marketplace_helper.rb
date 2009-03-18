module MarketplaceHelper
  def marketplace_header(options = {})
    stylesheet_link_tag('marketplace', :plugin => 'marketplace')
  end

  def feature_item(feature, options = {})
    returning('') do |content|
      if options[:type]
        content << content_tag(:span, feature.feature_type.name, :class => 'label')
        content << " : "
      end
      content << content_tag(:span, feature.name, :class => 'value')
      content << " "
      content << link_to_function("", "hint_window('feature_type', '#{summary_feature_type_path(feature.feature_type, :feature_id => feature.id, :anchor => feature.name.underscore)}', 400, 500);", :title => t(:more_info, :scope => [ :site_content ]), :class => 'hint-mark')
    end
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
  
  def feature_select(form_builder, name, options = {}, html_options = {})
    featurable = form_builder.object
logger.info("featurable.ings=#{featurable.features_featurings.inspect}")
    features_attribute = Marketplace::HasManyFeatures::FeaturesAttribute.new(featurable)
logger.info("featurable.ings2=#{featurable.features_featurings.inspect}")
logger.info("feature ids=#{features_attribute.feature_ids.inspect}")
logger.info("included feature ids=#{features_attribute.included_feature_ids.inspect}")
    capture do
      form_builder.fields_for(name, features_attribute) do |f|
        locals = {
          :feature_types => FeatureType.find_all_for_featurable(featurable),
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
end