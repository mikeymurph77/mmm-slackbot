require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  return if params[:token] != ENV['SLACK_TOKEN']
  message = params[:text].gsub(params[:trigger_word], '').strip

  action, repo = message.split('_').map {|c| c.strip.downcase }

  case action
    when 'issues'
      repo_url = "https://api.github.com/repos/#{repo}"
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message("There are #{resp['open_issues_count']} open issues on #{repo}", resp['avatar_url'])
    when 'advice'
      repo_url = "http://api.adviceslip.com/advice"
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message("*Your tip:* \n resp['advice']")
  end
end

def respond_message(message, img_url=nil)
  content_type :json
  {
    :text => message,
    :image_url => img_url
  }.to_json
end
