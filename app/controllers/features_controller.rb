class FeaturesController < ApplicationController
  make_resource_controller do
    belongs_to :featurable
    
    before :show do
      add_breadcrumb h(@feature.parent.name), @feature.parent unless @feature.parent.nil?
      add_breadcrumb h(@feature.name)
    end
  end
  
  def resourceful_name
    t(:feature, :scope => [ :marketplace ])
  end

  before_filter :check_administrator_role, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :load_parent, :only => [ :index, :new, :create ]
  before_filter :check_parent, :only => [ :new, :create ]
  
  add_breadcrumb I18n.t(:feature, :scope => [ :marketplace ]).pluralize, :features_path
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:group), :sort => :parent, :include => :parent, :order => "#{Feature.table_name}.name" }, #FIXME - will choke
      ]
      options[:search] = true

      if @parent
        add_breadcrumb h(@parent.name), @parent

        options[:conditions] = { "#{Feature.table_name}.parent_id" => @parent.id }
      else
        options[:conditions] = { "#{Feature.table_name}.parent_id" => nil }
      end
      if @featurable
        add_breadcrumb h(@featurable.name), @featurable

        options[:include] = :featurings
        options[:conditions]["#{Featuring.table_name}.featurable_type"] = @featurable.class.to_s
        options[:conditions]["#{Featuring.table_name}.featurable_id"] = @featurable.id
      end
    end
  end
  
  def summary
    @feature = Feature.find(params[:id])
 
    respond_to do |format|
      format.html { render :layout => 'layouts/clean' } # summary.html.erb
    end
  end
  
  
  private
  
  def load_parent
    @parent = Feature.find(params[:parent_id]) if params[:parent_id]
  end
  
  def check_parent
    check_condition(@parent)
  end
end
