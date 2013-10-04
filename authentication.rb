class Authentication < Rack::Auth::Basic
  def initialize(app, realm=nil, path_whitelist, &authenticator)
    @path_whitelist = path_whitelist
    super(app, realm, &authenticator)
  end

  def call(env)
    if @path_whitelist.include?(env["REQUEST_PATH"])
      return @app.call(env)
    end
    super(env)
  end
end
