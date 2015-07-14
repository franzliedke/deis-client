require 'httparty'

module Deis
  class ApiWrapper
    include HTTParty
    format :json
    headers 'Accept' => 'application/json'

    API_PATH = '/v1'

    @@methods = {
      # method => HTTP-verb, path
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

    def login(auth)
      self.class.post '/auth/login/', auth
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
end

class DeisClient
  def initialize(deis_url, username, password)
    @api_wrapper = Deis::ApiWrapper.new deis_url
    @headers = {}
    @auth = {username: username, password: password}
  end

  def login
    response = self.class.post('/auth/login/', @auth)

    throw Exeption unless response.code = 200

    @token = response['token']
    @headers['Authorization'] = "Token token=\"#{@token}\""
  end

  def apps
    get '/apps'
  end

  protected

  def get(path, retried=false)
    login unless @token
    response = self.class.get(path, headers: @headers)

    case response.code
    when 200
      response
    when 401
      throw Exception if retried
      login
      get path, retried: true
    when 404
      nil   # or better an exception?
    else
      throw Exception
    end
  end
end
