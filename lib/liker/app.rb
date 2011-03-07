require "rack/fiber_pool"
require "sinatra/base"

module Liker
  class App < Sinatra::Base
    
    use Rack::FiberPool, :size => 10
    
    set :logging, true
    set :raise_errors, true
    set :show_exceptions, true
    
    configure do
      puts "#{ENV.inspect}"
    end
    
    get "/" do
      "Hello, world! The time is now #{Time.now}."
    end

    get "/:name" do
      %Q[
        <html>
          <head>
            <title> #{params[:name]} </title>
          </head>
          <body>
            #{params[:name]}
          </body>
        </html>
      ]
    end  

  end # App
end # Liker
