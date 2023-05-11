# frozen_string_literal: true
# coding: utf-8
require 'selenium-webdriver'
require_relative './account_info'

# Application class (OHR)
class OrderHistoryReporter
  include AccountInfo

  def initialize(account_file)
    @account = read(account_file)
    @amazon = AmazonManipulator.new
  end

  def collect_order_history
    title = @amazon.open_order_list
    puts title
    @amazon.change_order_term
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

# Service class
class AmazonManipulator
  include Selenium::WebDriver::Error # <1>

  BASE_URL = 'https://www.amazon.co.jp/'

  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @wait = Selenium::WebDriver::Wait.new(timeout: 20)
  end

  def login(account)
    open_top_page
    open_login_page
    enter_mail_address(account[:email])
    enter_password(account[:password])
    wait_for_logged_in
  end

  def logout
    open_nav_link_popup
    wait_for_logged_out
  end

  def open_order_list
    element = @driver.find_element(:id, 'nav-orders')
    element.click
    @wait.until { @driver.find_element(:id, 'navFooter').displayed? }
    @driver.title
  end

  def change_order_term
    years = @driver.find_element(:name, 'orderFilter')
    select = Selenium::WebDriver::Support::Select.new(years)
    select.select_by(:value, 'year-2019')
    @wait.until { @driver.find_element(:id, 'navFooter').displayed? }
  end

  def collect_ordered_items
    order_infos = {}  # <1>

    orders_container = @driver.find_element(:id, 'ordersContainer') # <2>

    orders = orders_container.find_elements(:class, 'order') # <3>
    orders.each do |order|
      key = order.find_element(:tag_name, 'bdi').text # <4>
      order_infos[key] = {} # <5>

      info = order.find_element(:class, 'order-info') # <6>

      right = info.find_element(:class, 'a-col-right') # <7>
      label = right.find_element(:class, 'label').text
      value = right.find_element(:class, 'value').text
      order_infos[key][label] = value

      left = info.find_element(:class, 'a-col-left') # <8>
      cols = left.find_elements(:class, 'a-column')
      cols.each do |col|
        begin
          label = col.find_element(:class, 'label')
        rescue NoSuchElementError # <9>
          # p 'no such element error'
          next
        end

        label = label.text
        value = col.find_element(:class, 'value').text
        order_infos[key][label] = value
      end

      order_infos[key]['明細'] = [] # <10>

      selector = 'div:nth-child(2) .a-fixed-left-grid-col.a-col-right' # <11>
      details = order.find_elements(:css, selector) # <12>

      details.each do |detail_rows| # <13>
        rows = detail_rows.find_elements(:class, 'a-row')
        row_array = []
        rows.each do |row|
          row_array.push(row.text)
        end
        order_infos[key]['明細'].push(row_array.uniq) # <14>
      end
    end
    order_infos # <15>
  end

  private

  def wait_and_find_element(how, what)
    @wait.until { @driver.find_element(how, what).displayed? }
    @driver.find_element(how, what)
  end

  def open_top_page
    @driver.get BASE_URL
    wait_and_find_element(:id, 'navFooter')
  end

  def open_login_page
    element = wait_and_find_element(:id, 'nav-link-accountList')
    element.click
  end

  def enter_mail_address(email)
    element = wait_and_find_element(:id, 'ap_email')
    element.send_keys(email)
    @driver.find_element(:id, 'continue').click
  end

  def enter_password(password)
    element = wait_and_find_element(:id, 'ap_password')
    element.send_keys(password)
    @driver.find_element(:id, 'signInSubmit').click
  end

  def wait_for_logged_in
    wait_and_find_element(:id, 'nav-link-accountList')
  end

  def open_nav_link_popup
    element = wait_and_find_element(:id, 'nav-link-accountList')
    @driver.action.move_to(element).perform
  end

  def wait_for_logged_out
    element = wait_and_find_element(:id, 'nav-item-signout')
    element.click
    wait_and_find_element(:id, 'ap_email')
    @driver.quit
  end
end

if __FILE__ == $PROGRAM_NAME
  abort 'account file not specified.' unless ARGV.size == 1
  app = OrderHistoryReporter.new(ARGV[0]) # <1>
  app.run
end
