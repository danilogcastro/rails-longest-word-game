require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    alphabet = ('A'..'Z').to_a
    grid = []
    grid_size.times { grid << alphabet.sample }
    grid
  end

  def in_grid?(grid, attempt)
    test_array = grid.clone
    attempt.upcase.chars.each { |letter| test_array << letter }
    in_grid = test_array.sort.uniq == grid.sort.uniq

    has_less_letters = true
    attempt.upcase.chars.each do |letter|
      has_less_letters = false if attempt.upcase.chars.count(letter) > grid.count(letter)
    end

    in_grid && has_less_letters ? true : false
  end

  def word_valid?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    attempt_serialized = URI.open(url).read
    JSON.parse(attempt_serialized)['found']
  end

  def run_game(attempt, grid)
    if in_grid?(grid, attempt) && word_valid?(attempt)
      @message = "Congratulations! #{attempt.capitalize} is a valid English word!"
    elsif !word_valid?(attempt)
      @message = "Sorry! #{attempt.capitalize} is not a valid English word!"
    elsif !in_grid?(grid, attempt)
      @message = "Sorry! #{attempt.capitalize} is not in the grid!"
    end
  end

  def new
    @letters = generate_grid(10)
  end

  def score
    @guess = params[:guess]
    @grid = params[:grid].split(" ")
    run_game(@guess, @grid)
  end
end
