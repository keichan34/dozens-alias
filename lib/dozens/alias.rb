require "dozens/alias/version"
require "dozens/api"

module Dozens
  class Alias

    def initialize zone, hostname, target
      @zone = zone
      @hostname = hostname
      @target = target

      @general_resolv = Resolv::DNS.new
      @target_resolv = Resolv::DNS.new nameserver: authoritative_nameservers
    end

    def update!
      correct_ips = target_ips.sort_by { |x| x }

      api = API.new ENV['DOZENS_USER'], ENV['DOZENS_KEY']

      record_list = api \
        .get_record_list(@zone)['record'] \
        .select { |x| x['type'] == 'A' and x['name'] == @hostname } \
        .sort_by { |x| x['content'] }

      record_list.each_with_index do |r, i|
        if r['content'] != correct_ips[i]
          api.update_record r['id'], correct_ips[i]
          print "=> Updated #{r['content']} to #{correct_ips[i]}\n"
        end
      end
    end

    private

    def authoritative_nameservers(for_domain=nil)
      domain = for_domain || @target
      ns = @general_resolv.getresources domain, Resolv::DNS::Resource::IN::NS
      if ns.count == 0
        next_domain = domain.split('.')[1..-1].join('.')
        authoritative_nameservers next_domain
      else
        ns.map { |e| e.name.to_s }.first
      end
    end

    def target_ips
      @target_resolv.getaddresses(@target).map { |e| e.to_s }
    end

  end
end
