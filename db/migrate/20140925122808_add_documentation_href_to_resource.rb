class AddDocumentationHrefToResource < ActiveRecord::Migration
  def change
  	add_column :resources, :documentation_href, :string
  end
end
