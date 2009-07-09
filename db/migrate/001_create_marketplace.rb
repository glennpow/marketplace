class CreateMarketplace < ActiveRecord::Migration
  def self.up
    create_table :costs do |t|
      t.references :country, :null => false
      t.references :product, :null => false
      t.float :amount
    end
    
    add_index :costs, [ :country_id, :product_id ]
    add_index :costs, :product_id

    create_table :features do |t|
      t.references :parent
      t.string :feature_type, :null => false
      t.boolean :supplier_only, :default => false
      t.boolean :compare_only, :default => false
      t.string :units
      t.string :featurable_type
      t.string :name, :null => false
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.integer :position
      t.boolean :highlight, :default => false
      t.integer :highlight_position
      t.timestamps
    end
    
    add_index :features, :parent_id
    
    create_table :featurings do |t|
      t.references :featurable, :polymorphic => true, :null => false
      t.references :feature, :null => false
      t.string :value
      t.text :description
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
      t.string :production_status
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
      t.string :production_status
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
      t.string :offer_type, :null => false
      t.date :starts_on
      t.date :ends_on
      t.timestamps
    end
    
    add_index :offers, [ :offer_provider_type, :offer_provider_id ]

    create_table :offers_products, :id => false do |t|
      t.references :offer, :null => false
      t.references :product, :null => false
    end
    
    add_index :offers_products, :offer_id
    add_index :offers_products, :product_id

    create_table :orders do |t|
      t.references :user
      t.string :order_status
      t.string :card_first_name
      t.string :card_last_name
      t.string :card_type
      t.date :card_expires_on
      t.string :shipping_name
      t.timestamps
    end
    
    add_index :orders, [ :user_id, :order_status ]
    
    create_table :order_line_items do |t|
      t.references :order, :null => false
      t.references :price, :null => false
      t.integer :quantity, :default => 1
    end
    
    add_index :order_line_items, :order_id
    
    create_table :order_transactions do |t|
      t.references :order, :null => false
      t.string :order_action
      t.integer :amount
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params
      t.datetime :created_at
    end

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
      t.string :production_status
      t.integer :weight, :default => 0
      t.integer :width, :default => 0
      t.integer :length, :default => 0
      t.integer :height, :default => 0
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
    drop_table :carts
    drop_table :cart_items
    drop_table :costs
    drop_table :customers
    drop_table :features
    drop_table :feature_types
    drop_table :featurings
    drop_table :manufacturers
    drop_table :makes
    drop_table :models
    drop_table :offers
    drop_table :offers_products
    drop_table :orders
    drop_table :order_transactions
    drop_table :prices
    drop_table :products
    drop_table :quote_requests
    drop_table :vendors
  end
end
