class FeatureTypesController < ApplicationController
  make_resource_controller do
    belongs_to :feature_type
    
    before :show do
      add_breadcrumb h(@feature_type.parent_feature_type.name), @feature_type.parent_feature_type unless @feature_type.parent_feature_type.nil?
      add_breadcrumb h(@feature_type.name)
    end
    
    before :new do
      @parent_feature_types = FeatureType.find(:all)
    end
    
    before :edit do
      @parent_feature_types = FeatureType.find(:all, :conditions => [ "id != ?", @feature_type.id ]) - @feature_type.child_feature_types
    end
  end
  
  def resourceful_name
    t(:feature_type, :scope => [ :marketplace ])
  end

  before_filter :check_administrator_role, :only => [ :new, :create, :edit, :update, :destroy ]

  add_breadcrumb I18n.t(:feature_type, :scope => [ :marketplace ]).pluralize, :feature_types_path
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        t(:parent_feature_type, :scope => [ :marketplace ]),
      ]
      options[:search] = true

      if @feature_type
        add_breadcrumb h(@feature_type.name), @feature_type

        options[:conditions] = [ "parent_feature_type_id = ?", @feature_type.id ]
      end
    end
  end
  
  def summary
    @feature_type = FeatureType.find(params[:id], :include => :features)
    @feature = Feature.find(params[:feature_id]) if params[:feature_id]
 
    respond_to do |format|
      format.html { render :layout => 'layouts/clean' } # summary.html.erb
    end
  end
end
