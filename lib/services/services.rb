# a module to namespace all services
module Service; end
# a module to namespace all parsers
module Service::Parser; end
# a module to namespace all parser strategies
module Service::Parser::Strategy; end

require_relative './options.rb'
require_relative './delegator.rb'
require_relative './attributable.rb'
require_relative './worker/worker.rb'
require_relative './worker/supervisor.rb'
require_relative './parsers/base.rb'
require_relative './parsers/feed.rb'
require_relative './parsers/feed_item.rb'
require_relative './parsers/image.rb'
require_relative './parsers/metadata.rb'
require_relative './parsers/image_strategies/base.rb'
require_relative './parsers/image_strategies/xpath.rb'
require_relative './parsers/image_strategies/largest_image.rb'
require_relative './parsers/image_strategies/open_graph.rb'
require_relative './parsers/image_strategies/twitter.rb'
