require "curses"
include Curses

class Freqchange
    def initialize 
      @currentfreq =  7.0
      @hop = 0.042
      @multiplier = 4
      @command = "usbsoftrock"
      @freqchange = "set freq"
      @setfreqcommand = "#{@command} -m #{@multiplier} #{@freqchange} "
      init_screen
      noecho
      stdscr.keypad(true)
      getinitfreq
      writefreq
      #mainloop
      keyget
    end

    def getinitfreq
      IO.popen("#{@command} -m #{@multiplier} getfreq") { |io|
        while (line = io.gets) do
          curma = line.match(/Frequency\s+:\s+([0-9]+.[0-9]+)/)
          if curma and curma.size > 1
            @currentfreq = curma[1].to_f
          end
        end
      }
    end

    def setfreq
      system(@setfreqcommand + @currentfreq.to_s + "> /dev/null" )
      writefreq
    end

    def write(line, column, text)
      setpos(line, column)
      addstr(text);
    end

    def writefreq
      clear
      write(0,0,@currentfreq.to_s + " MHz")
    end


    def keyget
      begin
      manfrequency = ""
      while line = Curses.getch
        case line 
	      when Curses::Key::UP then
    	    @currentfreq += @hop
            setfreq
	      when Curses::Key::DOWN then
    	    @currentfreq -= @hop
            setfreq
	      when /[0-9,.]/ then
	        manfrequency += line
	      when 10 then
	        if manfrequency
	          @currentfreq = manfrequency.to_f
              setfreq
              manfrequency = ""
            end
          when Curses::Key::DC then
	        puts manfrequency.class
          when 'q' then
    	    break
    	  else
    	    clear
    	    #write(0,0,line.to_s)
      end
    end
    ensure 
      close_screen
    end
  end
end

Freqchange.new