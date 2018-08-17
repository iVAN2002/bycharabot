require "fast_irc"
require "file"
require "yaml"
require "socket"
require "regex"

# TODO: Write documentation for `Bycharabot`
class Bycharabot
  VERSION = "0.1.0"

  @server = ""
  @port = 6667
  @connection_timeout = 10
  @vote_kick = 5
  @nickname = "Bychara"
  @channels = [] of String
  @regex = [] of Regex

  @lines_normal = [] of String
  @lines_bot = [] of String
  @prev_line = {} of String => Int32
  @votekick_users = [] of String

  @client = TCPSocket.new

  @logged_in = false

  @used_times = 0

  def loadAndParse
    data = YAML::Any
    if (ENV.fetch("LAUNCH_ENV", "LOCAL") == "HEROKU")
        data = YAML.parse(ENV.fetch("BOT_SETTINGS", ""))
    else
      data = YAML.parse(File.read("./config.yml"))
    end
      @server = data["server"].to_s
      @port = data["port"].as_i
      @connection_timeout = data["connection_timeout"].as_i
      @vote_kick = data["vote_kick"].as_i
      @nickname = data["nickname"].to_s
      data["channels"].as_a.each do |el|
        @channels.push(el.to_s)
        @prev_line[el.to_s] = 0
      end

      data["regex"].as_a.each do |el|
        @regex.push(Regex.new(el.to_s))
      end

    @lines_normal = File.read_lines("text.txt")

    @lines_normal.each do |line|
      new_line = line.downcase.gsub(" ", "")

      @regex.each do |el|
        new_line = new_line.gsub(el, "")
      end

      @lines_bot.push(new_line)
    end
  end

  def login
    @client << "USER #{@nickname} localhost localhost #{@nickname}\n"
    @client << "NICK #{@nickname}\n"
  end

  def joinChannel(channel : String)
    @client << "JOIN #{channel}\n"
  end

  def joinAllChannels
    @channels.each do |el|
      joinChannel("#" + el.to_s)
    end
  end

  def sendPrivateMessage(channel : String, text : String)
    @client << "PRIVMSG #{channel} :#{text}\n"
  end

  def answer(message : FastIRC::Message)
    channel = message.params[0].gsub("#", "")
    msg = message.params[1].downcase.gsub(" ", "")
    @regex.each do |el|
      msg = msg.gsub(el, "")
    end

    if (@prev_line[channel]? == false)
      @prev_line[channel] = 0
    end

    found = false
    i = 0
    @lines_bot.each do |line|
      if (line == msg)
        found = true
        break
      end
      i += 1
    end

    if (found)
      found = false
      @used_times += 1
      if (i == (@lines_bot.size - 1))
        @prev_line[channel] = 0
        return
      end
      if (i < @prev_line[channel])
        i_old = i
        i = 0
        @lines_bot.each do |line|
          if (i < @prev_line[channel])
            i += 1
            next
          end
          puts line
          if (line == msg)
            found = true
            break
          end
          i += 1
        end
        if (found)
          if (i == (@lines_bot.size - 1))
            @prev_line[channel] = 0
          else
            @prev_line[channel] = i + 1
            sendPrivateMessage(message.params[0], @lines_normal[@prev_line[channel]])
          end
        else
          @prev_line[channel] = i_old + 1
          sendPrivateMessage(message.params[0], @lines_normal[@prev_line[channel]])
        end
      else
        @prev_line[channel] = i + 1
        sendPrivateMessage(message.params[0], @lines_normal[@prev_line[channel]])
      end
      return
    end
    return
  end

  def run
    loadAndParse()
    @client = TCPSocket.new(@server, @port, nil, @connection_timeout)
    irc_reader = FastIRC::Reader.new(@client)

    loop do
      Signal::INT.trap do
        puts "\nCTRL-C handler here!"
        @client << "QUIT\n"
        @client.close
        puts "Bot was used #{@used_times} times."
        exit
      end

      if (@logged_in != true)
        login
        joinAllChannels
        @logged_in = true
      end

      while message = irc_reader.next
        puts message.to_s
        case (message.command)
        when "PING"
          @client << "PONG :#{message.params[0]}\n"
          break
        when "KICK"
          if (message.params[0] == @nickname)
            puts "Oops, I'm kicked!"
          end
          break
        when "PRIVMSG"
          temp_msg = message.params[1].gsub(" ", "")
          @regex.each do |el|
            temp_msg = temp_msg.gsub(el, "")
          end
          if (temp_msg == "ктотакой#{@nickname}" || temp_msg == "актотакой#{@nickname}")
            sendPrivateMessage(message.params[0], "Я - самый полезный бот. Кто не согласен, тот будет построен и зарыт.")
            @used_times += 1
          elsif (temp_msg == "кудастремятсяжидомайдауны" || temp_msg == "кудастремятсяжидомайдуны")
            sendPrivateMessage(message.params[0], "На Белград!")
            @used_times += 1
          elsif (temp_msg[0..3] == "~inv")
            temp_msg = temp_msg.sub("~inv") { "" }
            sendPrivateMessage(message.params[0], "Захожу в #{temp_msg}...")
            joinChannel(temp_msg)
            @used_times += 1
          elsif (temp_msg[0..5] == "~leave")
            sendPrivateMessage(message.params[0], "Vote Kick ещё не работает :c")
            @used_times += 1
          else
            answer(message)
          end
          break
        else
          break
        end
      end
    end
    @client << "QUIT\n"
    @client.close
  end
end

bychara = Bycharabot.new

bychara.run
