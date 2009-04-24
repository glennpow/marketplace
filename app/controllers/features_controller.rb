class FeaturesController < ApplicationController
  make_resource_controller do
    belongs_to :feature_type, :featurable
    
    before :show do
      add_breadcrumb h(@feature.feature_type.name), @feature.feature_type
      add_breadcrumb h(@feature.name)
    end

    before :new do
      @feature_types = FeatureType.find(:all)
    end
    
    before :edit do
      @feature_types = FeatureType.find(:all)
    end
  end
  
  def resourceful_name
    t(:feature, :scope => [ :marketplace ])
  end

  before_filter :check_administrator_role, :only => [ :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:feature_type, :scope => [ :marketplace ]), :sort => :feature_type, :include => :feature_type, :order => "#{FeatureType.table_name}.name" },
      ]
      options[:search] = true

      if @feature_type
        add_breadcrumb h(@feature_type.name), @feature_type

        options[:conditions] = [ "feature_type_id = ?", @feature_type.id ]
      elsif @featurable
        add_breadcrumb h(@featurable.name), @featurable

        options[:include] = :featurings
        options[:conditions] = [ "#{Featuring.table_name}.featurable_type = ? && #{Featuring.table_name}.featurable_id = ?", @featurable.class.to_s, @featurable.id ]
      end
    end
  end
end
