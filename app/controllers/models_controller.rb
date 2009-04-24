class ModelsController < ApplicationController
  make_resource_controller do
    belongs_to :make
    
    before :show do
      add_breadcrumb h(@model.manufacturer.name), @model.manufacturer
      add_breadcrumb h(@model.make.name), @model.make
      add_breadcrumb h(@model.name)

      load_comments(@model)
      load_reviews(@model)
    end
    
    before :new do
      add_breadcrumb h(@make.manufacturer.name), @make.manufacturer
      add_breadcrumb h(@make.name), @make
    end
    
    before :edit do
      add_breadcrumb h(@model.manufacturer.name), @model.manufacturer
      add_breadcrumb h(@model.make.name), @model.make
      add_breadcrumb h(@model.name), @model
    end
  end
  
  def resourceful_name
    t(:model, :scope => [ :marketplace ])
  end

  before_filter :check_editor_of_make, :only => [ :new, :create ]
  before_filter :check_editor_of_model, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => :manufacturer, :order => 'manufacturers.name' },
        { :name => t(:make, :scope => [ :marketplace ]), :sort => :make, :include => :make, :order => 'makes.name' },
        tp(:product, :scope => [ :marketplace ])
      ]
      options[:search] = true
      options[:include] = [ { :manufacturer => :organization }, :make, :products ]

      if @make
        add_breadcrumb h(@make.manufacturer.name), @make.manufacturer
        add_breadcrumb h(@make.name), @make

        options[:conditions] = { "#{Model.table_name}.make_id" => @make }
      else
        options[:conditions] = {}
      end
      unless has_administrator_role? || is_editor_of?(@make)
        options[:conditions]["#{Model.table_name}.production_status"] = ProductionStatus[:available]
      end
    end
  end
  
  
  private
  
  def check_editor_of_make
    check_editor_of(@make)
  end
  
  def check_editor_of_model
    check_editor_of(@model)
  end
end
