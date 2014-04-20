class AddColumnsToWidget < ActiveRecord::Migration
  def change
    add_column :widgets, :email_address, :string
    add_column :widgets, :telephone_number, :string
    add_column :widgets, :phone_number, :string
    add_column :widgets, :url, :string
    add_column :widgets, :social_security_number, :string
  end
end
