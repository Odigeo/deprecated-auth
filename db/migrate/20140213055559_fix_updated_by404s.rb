class FixUpdatedBy404s < ActiveRecord::Migration

  def up
    ApiUser.where(updated_by: 0).each do |r| set_it r; end
    Group.where(updated_by: 0).each do |r| set_it r; end
    Resource.where(updated_by: 0).each do |r| set_it r; end
    Right.where(updated_by: 0).each do |r| set_it r; end
    Role.where(updated_by: 0).each do |r| set_it r; end
    Service.where(updated_by: 0).each do |r| set_it r; end
  end

  def set_it r
    r.updated_by = r.created_by
    r.save!
  end

end
