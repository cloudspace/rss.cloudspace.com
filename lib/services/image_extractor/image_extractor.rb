# require 'active_support/core_ext/hash/conversions'

# module Service
#   module StructuredMetadata
#     def self.parse(url)
#       p = Parser.new(url)
#       p.parse
#     end

#     class Parser
#       def initialize(url)
#         @url = url
#       end

#       def parse
#         @parsed ||= {}.tap do |out|
#           strategies.each do |s|
#             p = s.new(self)
#             out[s.to_s.demodulize.underscore.to_sym] = p.parse
#           end
#         end
#       end

#       def raw_page
#         @raw_page ||= HTTParty.get(@url)
#       end

#       def document
#         @document ||= Nokogiri::HTML(raw_page)
#       end

#       def meta_tags
#         @meta_tags ||= document.xpath("//meta").map { |meta| {}.tap{|out| meta.attribute_nodes.each{ |n| out[n.name] = n.value } } }
#       end

#       private

#       def strategies
#         ::Service::StructuredMetadata::Strategy::Base.descendants #.map{|d| d.to_s.demodulize.underscore.to_sym}
#       end
#     end

#     module Strategy
#       class Base
#         def initialize(parser)
#           @parser = parser
#         end

#         def parse
#           @cached_parse ||= execute_parse
#         end

#         def document
#           @parser.document
#         end
#       end

#       class OpenGraph < Base
#         def execute_parse
#           {}.tap do |out|
#             @parser.meta_tags.select { |k,v| k['property'] =~ /^og:[a-z]+/i }.each do |tag|
#               out[tag['property'].sub(/^og:/i, '')] = tag['content']
#             end
#           end
#         end
#       end

#       class Microdata < Base
#         def execute_parse
#           scopes = document.xpath("//*[@itemscope]")
#           scopes.map do |scope|
#             scope.xpath("//*[@itemprop]").map do |prop|
#               prop.content
#             end
#           end
#         end
#       end

#       class TwitterCard < Base
#         def execute_parse
#           {}.tap do |out|
#             @parser.meta_tags.select{ |k,v| k['name'] =~ /^twitter:[a-z]+/i }.each do |tag|
#               out[tag['name'].sub(/^twitter:/i, '')] = tag['content']
#             end
#           end
#         end
#       end
#     end
#   end
# end
