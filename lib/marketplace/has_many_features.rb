module Marketplace
  module HasManyFeatures
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def has_many_features(*args)
        options = args.extract_options!
        features_name = args.first || "features"
        feature_name = features_name.to_s.singularize
        order_options = { :include => options[:order_by_type] ? :feature_type : [],
          :order => options[:order_by_type] ? "#{FeatureType.table_name}.name ASC, #{Feature.table_name}.name ASC" : "#{Feature.table_name}.name ASC" }
      
        if options[:include]
          class_eval do
            has_many "#{features_name}_featurings".intern, :class_name => 'Featuring', :as => :featurable, :dependent => :destroy
            has_many features_name.intern, { :class_name => 'Feature', :through => "#{features_name}_featurings".intern, :source => :feature }.merge(order_options)

            includes = [ options[:include] ].flatten
            self_class_name = self.to_s
            self_attribute_name = self_class_name.underscore
            self_table_name = self.table_name
            finder_joins = ""
            finder_where = "(#{Featuring.table_name}.featurable_type = '#{self_class_name}' AND #{Featuring.table_name}.featurable_id = " + '#{id})'
            includes.each do |included|
              included_reflection = self.reflect_on_association(included)
              included_class_name = included_reflection.class_name
              included_table_name = included_reflection.klass.table_name
              if included_reflection.belongs_to?
                included_foreign_key = included_reflection.options[:foreign_key] || "#{included}_id"
                finder_joins += " LEFT JOIN #{included_table_name} ON #{included_table_name}.id = " + '#{' + included_foreign_key + '}'
              else
                included_foreign_key = included_reflection.options[:foreign_key] || "#{self_attribute_name}_id"
                finder_joins += " LEFT JOIN #{included_table_name} ON #{included_table_name}.#{included_foreign_key} = " + '#{id}'
              end
              finder_where += " OR (#{Featuring.table_name}.featurable_type = '#{included_class_name}' AND #{Featuring.table_name}.featurable_id = #{included_table_name}.id)"
            end
            finder_sql = "SELECT #{Featuring.table_name}.* FROM #{Featuring.table_name} #{finder_joins} WHERE #{finder_where}"
            
            has_many "#{features_name}_featurings_with_include".intern, :class_name => 'Featuring', :as => :featurable,
              :include => includes, :finder_sql => finder_sql
            has_many "#{features_name}_with_include".intern, { :class_name => 'Feature', :through => "#{features_name}_featurings_with_include".intern, :source => :feature }.merge(order_options)
          end
        else
          class_eval do
            has_many "#{features_name}_featurings".intern, :class_name => 'Featuring', :as => :featurable, :dependent => :destroy
            has_many features_name.intern, { :class_name => 'Feature', :through => "#{features_name}_featurings".intern, :source => :feature }.merge(order_options)
          end
        end
  
        define_method "#{feature_name}_for_type" do |feature_type|
          self.send(features_name).detect { |feature| feature.feature_type_id == feature_type.id }
        end
  
        define_method "has_#{feature_name}_type?" do |feature_type|
          !self.send("#{feature_name}_for_type", feature_type).nil?
        end
  
        define_method "valid_#{feature_name}_types" do
          FeatureType.find_all_for_featurable(self)
        end
  
        define_method "valid_#{feature_name}_types?" do
          FeatureType.count_for_featurable(self) > 0
        end
        
        define_method :attributes= do |attributes|
          if features = attributes.delete(features_name)
            feature_ids = features.values
            destroyed = []
            featurings = self.send("#{features_name}_featurings")
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
      attr_reader :feature_ids, :included_feature_ids
      
      def initialize(featurable = nil, features_name = nil)
        @feature_ids = {}
        @included_feature_ids = {}
        if featurable
          features_name ||= "features"
          featurings = featurable.send("#{features_name}_featurings")
          featurings.each do |featuring|
            @feature_ids[featuring.feature.feature_type_id.to_s] = featuring.feature_id
          end
          included_featurings = featurable.send("#{features_name}_featurings_with_include", :include => [ :feature, :featurable ]) - featurings
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