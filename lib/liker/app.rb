# http://www.sinatrarb.com/intro
require "rack/fiber_pool"
require "sinatra/base"

module Liker
  class App < Sinatra::Base
    
    use Rack::FiberPool, :size => 10
    
    set :logging, true
    set :raise_errors, true
    set :show_exceptions, true
    set :public, "public"
    enable :inline_templates
    
    configure do
      @@photos = {}
      pubdir = File.expand_path("../../../public", __FILE__)
      Dir.entries( pubdir ).each do |filename|  # bar.ext
        if filename =~ /(\.(jpeg|jpg|png))$/i   # $1 = .ext
          name = File.basename( filename, $1 )  # bar
          @@photos[name] = filename             # bar = bar.ext
        end
      end
    end
    
    get "/" do
      haml :index, :locals => { :title => "Liker", :photos => @@photos }, :layout => false
    end

    get "/:name" do
      name = params[:name]
      if file = @@photos[name] then
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
    %meta{ :property => "og:title",     :content => title }
    %meta{ :property => "og:type",      :content => "blog" }
    %meta{ :property => "og:url",       :content => "http://localhost/#{title}" }
    %meta{ :property => "og:image",     :content => "http://localhost/#{file}" }
    %meta{ :property => "og:site_name", :content => "Liker" }
    %meta{ :property => "fb:app_id",    :content => "208298742518293" }
  %body
    %div#wrapper
      = yield

@@ index
- photos.each_pair do |name,path|
  %div
    %a{ :href => ("/#{name}") }= name

@@ page
%div.title= title
%img{ :src => ("/#{file}"), :width => "100%" }
%script{ :src => "http://connect.facebook.net/en_US/all.js#xfbml=1" }
%fb:like{ :href => "http://localhost/#{title}", :show_faces => true, :width => 450 }
