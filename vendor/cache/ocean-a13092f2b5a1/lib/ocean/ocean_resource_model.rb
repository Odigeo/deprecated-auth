#
# This is an "acts_as" type method to be used in ActiveRecord model
# definitions: "ocean_resource_model". Its purpose is to include necessary
# modules and to define what attributes can be indexed and searched.
#

module Ocean
  module OceanResourceModel
    
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods

      def ocean_resource_model(index:  [:name], 
      	                       search: :description
      	                      )
      	include ApiResource
      	cattr_accessor :index_only
      	cattr_accessor :index_search_property
      	self.index_only = index
      	self.index_search_property = search
      end
    end
  end
end


ActiveRecord::Base.send :include, Ocean::OceanResourceModel
