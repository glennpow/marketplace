class CreateMarketplace < ActiveRecord::Migration
  def self.up
    create_table :costs, :id => false do |t|
      t.references :region, :null => false
      t.references :product, :null => false
      t.float :amount
    end
    
    add_index :costs, [ :region_id, :product_id ]
    add_index :costs, :product_id

    create_table :feature_types do |t|
      t.references :parent_feature_type
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
    
    add_index :feature_types, :parent_feature_type_id

    create_table :features do |t|
      t.references :feature_type, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
    
    add_index :features, :feature_type_id
    
    create_table :featurings do |t|
      t.references :featurable, :polymorphic => true, :null => false
      t.references :feature, :null => false
    end
    
    add_index :featurings, [ :featurable_type, :featurable_id ]
    add_index :featurings, :feature_id

    create_table :makes do |t|
      t.references :manufacturer, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.references :production_status
      t.timestamps
    end
    
    add_index :makes, :manufacturer_id
    
    create_table :manufacturers do |t|
      t.references :organization, :null => false
      t.timestamps
    end
    
    add_index :manufacturers, :organization_id

    create_table :models do |t|
      t.references :make, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.references :production_status
      t.integer :technology_level
      t.timestamps
    end
    
    add_index :models, :make_id

    create_table :offers do |t|
      t.references :offer_provider, :polymorphic => true
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :code
      t.float :amount
      t.references :offer_type, :null => false
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
    
    add_index :offers, [ :offer_provider_type, :offer_provider_id ]

    create_table :offers_products, :id => false do |t|
      t.references :offer, :null => false
      t.references :product, :null => false
    end
    
    add_index :offers_products, :offer_id
    add_index :offers_products, :product_id

    create_table :prices do |t|
      t.references :vendor, :null => false
      t.references :product, :null => false
      t.float :amount
      t.timestamps
    end
    
    add_index :prices, [ :vendor_id, :product_id ]
    add_index :prices, :product_id

    create_table :products do |t|
      t.references :model, :null => false
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :sku, :null => false
      t.references :production_status
      t.timestamps
    end
    
    add_index :products, :model_id
    add_index :products, :sku
    
    create_table :quote_requests do |t|
      t.references :user, :null => false
      t.references :vendor, :null => false
      t.references :product, :null => false
      t.timestamps
    end
    
    add_index :quote_requests, [ :user_id, :product_id ]
    add_index :quote_requests, [ :vendor_id, :product_id ]
    
    create_table :vendors do |t|
      t.references :organization, :null => false
      t.timestamps
    end
    
    add_index :vendors, :organization_id
  end

  def self.down
    drop_table :costs
    drop_table :features
    drop_table :feature_types
    drop_table :featurings
    drop_table :manufacturers
    drop_table :makes
    drop_table :models
    drop_table :offers
    drop_table :offers_products
    drop_table :prices
    drop_table :products
    drop_table :quote_requests
    drop_table :vendors
  end
end
