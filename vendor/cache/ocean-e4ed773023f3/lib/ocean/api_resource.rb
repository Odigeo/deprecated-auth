module ApiResource

  def self.included(base)
    base.extend(ClassMethods)
  end


  module ClassMethods

    #
    # The whole params hash can safely be passed in as the first arg: the 
    # index_only class method is used to filter away disallowed record attributes.
    #
    def index(conds={}, group_by=nil, substring=nil)
      # TODO: pagination
      if index_only != []
        new_conds = {}
        index_only.each { |key| new_conds[key] = conds[key] if conds[key].present? }
        conds = new_conds
      end
      query = scoped.where(conds)
      query = query.group(group_by) if group_by.present? && index_only.include?(group_by.to_sym)
      query = query.where("#{index_search_property} LIKE ?", "%#{substring}%") if substring
      query
    end
    

    #
    # Returns the latest version for the resource
    #
    def latest_api_version
      Api.version_for(self.class.name.pluralize.underscore)
    end

  end


  # Instance methods

  def touch_both(other)
    touch
    other.touch
  end

end
