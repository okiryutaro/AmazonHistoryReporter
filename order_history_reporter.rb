
require 'optparse'
require_relative './account_info'
require_relative './amazon_manipulator07.rb'
# Application class (OHR)
class OrderHistoryReporter
  include AccountInfo

  def initialize(argv)
    @order_term = 'last30'
    parse_options(argv)
    @account = read(@account_file)
    @amazon = AmazonManipulator.new
  end

  def parse_options(argv)
    opts = OptionParser.new
    opts.banner = 'Usage: ruby order_history_reporter.rb [options]'
    opts.program_name = 'Order History Reporter'
    opts.version = [0, 2]
    opts.release = '2020-09-12'

    opts.on('-t TERM', '--term TERM', '注文履歴を取得する年を指定する') do |t| # <1>
        term = 'last30' if t =~ /last/
        term = 'months-3' if t =~ /month/
        term = 'archived' if t =~ /arc/
        term = "year-#{$1}" if t =~ /(\d\d\d\d)/
        @order_term = term
    end

    opts.on_tail('-a ACCOUNT', '--account ACCOUNT','アカウント情報ファイルを指定する') do |a|
        @account_file = a
    end

    opts.on_tail('-v', '--version', 'バージョンを表示する') do
        puts opts.ver
        exit
    end

    begin
      opts.parse!(argv)
      puts "取得期間: #{@order_term}" # <3>
    rescue OptionParser::InvalidOption => e
      puts opts.help
    end
  end

  def collect_order_history
    title = @amazon.open_order_list
    puts title
    @amazon.change_order_term(@order_term)
    @amazon.collect_ordered_items
  end

  def make_report(order_infos) # <1>
    puts "#{order_infos.size} 件" # <2>
    order_infos.each do |id, rec| # <3>
      puts "ID: #{id}"
      rec.each do |key, val| # <4>
        puts format '%s: %s', key, val
      end
    end
  end

  def run
    @amazon.login(@account)
    order_infos = collect_order_history # <5>
    @amazon.logout
    make_report(order_infos) # <6>
  end
end


if __FILE__ == $PROGRAM_NAME
    app = OrderHistoryReporter.new(ARGV) # <1>
    app.run
end