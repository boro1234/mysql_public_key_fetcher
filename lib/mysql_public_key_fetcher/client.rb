# lib/mysql_public_key_fetcher/client.rb
require 'socket'

module MysqlPublicKeyFetcher
  class Client
    def initialize(host:, port: 3306)
      @host = host
      @port = port
    end

    def receive_handshake
      socket = TCPSocket.new(@host, @port)
      packet = socket.readpartial(512)
      socket.close

      puts "Received #{packet.bytesize} bytes"
      puts "First few bytes (hex): #{packet.bytes[0..15].map { |b| sprintf('%02X', b) }.join(' ')}"
      extract_version_string(packet)
    end

    private

    def extract_version_string(packet)
      # ハンドシェイクパケットは最初の5バイトを除いたところにバージョン文字列が入っている
      version_offset = 5  # 4バイト: packet length + 1バイト: packet number
      version_str = packet[version_offset..].split("\x00").first
      puts "MySQL server version: #{version_str}"
    end
  end
end
