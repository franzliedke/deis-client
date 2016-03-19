require 'httparty'

module Deis
  class Error < StandardError
    attr_reader :status, :message, :data

    def initialize(http_status = nil, message = nil, data = nil)
      @status = http_status
      @message = message
      @data = data
    end
  end

  class ClientError < Error; end

  class ServerError < Error; end

  # the following two errors are just convenience for better rescuing
  class AuthorizationError < ClientError
    def initialize(message = nil, data = nil)
      super(401, message, data)
    end
  end

  class NotFound < ClientError
    def initialize(message = nil, data = nil)
      super(404, message, data)
    end
  end


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
      apps: [:get, '/apps'],
      create_app: [:post, '/apps/'],
      delete_app: [:delete, '/apps/:app/'],
      app: [:get, '/apps/:app/'],
      app_logs: [:get, '/apps/:app/logs/'],
      app_run: [:post, '/apps/:app/run/'],
      containers: [:get, '/apps/:app/containers/'],
      restart_containers: [:post, '/apps/:app/containers/restart/'],
      restart_containers_by_type: [:post, '/apps/:app/containers/:type/restart/'],
      restart_container: [:post, '/apps/:app/containers/:type/:number/restart'],
      scale: [:post, '/apps/:app/scale/'],
      config: [:get, '/apps/:app/config/'],
      set_config: [:post, '/apps/:app/config/'],
      domains: [:get, '/apps/:app/domains/'],
      add_domain: [:post, '/apps/:app/domains/'],
      remove_domain: [:delete, '/apps/:app/domains/:domain'],
      builds: [:get, '/apps/:app/builds/'],
      create_build: [:post, '/apps/:app/builds/'],
      releases: [:get, '/apps/:app/releases/'],
      release: [:get, '/apps/:app/releases/:release/'],
      rollback_release: [:post, '/apps/:app/releases/rollback/']
    }

    def initialize(deis_url, username, password)
      @http = Deis::ApiWrapper.new deis_url
      @headers = {'Content-Type' => 'application/json'}
      @auth = { username: username, password: password }
    end

    def login
      verb, path = @@methods[:login]
      response = @http.public_send(verb, path, body: @auth)

      raise AuthorizationError.new unless response.code == 200

      @token = response['token']
      @headers['Authorization'] = "token #{@token}"
      response
    end

    def apps
      perform :apps
    end

    def create_app(id = nil)
      if id
        perform :create_app, {}, id: id
      else
        perform :create_app
      end
    end

    def delete_app(id)
      perform :delete_app, app: id
    end

    def app(id)
      perform :app, app: id
    end

    def app_logs(id)
      perform :app_logs, app: id
    end

    def app_run(id, command)
      perform :app_run, { app: id }, command: command
    end

    def containers(app_id)
      perform :containers, app: app_id
    end

    def restart_containers(app_id, opts = {})
      if opts[:type]
        if opts[:number]
          perform :restart_container, opts.merge(app: app_id)
        else
          perform :restart_containers_by_type, app: app_id, type: opts[:type]
        end
      else
        perform :restart_containers, app: app_id
      end
    end

    def scale(app_id, type_number_hash)
      perform :scale, { app: app_id }, type_number_hash
    end

    def config(app_id)
      perform :config, app: app_id
    end

    def set_config(app_id, values)
      perform :set_config, { app: app_id }, values: values
    end

    def domains(app_id)
      perform :domains, app: app_id
    end

    def add_domain(app_id, domain)
      perform :add_domain, { app: app_id }, domain: domain
    end

    def remove_domain(app_id, domain)
      perform :remove_domain, { app: app_id, domain: domain }
    end

    def builds(app_id)
      perform :builds, app: app_id
    end

    def create_build(app_id, image)
      perform :create_build, { app: app_id }, image: image
    end

    def releases(app_id)
      perform :releases, app: app_id
    end

    def release(app_id, release)
      perform :releases, app: app_id, release: release
    end

    def rollback_release(app_id, release)
      perform :rollback_release, { app: app_id }, release: release
    end

    protected

    def perform(method_sym, interpolations = {}, body = {}, try_twice = true)
      login unless @token

      verb, path = @@methods[method_sym]
      # Interpolate path modifies the path instead of only returning the new one.
      #   hence we duplicate it so the original is never modified.
      path = interpolate_path(path.dup, interpolations)

      options = {
        headers: @headers,
        body: body.to_json
      }

      begin
        handle @http.public_send(verb, path, options)
      rescue AuthorizationError => e
        raise e unless try_twice
        login
        handle @http.public_send(verb, path, options)
      end
    end

    def handle(response)
      case response.code
      when 200...300
        response.parsed_response
      when 401
        raise AuthorizationError.new
      when 404
        raise NotFound.new
      when 400...500
        raise ClientError.new response.code, response.message, response: response
      when 500...600
        raise ServerError.new response.code, response.message, response: response
      else
        raise Error.new response.code, response.message, response: response
      end
    end

    def interpolate_path(path, interpolations)
      %r{/:(?<key>\w+)/?} =~ path
      return path unless key

      value = interpolations[key.to_sym]
      path[':' + key] = value

      # this catched only one occurance of an key, so call recursively until nothing is found anymore
      interpolate_path path, interpolations
    end
  end
end
