require "erb"
require "rack/fiber_pool" # fibers
require "sinatra/base" # http://www.sinatrarb.com/intro

module Liker
  class App < Sinatra::Base
    
    use Rack::FiberPool, :size => 100 # fibers
    
    configure do
      set :app_file, __FILE__ # or could set public and views
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
      %meta{ :property => "fb:app_id",    :content => "199890130028792" }
      %meta{ :property => "fb:admins",    :content => "1664736154" }
  %body
    %div#wrapper
      = yield

@@ index
- photos.each_pair do |name,path|
  %div
    %a{ :href => ("/#{name}") }= name

@@ page
%link{ :rel => "stylesheet", :href => "/two.css", :type => "text/css" }
%div#header
  %h1.title= title
%div.colmask.rightmenu
  %div.colleft
    %div.col1wrap
      %div.col1
        %div.photo
          %img{ :src => ("/#{file}"), :"max-width" => "640", :"max-height" => "640" }
  %div.col2
    %fb:like{ :href => @like_url, :show_faces => true, :width => 300 }
    %br
    %fb:recommendations{ :site => @this_domain, :width => 300, :height => 300, :header => "true" }
    %br
    %fb:activity{ :site => @this_domain, :width => "300", :height => "300", :header => "true", :recommendations => "false" }
    %br
    %fb:comments{ :href => @like_url, :num_posts => 2, :width => 300 }
%div#footer
%div#fb-root
%script{ :src => "http://connect.facebook.net/en_US/all.js#appId=199890130028792&amp;xfbml=1" }
