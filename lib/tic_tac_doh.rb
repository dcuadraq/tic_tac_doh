require "tic_tac_doh/version"

module TicTacDoh
  class Game
    # X starts
    # Previous winner starts new game
    #   or which turn would have followed if draw

    attr_reader :players, :grid, :turn

    def initialize(args={})
      @players = []
      @turn = 1
      @players << args[:player1] << args[:player2]
      args.fetch(:size, 3).times do
        @grid = Array.new(3) {}
      end
    end

    def play
      # puts grid.length
      # puts players.count
      prepare_grid()
      player_turn ||= 0
      until game_over
        clear_screen
        print_grid
        # puts "turn: #{@turn}"
        turn(players[player_turn])
        player_turn = player_turn == (players.count - 1) ? 0 : player_turn + 1
        @turn = @turn + 1 unless game_over
      end
      clear_screen
      print_grid
      puts  "Game Over"
      # puts @turn
    end

    private

    def prepare_grid(size=grid.length)
      @grid = []
      array = []
      for cell in 0...size
        for cell2 in cell * size...(cell * size + size)
          array << cell2
        end
        @grid << array
        array = []
      end
    end

    def game_over
      # Winner
      if symbol_winner?
        return true
      end
      # No more free cells
      @grid.each do |row|
        row.each do |cell|
          return false if cell.is_a? Numeric
        end
      end
      clear_screen
      print_grid
      true
    end

    def symbol_winner?
      winner_mark = nil
      grid.length.times do |n|
        grid.length.times do |m|
          winner_mark ||= secuential_mark(grid[n][m], n,0,0,1) # horizontal search
          winner_mark ||= secuential_mark(grid[m][n], 0,n,1,0) # vertical search
          winner_mark ||= secuential_mark(grid[m][n], m,n,1,1) # diagonal +
          winner_mark ||= secuential_mark(grid[m][n], m,n,-1,1) # diagonal -
        end
      end
      return winner_mark
    end

    def secuential_mark(mark, row, col, row_step, col_step, counter=1)
      return nil unless in_range?(row, col)
      if grid[row][col] == mark
        return grid[row][col] if counter == 3
        return secuential_mark(mark, row + row_step, col + col_step, row_step, col_step, counter+1)
      else
        return nil
      end
    end

    def in_range? (arg, col)
      if arg.is_a? Hash
        return true if arg[:row] < grid.length && arg[:col] < grid.length if arg[:row] >= 0 && arg[:col] >= 0
      else
        return true if arg < grid.length && col < grid.length if arg >= 0 && col >= 0
      end
      false
    end

    def print_grid
      grid.each do |row|
        puts row.join('|')
      end
    end

    def turn(player)
      player_action player
    end

    def player_action (player)
      valid_move = false
      until valid_move == true do
        position = calculate_cell(player_move player)
        valid_move = insert_player_move_in_grid(position, player_mark(player))
      end
    end

    def clear_screen
      system 'clear' or system 'cls'
    end

    def calculate_cell(cell_number)
      row = 0
      for n in 0..cell_number
        row += 1 if (n % grid.size) == 0 unless n == 0
      end
      column = cell_number - (row * grid.size)
      {row: row, column: column}
    end

    def insert_player_move_in_grid(position, mark)
      return false unless valid_move? position
      @grid[position[:row]][position[:column]] = mark
      true
    end

    def valid_move?(position)
      return false if position[:row] < 0 || position[:row] > (@grid.length) -1
      return false if position[:column] < 0 || position[:column] > (@grid.length) -1
      return false unless @grid[position[:row]][position[:column]].is_a? Numeric
      true

    end

    def player_move(player)
      player.move()
    end

    def player_mark(player)
      player.mark
    end
  end

  class Player
    attr_reader :nickname, :score, :mark

    def initialize(args={})
      @nickname = args.fetch(:nickname, "Anonymous#{rand(100)}")
      @score = 0
      @mark = args[:mark]
    end

    def move()
      puts "#{self.mark} turn "
      puts "Pick a position"
      gets.chomp.to_i
    end

    def add_to_score(score)
      @score += score
    end
  end
end