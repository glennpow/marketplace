class ModelsController < ApplicationController
  make_resource_controller do
    belongs_to :make
  end
  
  def resourceful_name
    t(:model, :scope => [ :marketplace ])
  end

  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]
  before_filter :check_editor_of, :only => [ :new, :create, :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:conditions] = [ "make_id = ?", @make.id ] unless @make.nil?
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => :manufacturer, :order => 'manufacturers.name' },
        { :name => t(:make, :scope => [ :marketplace ]), :sort => :make, :include => :make, :order => 'makes.name' },
        tp(:product, :scope => [ :marketplace ])
      ]
      options[:search] = true
    end
  end
  
  
  private
  
  def check_editor_of
    check_editor(@make || @model)
  end
end
