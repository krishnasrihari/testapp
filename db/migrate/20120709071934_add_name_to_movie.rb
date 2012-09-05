class AddNameToMovie < ActiveRecord::Migration
  def up
    add_column :movies, :name, :string
    add_column :movies, :release, :string
  end
  
  def down
    remove_column :movies, :name
    remove_column :movies, :release
  end
end
