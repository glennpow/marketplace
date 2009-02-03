class ManufacturersController < ApplicationController
  make_resource_controller do
    before :create do
      @manufacturer.organization.manager = current_user
      @manufacturer.organization.parent_group = @group
    end
    
    response_for :create do |format|
      format.html { redirect_to home_path }
    end
    
    response_for :update do |format|
      format.html { redirect_to home_path }
    end
  end
  
  def resourceful_name
    t(:manufacturer, :scope => [ :marketplace ])
  end

  before_filter :check_add_manufacturer, :only => [ :new, :create ]
  before_filter :check_editor_of, :only => [ :set_current ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name },
        tp(:moderator, :scope => [ :authentication ]),
        tp(:make, :scope => [ :marketplace ]),
        tp(:model, :scope => [ :marketplace ]),
        tp(:product, :scope => [ :marketplace ])
      ]
      options[:search] = true
    end
  end
  
  
  private
    
  def check_add_manufacturer
    @group = Group.find_by_name(Configuration.manufacturer_group_name)
    check_condition(has_permission?(Action.add_organization, @group))
  end

  def check_moderator_of
    check_moderator(@manufacturer)
  end
end
