class AddDocumentationToRolesAndGroups < ActiveRecord::Migration
  def change
  	add_column :roles, :documentation_href, :string
  	add_column :groups, :documentation_href, :string
  end
end
