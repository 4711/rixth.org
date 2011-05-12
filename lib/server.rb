require 'sinatra/base'
require 'net/http'

module RixthOrg
  class Server < Sinatra::Base
    set :cache, Dalli::Client.new(nil, {
      :expires_in => 3600 # cache for an hour
    })
    
    set :public, File.dirname(__FILE__) + '/../public'
    
    before do
      redirect request.url.sub('//www.', '//') if request.host[0..2] == 'www'
    end
  
    get '/' do
      @git = my_git_repos
      haml :index
    end
  
    helpers do
      def style_github_repo(repo)
        "<a href=\"#{repo['url']}\">#{repo['name']}</a>"
      end
    end
  
    def my_git_repos
      from_cache = settings.cache.get('gitrepos')
      return JSON.parse(from_cache) if from_cache
      
      begin
        repositories = JSON.parse(Net::HTTP.get_response(URI.parse('http://github.com/api/v2/json/repos/show/rixth')).body)["repositories"]
      rescue
        return []
      end
    
      repositories.reject! { |repo| repo['watchers'] < 3 }

      settings.cache.set('gitrepos', JSON.generate(repositories))
    end
  end
end