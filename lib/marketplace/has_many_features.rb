module Marketplace
  module HasManyFeatures
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def has_many_features(*args)
        options = args.extract_options!
        features_name = args.first || :features
        feature_name = features_name.to_s.singularize
        order_options = { :include => options[:order_by_type] ? :feature_type : [],
          :order => options[:order_by_type] ? "#{FeatureType.table_name}.name ASC, #{Feature.table_name}.name ASC" : "#{Feature.table_name}.name ASC" }
      
        class_eval do
          has_many :featurings, :as => :featurable, :dependent => :destroy
          has_many features_name, { :class_name => 'Feature', :through => :featurings, :source => :feature }.merge(order_options)
        end
        
        if options[:include]
          define_method "#{features_name}_with_include" do
            conditions_string = "(#{Featuring.table_name}.featurable_type = ? && #{Featuring.table_name}.featurable_id = ?)"
            conditions_array = [ self.class.to_s, self.id ]
            [ options[:include] ].flatten.each do |include_name|
              conditions_string << " OR (#{Featuring.table_name}.featurable_type = ? && #{Featuring.table_name}.featurable_id = ?)"
              included = self.send(include_name)
              conditions_array += [ included.class.to_s, included.id ]
            end
            Feature.all(:include => [ :featurings ] + order_options[:include], :order => order_options[:order],
              :conditions => conditions_array.unshift(conditions_string))
          end
          
          class_eval do
            alias_method_chain features_name, :include
          end
        end
        
        define_method "#{feature_name}_ids" do
          Feature.all(:include => [ :featurings ] + order_options[:include], :order => order_options[:order], :select => 'id',
            :conditions => [ "(#{Featuring.table_name}.featurable_type = ? && #{Featuring.table_name}.featurable_id = ?)",
              self.class.to_s, self.id ]).map(&:id)
        end
  
        define_method "#{feature_name}_for_type" do |feature_type|
          self.features.detect { |feature| feature.feature_type_id == (feature_type.is_a?(Fixnum) ? feature_type : feature_type.id) }
        end
  
        define_method "has_#{feature_name}_type" do |feature_type|
          !self.feature_for_type(feature_type.is_a?(Fixnum) ? feature_type : feature_type.id).nil?
        end
        
        define_method :attributes= do |attributes|
          attributes = attributes.deep_symbolize_keys
          if feature_ids = attributes.delete(:feature_ids)
            destroyed = []
            self.featurings.each do |featuring|
              destroyed << featuring if feature_ids.delete(featuring.feature_id).nil?
            end
            destroyed.each do |featuring|
              self.featurings.delete(featuring)
            end
            feature_ids.each do |feature_id|
              self.featurings << Featuring.new(:feature_id => feature_id)
            end
          end
          super(attributes)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Marketplace::HasManyFeatures) if defined?(ActiveRecord::Base)