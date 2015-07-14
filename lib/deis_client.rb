require 'httparty'

module Deis
  class ApiWrapper
    include HTTParty
    format :json
    headers 'Accept' => 'application/json'

    API_PATH = '/v1'

    @@methods = {
      # method => HTTP-verb, path
      login: [:post, '/auth/login/']
      apps: [:get, '/apps/'],
      create_app: [:post, '/apps/'],
      delete_app: [:delete, '/apps/%s/'],
      app: [:get, '/apps/%s/'],
      app_logs: [:get, '/apps/%s/logs'],
      app_run: [:post, '/apps/%s/run']
    }

    def initialize(deis_url)
      self.class.base_uri (deis_url + API_PATH)
    end

    def method_missing(method_sym, *arguments, &block)
      super unless @@methods.has_key? method_sym

      verb, path = @@methods[method_sym]
      options = arguments.length == 0 ? {} : arguments[0]

      path = path % options[:id] if '%s' in path
      perform_request verb, path, options, &block
    end

    def perform_request(verb, path, options, &block)
      case verb
      when :get
        self.class.get path, options, &block
      when :post
        self.class.post path, options, &block
      when :delete
        self.class.delete path, options, &block
      end
    end
  end

  class Client
    def initialize(deis_url, username, password)
      @api_wrapper = Deis::ApiWrapper.new deis_url
      @headers = {}
      @auth = {username: username, password: password}
    end

    def login
      response = @api_wrapper.login @auth

      throw Exception unless response.code == 200

      @token = response['token']
      @headers['Authorization'] = "Token token=\"#{@token}\""
      response
    end

    def apps
      perform :apps
    end

    def create_app(id)
      perfrom :create_app, {id: id}
    end

    def delete_app(id)
      perform :delete_app, {id: id}
    end

    def app
      perform :app, {id: id}
    end

    def app_logs
      perform :app_logs, {id: id}
    end

    protected

    # TODO: use own, meaningful exceptions expecially in this method
    def perform(method_sym, body={}, try_twice=false)
      login unless @token

      options = {
        headers: @headers,
        body: body
      }
      response = @api_wrapper.public_send method_sym, options

      case response.code
      when 200
        response
      when 401    # authentification required
        throw Exception unless try_twice
        login
        perform method_sym, options
      when 404
        nil   # or better an exception?
      else
        throw Exception
      end
    end
  end
end
