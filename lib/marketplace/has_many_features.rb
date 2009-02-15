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
          has_many "#{features_name}_featurings", :class_name => 'Featuring', :as => :featurable, :dependent => :destroy
          has_many features_name, { :class_name => 'Feature', :through => "#{features_name}_featurings", :source => :feature }.merge(order_options)
          
          write_inheritable_attribute(:features_attribute_name, features_name)
        end
        
        if options[:include]
          define_method "#{features_name}_featurings_with_include" do
            self.send("#{features_name}_featurings_without_include") + [ options[:include] ].flatten.map do |include_name|
              included = self.send(include_name)
              included.nil? ? nil : included.send("#{included.class.read_inheritable_attribute(:features_attribute_name)}_featurings")
            end.flatten.compact
          end

          define_method "#{features_name}_with_include" do
            (self.send("#{features_name}_without_include") + [ options[:include] ].flatten.map do |include_name|
              included = self.send(include_name)
              included.nil? ? nil : included.send(included.class.read_inheritable_attribute(:features_attribute_name))
            end.flatten.compact).uniq
          end
        else
          define_method "#{features_name}_featurings_with_include" do
            self.send("#{features_name}_featurings_without_include")
          end

          define_method "#{features_name}_with_include" do
            self.send("#{features_name}_without_include")
          end
        end
          
        class_eval do
          alias_method_chain "#{features_name}_featurings", :include
          alias_method_chain features_name, :include
        end
  
        define_method "#{feature_name}_for_type" do |feature_type|
          self.send(features_name, :conditions => { :feature_type_id => feature_type })
        end
  
        define_method "has_#{feature_name}_type" do |feature_type|
          !self.send("#{feature_name}_for_type", feature_type).nil?
        end
        
        define_method :attributes= do |attributes|
          if features = attributes.delete(features_name)
            feature_ids = features.values
            destroyed = []
            featurings = self.send("#{features_name}_featurings_without_include")
            featurings.each do |featuring|
              destroyed << featuring if feature_ids.delete(featuring.feature_id).nil?
            end
            destroyed.each do |featuring|
              featurings.delete(featuring)
            end
            feature_ids.each do |feature_id|
              featurings << Featuring.new(:feature_id => feature_id) unless feature_id.to_i.zero?
            end
          end
          super(attributes)
        end
      end
    end
    
    class FeaturesAttribute
      def initialize(featurable = nil)
        @feature_ids = {}
        @included_feature_ids = {}
        if featurable
          features_attribute_name = featurable.class.read_inheritable_attribute(:features_attribute_name)
          featurings = featurable.send("#{features_attribute_name}_featurings", :include => [ :feature, :featurable ])
          featurings.each do |featuring|
            @feature_ids[featuring.feature.feature_type_id.to_s] = featuring.feature_id
          end
          included_featurings = featurings - featurable.send("#{features_attribute_name}_featurings_without_include", :include => :feature)
          included_featurings.each do |featuring|
            @included_feature_ids[featuring.feature.feature_type_id.to_s] = { :feature_id => featuring.feature_id, :featurable => featuring.featurable }
          end
        end
      end
      
      def included_for_type(feature_type)
        feature_type_id = case feature_type
        when String, Fixnum
          feature_type.to_i
        else
          feature_type.id
        end
        @included_feature_ids[feature_type_id.to_s]
      end
    
      def method_missing(method, *args)
        @feature_ids[method.to_s] || 0
      end
    end
  end
end

ActiveRecord::Base.send(:include, Marketplace::HasManyFeatures) if defined?(ActiveRecord::Base)