class ModelsController < ApplicationController
  make_resource_controller do
    belongs_to :make
  end
  
  def resourceful_name
    t(:model, :scope => [ :marketplace ])
  end

  before_filter :check_editor_of_make, :only => [ :new, :create ]
  before_filter :check_editor_of_model, :only => [ :edit, :update, :destroy ]
  
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
      options[:include] = [ { :manufacturer => :organization }, :make, :products ]
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
