require 'colorize'

class Mastermind
  attr_reader :board, :hints, :template, :colors, :empty_key, :answer_key, :player, :color_key, :letter_key, :who_player, :game_finished, :current_row, :key, :computer_color_list, :computer_passed_colors, :comptuer_answer_key, :computer_guesses, :current_amount_correct, :prev_amount_correct

  def initialize
    @board = Array.new(12){['X','X','X','X']}
    @hints = Array.new(12){Array.new(4)}
    @template = ['O'.colorize(:red) + ' = "R"', 'O'.colorize(:green) + ' = "G"', 'O'.colorize(:blue) + ' = "B"', 'O'.colorize(:yellow) + ' = "Y"', 'O'.colorize(:magenta) + ' = "M"', 'O'.colorize(:cyan) + ' = "C"', 'O'.colorize(:black) + ' = "BLK"', 'O'.colorize(:white) + ' = "W"', "|".colorize(:red) + ' = Correct color but wrong position', '|'.colorize(:green) + ' = Correct color and position']
    @colors = ['R', 'G', 'B', 'Y', 'M', 'C', 'BLK', 'W']
    @empty_key = Array.new(4)
    @answer_key = Array.new(4)
    @key = {'R' => 'O'.colorize(:red), 'G' => 'O'.colorize(:green), 'B' => 'O'.colorize(:blue),'Y' => 'O'.colorize(:yellow),'M' => 'O'.colorize(:magenta),'C' => 'O'.colorize(:cyan),'BLK' => 'O'.colorize(:black),'W' => 'O'.colorize(:white)}
    @player = nil
    @color_key = Array.new(4)
    @letter_key = Array.new(4)
    @who_player = nil
    @game_finished = false
    @current_row = 0
    @computer_color_list = @colors
    @computer_passed_colors = Hash.new
    @computer_guesses = Array.new(4){Array.new(4)}
    @prev_amount_correct = 0
    @current_amount_correct = 0
  end

  def which_player
    while @who_player == nil do 
      puts "Type ('Y'/'y') if you'd like to be the one guessing and ('N'/'n') if you want to choose the 4 codes"
      choice = gets.chomp.upcase
      if choice == 'Y'
        @who_player = true
      elsif choice == 'N'
        @who_player = false
      end
    end
  end

  def get_answer_key
    if !@who_player
      @answer_key = @empty_key.each_with_index.map do |peg_color, index|
        while !@colors.include?(peg_color) do
          p "Enter the color you'd like for peg position ##{index+1}. Follow key on right side for colors"
          peg_color = gets.chomp.upcase
        end
        peg_color
      end
    else
      @answer_key = @empty_key.map do
        random_color = @colors[rand(8)]
        random_color
      end
    end
  end

  def delete_options(color, position)
    temp = @computer_guesses[position].clone
    @computer_guesses.each_with_index.map do | column, index |
      if position == index # <= removes all options besides the right color at the right position
        spot = column.index(color)
        temp.delete_at(spot)
        temp.each { |c| column.delete_at(column.index(c))} 
      else # <= removes the correct color option from other arrays in the matrix
        first_instance = column.index(color)
        column.delete_at(first_instance)
      end
    end
  end

  def one_at_a_time(matrix) # <= finds the correct color between the two that switched
    index = tested = 0
    found = false
    while !found
      if matrix[index].length > 1
        position = matrix[index].index(@letter_key[index])
        @letter_key[index] = matrix[index][position-1]
        if tested == 0 # <= if it's the first changed node it will test and if it is the correct one then it removes the color options from the matrix else the second changed node will be the correct one
          play_round 
          if @current_amount_correct > @prev_amount_correct 
            delete_options(@letter_key[index], index)
            found = true
          else
              @computer_guesses[index].delete_at(position-1) # <= removes the tested color from the corresponding index
          end
        else
          delete_options(@letter_key[index],index)
          found = true
        end
        tested += 1
      end
      index += 1
    end
  end

  def choose_next # <= changes only the next two possible elements
    count = 0
    @computer_guesses.each_with_index do |array, index|
      position = array.index(@letter_key[index])
      if array.length > 1 && count < 2
        position == array.length ? position = -1 : position # <= wraps back to first element of the array 
        @letter_key[index] = array[position + 1]
        count += 1
      end
  end

  def computer_logic
    if @computer_guesses[1][1] == nil # <= initialize the 4 colors in the final answer into the matrix computer_guesses
      @computer_passed_colors.each_with_index.map do |color, index|
        @computer_guesses[0][index] = @computer_guesses[1][index-3] = @computer_guesses[2][index-2] = @computer_guesses[3][index-1] = color
      end
      @letter_key.each_with_index.map do |space,index| # <= Allow a baseline hint so computer logic can start narrowing colors down
        space = @computer_guesses[index][0]
        space
      end
    else
      delta_correct = @current_amount_correct - @prev_amount_correct
      if !delta_correct.positive?
        if @current_amount_correct == 0
          @letter_key.each_with_index.map do |peg, index| # <= removes values from guess matrix if none of them are in the correct position
            @computer_guesses[index].delete_at(@computer_guesses[index].index(peg))
            peg = @computer_guesses[index][0]
          end
        elsif delta_correct.negative?
          one_at_a_time(@computer_guesses)
          choose_next
        else
          choose_next
        end
      elsif delta_correct.positive?
        if delta_correct == 1 && skip == false
          one_at_a_time(@computer_guesses)
          choose_next
        elsif delta_correct == 2
          count = 0
          @computer_guesses.each_with_index do |array, index|
            position = array.index(@letter_key[index])
            if array.length > 1 && count < 2
              delete_options(@letter_key[index], index)
              count += 1
            end
          end
        end
      end
    end
  end

  def get_guess
    if @who_player
      @letter_key = @empty_key.each_with_index.map do |peg, index| 
        while peg == nil do
          puts "What is your current guess of colors on peg #{index+1}. Please type the letter corresponding to the color of your choice (see color key)."
          peg = gets.chomp.upcase
          @colors.include?(peg) ?  peg : peg = nil
        end
        peg
      end
    else
      if @computer_passed_colors.length == 4
        
      elsif @current_row < 8
        @letter_key.map do
          @color[@current_row]
        end
      end
    end
  end

  def game_end_test
    if @letter_key == @answer_key
      puts "\nCongrats you won!"
      @game_finished = true
    elsif @current_row == 12
      colored_answer = @answer_key.map do |letter|
        @key[letter]
      end
      puts "\nYou lost, better luck next time! The correct answer was: #{colored_answer.join(' ')}"
      @game_finished = true
    end
  end

  def convert_key # <= converts the letter array into one with 'O' with the corresponding color
    @color_key = @letter_key.map do |letter|
      @key[letter]
    end
  end

  def change_hints_color
    temp_answer = @answer_key.clone
    changed_key = Array.new(4)
    randomize_hint = rand(2)
    changed_key = @letter_key.each_with_index.map do |peg, index|
      if peg == @answer_key[index]
        randomize_hint == 0 ? @hints[@current_row].push('|'.colorize(:green)) : @hints[@current_row].unshift('|'.colorize(:green))
        temp_answer.delete_at(temp_answer.index(peg)) #<- removes color from the array it is being compared to so if mulitple same color is guessed but only answer key only has 1 guess then it won't change all the pegs to red
        peg = ''
      end
      peg
    end
    changed_key.each_with_index.map do |peg, index| #<- finds if there's any colors in the guess & answer key but not in the right location
      if temp_answer.include?(peg)
        randomize_hint == 0 ? @hints[@current_row].push('|'.colorize(:red)) : @hints[@current_row].unshift('|'.colorize(:red))
        temp_answer.delete_at(temp_answer.index(peg))
      end
    end
  end

  def add_key_to_board
    @board[@current_row] = @color_key
    @current_row += 1
  end

  def print_board 
    puts "\n", @template
    @board.each_with_index do |row, index|
      puts "Guess ##{index+1} ==> #{row.join(' ')} ++#{@hints[index].join(' ')}"
    end
  end

  def play_round #<= plays one round of the game
    get_guess
    convert_key
    change_hints_color
    add_key_to_board
    game_end_test
    print_board
  end

  def play_game
    which_player
    puts "\n", @template
    get_answer_key
    while !@game_finished
      play_round
    end
  end
end

game = Mastermind.new()
game.play_game