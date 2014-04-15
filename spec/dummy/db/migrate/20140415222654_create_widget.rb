class CreateWidget< ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.decimal :decimal
      t.float :float
      t.integer :integer
      t.datetime :datetime
    end
  end
end
