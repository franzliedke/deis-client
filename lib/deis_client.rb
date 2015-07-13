require 'httparty'

class DeisClient
  include HTTParty
  format :json
  headers 'Accept' => 'application/json'
  API_PATH = '/v1'

  def initialize(deis_url, username, password)
    self.class.base_uri (deis_url + API_PATH)
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
