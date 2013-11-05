source "https://rubygems.org"
ruby '2.0.0'

# Core
gem "sinatra"
gem "mongoid", "~> 3.1.0"
gem "activesupport", require: "active_support/core_ext/string"
gem "thin"
# gem "will_paginate", :git => "https://github.com/mislav/will_paginate.git",
#                      :ref => "7a45eab080ff0da7917ac4f6e76cfb2db29d90b1"
gem "will_paginate_mongoid"
gem "will_paginate-bootstrap"
gem "erubis"
gem "nokogiri"
gem "thor"
gem "faker"
if RUBY_PLATFORM =~ /linux/
  gem "rubywmq"
end

# Views
gem "haml"
gem "sass"
gem "sinatra-twitter-bootstrap", require: "sinatra/twitter-bootstrap"

gem "pry"

group :development do
  gem "awesome_print"
  gem "rb-fsevent"
  gem "guard"
  gem "guard-shotgun"
end
