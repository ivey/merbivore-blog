module Merb
  module GlobalHelpers    
    def tag_cloud(tags, classes)
      return "" if tags.nil? || tags.empty?
      max, min = 0, 0
      tags.each do |t|
        max = t.taggings.count.to_i if t.taggings.count.to_i > max
        min = t.taggings.count.to_i if t.taggings.count.to_i < min
      end
      divisor = ((max - min) / classes.size) + 1
      tags.each do |t|
        yield t, classes[(t.taggings.count.to_i - min) / divisor]
      end
    end
  end
end