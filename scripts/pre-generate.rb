run do |spec|
  spec.targets[0].configurations.each { |c|
    c.settings ||= {}
    if ENV['PRODUCT_NAME']
    	c.settings['PRODUCT_NAME'] = ENV['PRODUCT_NAME']
    end
  }
end
