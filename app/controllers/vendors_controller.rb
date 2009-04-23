class VendorsController < ApplicationController
  make_resource_controller do
    before :show do
      load_comments(@vendor)
      load_reviews(@vendor)
    end

    before :create do
      @vendor.organization.moderator = current_user
      @vendor.organization.parent_group = @group
    end
    
    response_for :create do |format|
      format.html { redirect_to home_path }
    end
    
    response_for :update do |format|
      format.html { redirect_to home_path }
    end
  end
  
  def resourceful_name
    t(:vendor, :scope => [ :marketplace ])
  end

  before_filter :check_add_vendor, :only => [ :new, :create ]
  before_filter :check_moderator_of_vendor, :only => [ :edit, :update, :destroy ]
  
  def index
    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(:name), :sort => :name, :include => :organization, :order => "#{Organization.table_name}.name" },
        tp(:moderator, :scope => [ :authentication ]),
      ]
      options[:search] = true
      options[:include] = [ { :organization => { :group => :moderators } }, :products ]
    end
  end
  
  
  private
  
  def check_add_vendor
    @group = Group.find_by_name(Configuration.vendor_group_name)
    check_condition(has_permission?(Action.add_organization, @group))
  end
  
  def check_moderator_of_vendor
    check_moderator_of(@vendor)
  end
end
