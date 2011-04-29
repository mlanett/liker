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
      set :app_id,            development? && LIKER_ML || LIKER_B
      set :app_file,          __FILE__ # or could set public and views
      set :inline_templates,  true
      set :public,            "public"
      
      @@photos = {}
      pubdir = File.expand_path("../../../public", __FILE__)
      Dir.entries( pubdir ).each do |filename|  # bar.ext
        if filename =~ /(\.(jpeg|jpg|png))$/i   # $1 = .ext
          name = File.basename( filename, $1 )  # bar
          @@photos[name] = filename             # bar = bar.ext
        end
      end
    end
    
    configure :development, :test do
      set :logging,         true
      set :raise_errors,    true
      set :show_exceptions, true
    end
    
    helpers do
      def fbconnect( title, image )
        @this_app_id = settings.development? && LIKER_ML || LIKER_B
        @this_domain = request.host
        @like_url    = request.url
        @like_title  = title
        @like_image  = image
      end
    end
    
    get "/" do
      haml :index, :locals => { :title => "Liker", :photos => @@photos }, :layout => false
    end

    get "/:name" do
      name = params[:name]
      if file = @@photos[name] then
        fbconnect( name, url(file) )
        haml :page, :locals => { :title => name, :file => file }
      end
    end  
    
  end # App
end # Liker

__END__

@@ layout
%html{ :xmlns => "http://www.w3.org/1999/xhtml", :"xmlns:og" => "http://ogp.me/ns#", :"xmlns:fb" => "http://www.facebook.com/2008/fbml" }
  %head
    %title= title
    - if @like_url then
      %meta{ :property => "og:title",     :content => @like_title }
      %meta{ :property => "og:type",      :content => "blog" }
      %meta{ :property => "og:url",       :content => @like_url }
      %meta{ :property => "og:image",     :content => @like_image }
      %meta{ :property => "og:site_name", :content => "Liker" }
      %meta{ :property => "fb:app_id",    :content => @this_app_id }
  %body
    %div#wrapper
      = yield

@@ index
- photos.each_pair do |name,path|
  %div
    %a{ :href => ("/#{name}") }= name

@@ page
%link{ :rel => "stylesheet", :href => "/table.css", :type => "text/css" }
%div#header
  %h1.title= title
%table{ :cellspacing => 0, :cellpadding => 0, :border => 0 }
  %tr
    %td.content
      %div.photo
        %img{ :src => ("/#{file}"), :"max-width" => "640", :"max-height" => "640" }
    %td.menu
      %fb:like{ :href => @like_url, :show_faces => true, :width => 300, :send => 1 }
      %br
      %br
      %fb:recommendations{ :site => @this_domain, :width => 300, :height => 300, :header => "true" }
      %br
      %br
      %fb:activity{ :site => @this_domain, :width => "300", :height => "300", :header => "true", :recommendations => "false" }
      %br
      %br
      %fb:comments{ :href => @like_url, :num_posts => 2, :width => 300 }
%div#footer
%div#fb-root
%script{ :src => "http://connect.facebook.net/en_US/all.js#appId=199890130028792&amp;xfbml=1" }
