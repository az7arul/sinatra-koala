require 'bundler'
Bundler.require(:default)

require 'koala'
require 'byebug'

Koala.config.api_version = "v2.8"



APP_ID = 111
APP_SECRET = ''
PAGE_SIZE = 50

class QITest < Sinatra::Application

  use Rack::Session::Cookie, secret: ''

  get '/' do
  
    @logged_in = session['access_token']
    if @logged_in
      @graph = Koala::Facebook::API.new(session["access_token"])
      @images = @graph.get_connection('me', 'photos',
                                      {limit: PAGE_SIZE,
                                       fields: ['picture'
                                       ]})
      
      @statuses = @graph.get_connection('me', 'posts',
                                        {limit: PAGE_SIZE,
                                         fields: ['message', 'link'
                                         ]})
      
      @shared_links =  @graph.get_connection('me', 'posts',
                                            {limit: PAGE_SIZE,
                                             fields: ['story', 'link'
                                             ]})

      @videos =  @graph.get_connection('me', 'videos',
                                             {limit: PAGE_SIZE,
                                              type: 'uploaded',
                                              fields: ['source'
                                              ]})
      
      erb :index
    else
      erb :login
    end
  end

  get '/login' do
    # generate a new oauth object with your app data and your callback url
    session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
    # redirect to facebook to get your code
    permissions = "user_posts,user_status,user_photos"
    redirect session['oauth'].url_for_oauth_code(permissions: permissions)
  end

  get '/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/'
  end

  #method to handle the redirect from facebook back to you
  get '/callback' do
    #get the access token from facebook with your code
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect '/'
  end
end

