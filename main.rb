require 'colorize'

class Mastermind
  attr_reader :board, :hints, :template, :colors, :empty_key, :answer_key, :player, :color_key

  def initialize
    @board = Array.new(12,['X','X','X','X'])
    @hints = Array.new(12,['|','|','|','|'])
    @template = ['O'.colorize(:red) + ' = "R"', 'O'.colorize(:green) + ' = "G"', 'O'.colorize(:blue) + ' = "B"', 'O'.colorize(:yellow) + ' = "Y"', 'O'.colorize(:magenta) + ' = "M"', 'O'.colorize(:cyan) + ' = "C"', 'O'.colorize(:black) + ' = "BLK"', 'O'.colorize(:white) + ' = "W"', "|".colorize(:red) + ' = Correct color but wrong position', '|'.colorize(:green) + ' = Correct color and position']
    @colors = ['R', 'G', 'B', 'Y', 'M', 'C', 'BLK', 'W']
    @empty_key = Array.new(4)
    @answer_key = Array.new(4)
    @player = nil
    @color_key = Array.new(4)
  end

  def get_key(player)
    if player
      @answer_key = @empty_key.each_with_index.map do |peg_color, index|
        while !colors.include?(peg_color) do
          p "Enter the color you'd like for peg position ##{index+1}. Follow key on right side for colors"
          peg_color = gets.chomp.upcase
        end
        peg_color
      end
    else
      @answer_key = @empty_key.map do
        random_color = colors[rand(8)]
        random_color
      end
    end
  end

  def get_guess
    @empty_key.each_with_index do |peg, index|
    puts "What is your current guess of colors. Separate each guess by a comma. See color key on the right."
    
  end

  def convert_key
    key = {'R' => 'O'.colorize(:red), 'G' => 'O'.colorize(:green), 'B' => 'O'.colorize(:blue),'Y' => 'O'.colorize(:yellow),'M' => 'O'.colorize(:magenta),'C' => 'O'.colorize(:cyan),'BLK' => 'O'.colorize(:black),'W' => 'O'.colorize(:white)}

    @color_key = letter_key.map do |letter|
      key[letter]
    end
  end

  def print_board 
    @board.each_with_index do |row, index|
      puts "Guess ##{index+1} ==> #{row} ++ #{@hints[index]}  || #{@template[index]}"
    end
  end
end

game = Mastermind.new()

who_player = nil
while who_player == nil do 
  puts "Type ('Y'/'y') if you'd like to be the one guessing and ('N'/'n') if you want to choose the 4 codes"
  choice = gets.chomp.upcase
  if choice == 'Y'
    who_player = true
  elsif choice == 'N'
    who_player = false
  end
end

game.get_key(who_player)