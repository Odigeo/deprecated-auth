class AddDocumentationHrefToService < ActiveRecord::Migration
  def change
  	add_column :services, :documentation_href, :string
  end
end
