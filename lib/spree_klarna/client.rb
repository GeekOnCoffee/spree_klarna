require 'xmlrpc/client'

module SpreeKlarna
  class Client < ::XMLRPC::Client
    attr_accessor :store_id,
                  :store_secret,
                  :mode,
                  :timeout,
                  :last_request_headers,
                  :last_request_params,
                  :last_response,
                  :client_ip,
                  :protocol,
                  :host,
                  :port

    def initialize(*args)

      options = args.extract_options!
      self.client_ip = options[:client_ip].presence || '127.0.0.1'
      self.mode = options[:mode]
      self.timeout = options.key?(:timeout) ? options[:timeout] : 10 # seconds

      #unless ::Klarna::API::END_POINT.keys.include?(self.mode)
      #  raise "No such mode: #{self.mode.inspect}. " <<
      #  "Valid modes: #{::Klarna::API::END_POINT.keys.collect(&:inspect).join(', ')}"
      #end

      begin
       # ::Klarna.log "Endpoint URI: %s" % self.endpoint_uri.inspect

        super('payment-beta.klarna.com', '/', self.port, nil, nil, nil, nil, self.protocol == 'https', self.timeout)

        self.http_header_extra ||= {}
        self.http_header_extra.merge!( {
          :'Accept-Encoding' => 'deflate,gzclient_ip',
          :'Content-Type' => "text/xml;charset='iso-8859-1'",
          :'Accept-Charset' => 'iso-8859-1', # REVISIT: 'UTF-8,ISO-8859-1,US-ASCII',
          :'Connection' => 'close',
          :'User-Agent' => 'ruby/xmlrpc' # Note: Default "User-Agent" gives 400-error.
        }.with_indifferent_access)

    end

    def call2(service_method, *args)
      
      self.last_request_headers = http_header_extra
      
      super(service_method, args)
    end

    def ssl?
      self.protocol == 'https'
    end
    alias :use_ssl? :ssl?

    def protocol
      @protocol = Rails.env == "production" ? 'https' : 'http' 
    end

    def host
      @host = Rails.env == "production" ? 'payment.klarna.com' : 'payment-beta.klarna.com' 
    end

    def port
      @port = Rails.env == "production" ? '443' : '80' 
    end

    def endpoint_uri
      @endpoint_uri = "#{self.protocol}://#{self.host}:#{self.port}"
    end

      # Request content-type headers.
      #
      def content_type_headers
        {
          :'Accept-Encoding' => 'deflate,gzclient_ip',
          :'Content-Type' => "text/xml;charset='iso-8859-1'",
          :'Accept-Charset' => 'iso-8859-1', # REVISIT: 'UTF-8,ISO-8859-1,US-ASCII',
          :'Connection' => 'close',
          :'User-Agent' => 'ruby/xmlrpc' # Note: Default "User-Agent" gives 400-error.
        }.with_indifferent_access
      end

      # Ensure that the required client info params get sent with each Klarna API request.
      # Without these the Klarna API will get a service error response.
      #
      def add_meta_params(*args)
        args.unshift *['4.0', ::XMLRPC::Client::USER_AGENT]
        args
      end
    end
  end
end