class RemoveFeatureToggling < ActiveRecord::Migration

  def up
  	ft = Service.find_by_name "feature_toggling"
  	ft.destroy if ft
  end

end
