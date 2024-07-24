require 'colorize'

class Mastermind
  attr_reader :board, :hints, :template

  def initialize
    @board = Array.new(12,['O','O','O','O'])
    @hints = Array.new(12,['|','|','|','|'])
    @template = ['O'.colorize(:red) + ' = "R"', 'O'.colorize(:green) + ' = "G"', 'O'.colorize(:blue) + ' = "B"', 'O'.colorize(:yellow) + ' = "Y"', 'O'.colorize(:magenta) + ' = "M"', 'O'.colorize(:cyan) + ' = "C"', 'O'.colorize(:black) + ' = "BLK"', 'O'.colorize(:white) + ' = "W"', "|".colorize(:red) + ' = Correct color but wrong position', '|'.colorize(:green) + ' = Correct color and position']
  end

  def get_key(player)
    empty_key = Array.new(4)
    colors = ['R', 'G', 'B', 'Y', 'M', 'C', 'BLK', 'W']

    if player
      answer_key = empty_key.each_with_index.map do |peg_color, index|
        while !colors.include?(peg_color) do
          p "Enter the color you'd like for peg position ##{index+1}. Follow key on right side for colors"
          peg_color = gets.chomp.upcase
        end
        peg_color
      end
    else
      answer_key = empty_key.map do
        random_color = colors[rand(8)]
        random_color
      end
    end
    return answer_key
  end

  def get_guess
    return gets.chomp "What is your current guess of colors. Separate each guess by a comma. See color key on the right."
  end

  def convert_key(letter_key)
    letter_key = ['R', 'B', 'BLK', 'C']
    key = {'R' => 'O'.colorize(:red), 'G' => 'O'.colorize(:green), 'B' => 'O'.colorize(:blue),'Y' => 'O'.colorize(:yellow),'M' => 'O'.colorize(:magenta),'C' => 'O'.colorize(:cyan),'BLK' => 'O'.colorize(:black),'W' => 'O'.colorize(:white)}

    color_key = letter_key.map do |letter|
      key[letter]
    end
    return color_key
  end

  def print_board 
    @board.each_with_index do |row, index|
      puts "Guess ##{index+1} ==> #{row} ++ #{@hints[index]}  || #{@template[index]}"
    end
  end
end

game = Mastermind.new()
game.print_board