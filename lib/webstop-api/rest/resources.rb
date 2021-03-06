require 'webstop-api/utilities/object_factory'
require 'faraday'

module WebstopApi

  module REST
    module Resources
      include WebstopApi::ObjectFactory

      STATUSES = {
        400 => 'Missing or Malformed Input. Check your submitted information and try again.',
        401 => 'Your token is unavailable or incorrect.'
      }

      def enhanced_exception(e, custom_statuses = {})
        statuses = STATUSES.merge(custom_statuses)
        if e.respond_to?(:http_code) && statuses[e.http_code]
          new_message = "#{e.message}: #{statuses[e.http_code]}"
          e.define_singleton_method(:message) { new_message }
        end
        e
      end

      def connection(path = "/api/#{WebstopApi.api_version}")
        # puts "=== connection('#{path}')"
        @@connection_cache ||= {}
        @@connection_cache[path] ||= Faraday.new(:url => WebstopApi.endpoint + path) do |faraday|
          # yields Faraday instance to be config'd (make adapter last)
          # see: https://github.com/lostisland/faraday
          # faraday.response :logger # log requests & responses to stdout
          faraday.headers['Content-Type'] = 'application/json'
          faraday.adapter :net_http_persistent, pool_size: 15 do |http|
            # yields Net::HTTP::Persistent to be config'd
            # see: https://www.rubydoc.info/gems/net-http-persistent/Net/HTTP/Persistent
            http.idle_timeout = 20
          end
        end
      end

      def v1_connection
        connection("/api/v1")
      end

      def retailer_connection
        connection("/api/#{ WebstopApi.api_version }/retailers/#{WebstopApi.retailer_id}")
      end

      def v1_retailer_connection
        connection("/api/v1/retailers/#{WebstopApi.retailer_id}")
      end

      def v2_retailer_connection
        connection("/api/v2/retailers/#{WebstopApi.retailer_id}")
      end


    end
  end
end
