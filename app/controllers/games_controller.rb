require 'open-uri'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    grid = []
    grid_size.times { grid << ("A".."Z").to_a.sample }
    grid
  end

  def freq_builder(char_array)
    # Creates a hash with the frequency of each character
    char_array.each_with_object(Hash.new(0)) { |char, h| h[char.downcase] += 1 }
  end

  def match_grid?(attempt, grid)
    # Returns true if the letters of attempt (s) are a subset of the letters of grid (a)
    return false if attempt.empty?
    # Build frequency hashes
    freq_attempt = freq_builder(attempt.chars)
    freq_grid = freq_builder(grid)
    # Does only return true if all chars in attempt have lower or equal frequency than grid
    freq_attempt.keys.reduce(true) { |memo, key| memo && (freq_attempt[key] <= freq_grid[key]) }
  end

  def word_exists?(word)
    # Checks if the word exist by using the Wagon dictionary API
    word_url = "https://wagon-dictionary.herokuapp.com/#{word}"
    word_serialized = open(word_url).read
    JSON.parse(word_serialized)["found"]
  end

  def calc_result(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    # create a hash, put in the time, and starts with a result at 0
    result_h = { score: 0, time: ((end_time - start_time) / 1.second).round }
    if match_grid?(attempt, grid) == false
      result_h[:message] = "Not in the grid"
    elsif word_exists?(attempt) == false
      result_h[:message] = "Not an english word"
    else
      result_h[:score] = attempt.length.fdiv(result_h[:time])
      result_h[:message] = "Well done!"
    end
    result_h
  end

  def new
    @start_time = Time.now
    @letters = generate_grid(9)
  end

  def score
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    # raise
    grid = params[:grid].split
    word = params[:word]
    @result = calc_result(word, grid, start_time, end_time)
    # raise
  end
end
