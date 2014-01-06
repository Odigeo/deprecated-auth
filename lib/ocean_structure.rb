#
# Process any rights
#
def process_rights(target, list, exclusive)
  if exclusive
    puts "| Cleared all rights"
    target.rights = [] 
  end
  (list || []).each do |x|
    if x.is_a?(Hash) && x['regexp']
      Right.all.each do |r|
        if r.name =~ Regexp.new(x['regexp']) && !target.rights.include?(r)
          puts "| Added the regexp matched #{r.name} right"
          target.rights << r 
        end
      end
    else
      r = Right.find_by_name x
      target.rights << r if r && !target.rights.include?(r)
      puts "| Added #{r.name} right"
    end
  end
end
