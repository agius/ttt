require 'sinatra'
require 'haml'

enable :sessions

helpers do
  def new_board
    session['ttt'] = [[0,0,0],[0,0,0],[0,0,0]]
  end
  
  def win?(player)
    @win_conditions.any? { |coordinates| 
      coordinates.all? {|point| session['ttt'][point[0]][point[1]] == player }
    }
  end
  
  def open_location?
    session['ttt'].any? { |row| row.any?{|col| col == 0 } }
  end
  
  def open_locations
    open_locations = []
    session['ttt'].each_with_index { |row, r| row.each_with_index { |col, c| open_locations << [r, c] if col == 0 } }
    open_locations
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

[:win, :lose, :draw].each do |page|
  get "/#{page}" do
    new_board
    haml page
  end
end

get '/move' do
  session['flash'] = 'Invalid move!' and redirect '/' unless params.keys.count > 0
  hit = params.keys.first.match(/(\d+),(\d+)/).to_a
  row, col = hit[1].to_i, hit[2].to_i if hit.count > 2
  if hit.count < 2 || session['ttt'][row][col] != 0
    session['flash'] = 'Invalid move!'
    redirect '/' and return
  end
  session['ttt'][row][col] = 1
  redirect '/win' if win?(1)
  redirect '/draw' unless open_location?
  
  ai_moved = false
  # if player is about to win, block them
  @win_conditions.each do |coordinates|
    next if ai_moved
    open_location = coordinates.select{|point| session['ttt'][point[0]][point[1]] == 0}.first
    if coordinates.select {|point| session['ttt'][point[0]][point[1]] == 1}.count > 1 and open_location
      session['ttt'][open_location[0]][open_location[1]] = 2
      ai_moved = true
    end
  end
  
  #otherwise, move randomly
  unless ai_moved
    r, c = open_locations[rand(open_locations.count - 1)]
    session['ttt'][r][c] = 2
  end
  
  redirect '/lose' if win?(2)
  redirect '/draw' unless open_location?
  redirect '/'
end