module Microservice
  class Runner
    attr_accessor :service_name, :owner, :callback

    def initialize(microservice, owned_by, callback_url = '')
      @service_name = microservice
      @owner = owned_by
      @callback = callback_url
    end

    def run(user_params)
      HTTParty.post(ENV['MICROSERVICE_API_URL'] + '/jobs',
                    body: {
                      client_id: ENV['MICROSERVICE_API_KEY'],
                      client_secret: ENV['MICROSERVICE_API_SECRET'],
                      microservice_name: "#{@service_name}",
                      owned_by: "#{@owner}",
                      callback: "#{@callback}",
                      user_params: user_params
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
            )
    end
  end
end
