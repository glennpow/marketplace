class MakesController < ApplicationController
  make_resource_controller do
    belongs_to :manufacturer
  end
  
  def resourceful_name
    t(:make, :scope => [ :marketplace ])
  end

  before_filter :check_editor_of_manufacturer, :only => [ :new, :create ]
  before_filter :check_editor_of_make, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:conditions] = [ "manufacturer_id = ?", @manufacturer.id ] unless @manufacturer.nil?
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        { :name => t(:manufacturer, :scope => [ :marketplace ]), :sort => :manufacturer, :include => :manufacturer, :order => 'manufacturers.name' },
        tp(:model, :scope => [ :marketplace ]),
        tp(:product, :scope => [ :marketplace ])
      ]
      options[:search] = true
      options[:include] = [ { :manufacturer => :organization }, :models, :products ]
    end
  end
 
  
  private
  
  def check_editor_of_manufacturer
    check_editor_of(@make)
  end
  
  def check_editor_of_make
    check_editor_of(@make)
  end
end
