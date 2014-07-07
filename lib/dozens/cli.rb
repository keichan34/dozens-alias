require 'thor'
require 'dozens/alias'

module Dozens
  class CLI < Thor

    desc "update", "Updates a record to match another hostname."
    method_option :zone, :required => true, :desc => 'The zone of the record to update'
    method_option :hostname, :required => true, :desc => 'The hostname of the record to update'
    method_option :target, :required => true, :desc => 'The target record to ALIAS'
    def update
      d = Dozens::Alias.new options[:zone], options[:hostname], options[:target]
      d.update!
    end

  end
end
