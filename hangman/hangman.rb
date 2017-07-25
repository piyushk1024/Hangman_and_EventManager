#require "yaml"
class Hangman

  def initialize #sets up the game and initilizes the major instance variables
    @dict = File.readlines("5desk.txt") #open and read from the dictionary
    @word = wordpicker #choose a random word from the dictionary
    @moves = 10 #set the number of guesses
    @score = @word.length #used to determine the progress of player's success
    @used_guesses = "" # tracks all the guesses used up by the player
    @response = "" #current player response
    #array of available guesses
    @guess_space = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    master #call up the controller method for the game
  end

  def displayer #puts out status of the game in a formatted manner
    puts @display_string.join("  ")
    puts ""
    puts "#{@moves} guesses left"
    puts ""
    puts "Guesses made: #{@used_guesses}"
    puts ""

    fn = File.open("killme.txt","r") #routine for printing out the hangman
    n = 0
    printer = false
    fn.each do |x|
      if printer
        puts x
        n += 1
      end
      printer = true if @moves.to_s == x.chomp
      printer = false if n == 6
    end
  end

  def wordpicker #picks random word from the dictionary
    word = ""
    while word.length <7 || word.length >14 #ensure word is between 5 and 12 chars long
      word = @dict.sample().downcase
    end
    return word.split("")[0..-3] #strip /n and split into char array
  end

  def saver  #save file routine
    puts "Enter savefile name"
    fname = gets.chomp
    fn = File.new("#{fname}.sfv","wb")
    fn.write(Marshal::dump([@word,@moves,@score,@used_guesses,@guess_space,@display_string]))
    fn.close
    puts "File saved"
    displayer
    return
  end

  def loader #load savefile routine
    filefound = false
    until filefound
      puts "Enter savefile name"
      fname = gets.chomp
      if File.exist?("#{fname}.sfv")
        filefound = true
      else
        puts "File not found"
      end
    end
    fn = File.open("#{fname}.sfv","rb")
    details = Marshal::load(fn)
    @word,@moves,@score,@used_guesses,@guess_space,@display_string = details
    puts "File loaded"
    displayer
    return
  end

  def master # controller method for the game
    @display_string = [] #display string shows _ marks and correct guesses
    @word.length.times {@display_string.push("_")}
    #initial greeting
    puts "Welcome to Hangman"
    puts "Guess the word! You have #{@moves} guesses"
    puts @display_string.join("  ")
    puts ""

    while @score > 0 && @moves > 0 #main game loop, games continues until all letters guessed, or running out of moves
      puts ""
      puts "Enter guess | rr - restart game | ss - save game | ll - load game"
      match = false #flag variable
      until match #input validator
        @response = gets.chomp.downcase
        if @response == "rr"
          initialize
        elsif @response == "ss"
          saver
        elsif @response == "ll"
          loader
        elsif @response.length != 1
          puts "Please enter single character"
          next
        else
          if @guess_space.include?(@response)
            match = true
            @guess_space.delete(@response)
          else
            puts "Invalid/repeat guess"
          end
        end
      end

      @used_guesses += "#{@response}, "

      match = false #reset flag
      (0..@word.length).each do |x| #check if response if correct
        if @word[x] == @response
          @score -= 1
          @display_string[x] = @response
          match = true
        end
      end
      @moves -= 1 unless match #deduct move for each incorrect guess
      displayer
    end

    if @score == 0 # print game result
      puts "Congratulation! You won, your score is #{@moves}"
    else
      puts "You lost. The word was #{@word.join()}"
    end
    exit
  end
end

t = Hangman.new() #startup the game
