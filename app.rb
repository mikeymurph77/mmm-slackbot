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
      respond_message("There are #{resp['open_issues_count']} open issues on #{repo}")
    when 'advice'
      repo_url = "http://api.adviceslip.com/advice"
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message("*Your tip:* \n resp['advice']")
    when 'github status'
      repo_url = "https://status.github.com/api/last-message.json"
      resp = HTTParty.get(repo_url)
      resp = JSON.parse resp.body
      respond_message("*Status:* _#{resp['status']}_ \n #{resp['body']}")
  end
end

def respond_message(message)
  content_type :json
  { text: message }.to_json
end
