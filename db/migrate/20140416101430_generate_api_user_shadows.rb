class GenerateApiUserShadows < ActiveRecord::Migration
  def up
    ApiUser.find_each do |u|
      u.save!
    end
  end
end
