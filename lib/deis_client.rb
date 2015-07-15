require 'httparty'

module Deis
  class ApiWrapper
    include HTTParty
    format :json
    headers 'Accept' => 'application/json'

    API_PATH = '/v1'

    def initialize(deis_url)
      @base_uri = deis_url + API_PATH
      # self.class.base_uri (deis_url + API_PATH)
    end

    def get(path, options)
      self.class.get(@base_uri + path, options)
    end

    def post(path, options)
      self.class.post(@base_uri + path, options)
    end

    def delete(path, options)
      self.class.delete(@base_uri + path, options)
    end
  end

  class Client
    @@methods = {
      # method => HTTP-verb, path
      login: [:post, '/auth/login/'],
      apps: [:get, '/apps/'],
      create_app: [:post, '/apps/'],
      delete_app: [:delete, '/apps/:app/'],
      app: [:get, '/apps/:app/'],
      app_logs: [:get, '/apps/:app/logs/'],
      app_run: [:post, '/apps/:app/run/'],
      containers: [:get, '/apps/:app/containers/'],
      config: [:get, '/apps/:app/config'],
      domains: [:get, '/apps/:app/domains'],
      builds: [:get, '/apps/:app/builds'],
      create_build: [:post, '/apps/:app/builds'],
      releases: [:get, '/apps/:app/releases'],
      release: [:get, '/apps/:app/releases/:release'],
      rollback_release: [:post, '/apps/:app/releases/rollback']
    }

    def initialize(deis_url, username, password)
      @http = Deis::ApiWrapper.new deis_url
      @headers = {}
      @auth = {username: username, password: password}
    end

    def login
      response = @http.post('/auth/login/', {body: @auth})

      throw Exception unless response.code == 200

      @token = response['token']
      @headers['Authorization'] = "token #{@token}"
      response
    end

    def apps
      perform :apps
    end

    def create_app(id=nil)
      if id
        perform :create_app, {app: id}
      else
        perform :create_app
      end
    end

    def delete_app(id)
      perform :delete_app, {app: id}
    end

    def app(id)
      perform :app, {app: id}
    end

    def app_logs(id)
      perform :app_logs, {app: id}
    end

    def app_run(id, command)
      perform :app_run, {app: id, command: command}
    end

    def containers(app_id)
      perform :containers, {app: app_id}
    end

    def config(app_id)
      perform :config, {app: app_id}
    end

    def domains(app_id)
      perform :domains, {app: app_id}
    end

    def builds(app_id)
      perform :builds, {app: app_id}
    end

    def create_build(app_id, image)
      perform :create_build, {app: app_id, image: image}
    end

    def releases(app_id)
      perform :releases, {app: app_id}
    end

    def release(app_id, release)
      perform :releases, {app: app_id, release: release}
    end

    def rollback_release(app_id, release)
      perform :rollback_release, {app: app_id, release: release}
    end

    protected

    # TODO: use own, meaningful exceptions expecially in this method
    def perform(method_sym, body={}, try_twice=true)
      login unless @token

      verb, path = @@methods[method_sym]
      path = interpolate_path(path, body)

      options = {
        headers: @headers,
        body: body
      }
      handle @http.public_send verb, path, options
    end

    def handle(response)
      case response.code
      when 200...300
        response.parsed_response
      when 401    # authentification required
        throw Exception unless try_twice
        login
        perform method_sym, options, false
      when 404
        nil   # or better an exception?
      else
        throw Exception
      end
    end

    def interpolate_path(path, body)
      /\/:(?<key>\w+)\/?/ =~ path
      return path unless key

      value = body[key.to_sym]
      path[':' + key] = value

      # this catched only one occurance of an key, so call recursively until nothing is found anymore
      interpolate_path path, body
    end
  end
end
