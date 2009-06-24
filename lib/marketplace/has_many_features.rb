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
      
        class_eval do
          has_many "#{features_name}_featurings".intern, :class_name => 'Featuring', :as => :featurable, :include => :feature, :order => "#{Feature.table_name}.position ASC, #{Feature.table_name}.name ASC", :dependent => :destroy
          has_many features_name.intern, :class_name => 'Feature', :through => "#{features_name}_featurings".intern, :source => :feature, :order => "#{Feature.table_name}.position ASC, #{Feature.table_name}.name ASC"
        end

        if (includes = [ options[:include] || [] ].flatten).any?
          class_eval do
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
            includes << :feature unless includes.include?(:feature)
            finder_sql = "SELECT #{Featuring.table_name}.* FROM #{Featuring.table_name} #{finder_joins} WHERE #{finder_where}"
            
            has_many "#{features_name}_featurings_with_include".intern, :class_name => 'Featuring', :as => :featurable, :include => includes, :finder_sql => finder_sql, :order => "#{Feature.table_name}.position ASC, #{Feature.table_name}.name ASC"
            has_many "#{features_name}_with_include".intern, :class_name => 'Feature', :through => "#{features_name}_featurings_with_include".intern, :source => :feature, :order => "#{Feature.table_name}.position ASC, #{Feature.table_name}.name ASC"
          end
        end

        # define_method "#{feature_name}_in" do |feature|
        #   self.send(features_name).detect { |feature| feature.parent_id == feature.id }
        # end
        #   
        # define_method "has_#{feature_name}_in?" do |feature|
        #   !self.send("#{feature_name}_for", feature).nil?
        # end
        
        define_method "#{feature_name}_tree" do
          self.send("#{features_name}_featurings").inject([]) do |feature_tree, featuring|
            tree = feature_tree
            featuring.feature.ancestors.reverse.each do |ancestor|
              ancestor_hash = tree.detect { |child| child[:id] == ancestor.id }
              tree << ancestor_hash = { :id => ancestor.id, :name => ancestor.name, :feature_type => ancestor.feature_type, :children => [] } if ancestor_hash.nil?
              tree = ancestor_hash[:children]
            end

            case featuring.feature.feature_type
            when FeatureType[:option]
              tree << { :id => featuring.feature.id, :name => featuring.feature.name, :feature_type => featuring.feature.feature_type, :value => 1 }
            when FeatureType[:comparable]
              tree << { :id => featuring.feature.id, :name => featuring.feature.name, :feature_type => featuring.feature.feature_type, :value => featuring.value }
            when FeatureType[:boolean]
              tree << { :id => featuring.feature.id, :name => featuring.feature.name, :feature_type => featuring.feature.feature_type, :value => featuring.value }
            end
            feature_tree
          end
        end
  
        define_method "valid_#{features_name}" do
          Feature.find_all_for_featurable(self)
        end
  
        define_method "valid_#{features_name}?" do
          Feature.count_for_featurable(self) > 0
        end
        
        define_method :attributes= do |attributes|
          if features = attributes.delete(features_name)
            featurings = self.send("#{features_name}_featurings")
            featurings.destroy_all
            features.each do |feature_id, value|
              feature = Feature.find(feature_id)
              case feature.feature_type
              when FeatureType[:single_select]
                featurings << Featuring.new(:feature_id => value)
              when FeatureType[:option]
                featurings << Featuring.new(:feature_id => feature_id) if value.true?
              when FeatureType[:comparable]
                featurings << Featuring.new(:feature_id => feature_id, :value => value)
              when FeatureType[:boolean]
                featurings << Featuring.new(:feature_id => feature_id, :value => value)
              end
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
        # @included_feature_ids = {}
        if featurable
          features_name ||= "features"
          featurings = featurable.send("#{features_name}_featurings")
          featurings.each do |featuring|
            case featuring.feature.feature_type
            when FeatureType[:option]
              if featuring.feature.parent.feature_type == FeatureType[:single_select]
                @feature_ids[featuring.feature.parent_id.to_s] = featuring.feature_id
              else
                @feature_ids[featuring.feature.id.to_s] = 1
              end
            when FeatureType[:comparable]
              @feature_ids[featuring.feature.id.to_s] = featuring.value
            when FeatureType[:boolean]
              @feature_ids[featuring.feature.id.to_s] = featuring.value
            end
          end
          # included_featurings = featurable.send("#{features_name}_featurings_with_include", :include => [ :feature, :featurable ]) - featurings
          # included_featurings.each do |featuring|
          #   @included_feature_ids[featuring.feature.feature_type_id.to_s] = { :feature_id => featuring.feature_id, :featurable => featuring.featurable }
          # end
        end
      end
      # 
      # def included_for_type(feature_type)
      #   feature_type_id = case feature_type
      #   when String, Fixnum
      #     feature_type.to_i
      #   else
      #     feature_type.id
      #   end
      #   @included_feature_ids[feature_type_id.to_s]
      # end
    
      def method_missing(method, *args)
        @feature_ids[method.to_s] || 0
      end
    end
  end
end

ActiveRecord::Base.send(:include, Marketplace::HasManyFeatures) if defined?(ActiveRecord::Base)