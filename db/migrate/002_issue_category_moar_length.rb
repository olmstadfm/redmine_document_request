class IssueCategoryMoarLength < ActiveRecord::Migration

  def self.up
    change_column :issue_categories, :name, :string, :limit => 150, :default => "", :null => false    
  end

  def self.down
    change_column :issue_category, :name, :string, :limit => 60, :default => "", :null => false    
  end

end
