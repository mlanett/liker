require "clogger"
require "erb"
require "logger"
require "rack/fiber_pool" # fibers
require "sinatra/base" # http://www.sinatrarb.com/intro

module Liker
  class App < Sinatra::Base
    
    LIKER_ML = 144834555585360
    LIKER_B  = 199890130028792
    
    use Rack::FiberPool, :size => 100 # fibers
    use Clogger, :format => '$status "$request" ($request_time)', :logger => $stdout, :reentrant => true
    
    configure do
      @@photos = {}
      pubdir = File.expand_path("../../../public", __FILE__)
      Dir.entries( pubdir ).each do |filename|  # bar.ext
        if filename =~ /(\.(jpeg|jpg|png))$/i   # $1 = .ext
          name = File.basename( filename, $1 )  # bar
          @@photos[name] = filename             # bar = bar.ext
        end
      end
      set :public, File.expand_path("../../../public", __FILE__)
      set :views,  File.expand_path("../views", __FILE__)
    end
    
    configure :development, :test do
      require "sinatra/reloader"
      register Sinatra::Reloader
      set :logging,         true
      set :raise_errors,    true
      set :show_exceptions, true
    end
    
    helpers do
      # @see http://developers.facebook.com/docs/opengraph/
      # Should have title, type, image, url, site_name; description recommended
      @@og_default = {
        :fb_admins    => "1664736154",
        :fb_app_id    => settings.development? ? LIKER_ML : LIKER_B,
        #og_image     => "http://www.example.com/logo.gif",
        :og_site_name => "Liker",
        :og_title     => "Example",
        :og_type      => "product",
        :og_url       => "http://www.example.com/"
      }
      def set_og_headers( options = {} )
        @og = @@og_default.merge( :og_url => request.url, :site => request.host ).merge( options )
        puts @og.inspect
      end
    end
    
    get "/" do
      set_og_headers :og_title => "Liker", :og_type => "website"
      haml :index, :locals => { :photos => @@photos }
    end

    get "/:name" do
      name = params[:name]
      if file = @@photos[name] then
        set_og_headers :og_title => name, :og_image => url(file)
        haml :page, :locals => { :file => file }
      end
    end  
    
  end # App
end # Liker
