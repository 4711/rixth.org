require 'sinatra/base'
require 'net/https'

module RixthOrg
  class Server < Sinatra::Base
    set :cache, Dalli::Client.new(nil, {
      :expires_in => 3600 # cache for an hour
    })

    set :public_folder, File.dirname(__FILE__) + '/../public'
    set :haml, :format => :html5

    before do
      redirect request.url.sub('//www.', '//') if request.host[0..2] == 'www'
    end

    get '/' do
      @git = my_git_repos
      haml :index
    end

    def my_git_repos
      from_cache = settings.cache.get('gitrepos')
      return JSON.parse(from_cache) if from_cache

      begin
        uri = URI.parse("https://api.github.com/users/rixth/repos")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        repositories = JSON.parse(http.request(request).body)
      rescue
        return []
      end

      repositories.reject! { |repo| repo['watchers'] < 3 }
      repositories.sort! { |a, b| b['watchers'] <=> a['watchers'] }

      settings.cache.set('gitrepos', JSON.generate(repositories))
      repositories
    end
  end
end