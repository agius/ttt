require 'sinatra'
require 'haml'

enable :sessions

helpers do
  def new_board
    session['ttt'] = [[0,0,0],[0,0,0],[0,0,0]]
  end
end

before do
  new_board unless session['ttt'].is_a?(Array)
  @win_conditions = []
  3.times do |n|
    @win_conditions << [[n, 0], [n, 1], [n, 2]]
    @win_conditions << [[0, n], [1, n], [2, n]]
  end
  @win_conditions << [[0, 0], [1, 1], [2, 2]]
  @win_conditions << [[0, 2], [1, 1], [2, 0]]
end

get '/' do
  haml :index
end

get '/new' do
  new_board
  redirect '/'
end

get '/win' do
  new_board
  haml :win
end

post '/' do
  hit = params.keys.first.match(/(\d+),(\d+)/).to_a
  row, col = hit[1].to_i, hit[2].to_i if hit.count > 2
  session['ttt'][row][col] = 1
  ai_moved = false
  @win_conditions.each do |coordinates|
    redirect '/win' if coordinates.all? {|point| session['ttt'][point[0]][point[1]] == 1 }
  end
  
  ai_moved = false
  case [:row, :col].sample
  when :row
    session['ttt'][row][session['ttt'][row].index(0)] = 2
  when :col
    session['ttt'][(0..2).to_a.select {|i| session['ttt'][i][col] == 0}.first][col] = 2
  end
  haml :index
end