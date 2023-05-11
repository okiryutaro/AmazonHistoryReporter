# require 'selenium-webdriver'
# require_relative './account_reader'

# abort 'account file not specified.' unless ARGV.size == 1
# account = read_account(ARGV[0])

# driver = Selenium::WebDriver.for :chrome
# wait = Selenium::WebDriver::Wait.new(timeout: 20)

# driver.get 'https://www.amazon.co.jp/'
# element = driver.find_element(:id,'nav-link-accountList')
# puts element.text
# element.click
# wait.until {driver.find_element(:id,'ap_email').displayed?}
# element = driver.find_element(:id,'ap_email')
# element.send_keys(account[:email])
# element = driver.find_element(:id,'continue')
# element.click
# wait.until {driver.find_element(:id,'ap_password').displayed?}
# element = driver.find_element(:id,'ap_password')
# element.send_keys(account[:password])
# element = driver.find_element(:id,'signInSubmit')
# element.click
# wait.until {driver.find_element(:id,'nav-link-accountList').displayed?}
# element = driver.find_element(:id,'nav-orders')
# element.click
# wait.until {driver.find_element(:id,'navFooter').displayed?}
# puts driver.title
# sleep 3
# sleep(100000000000000)
# years = driver.find_element(:id,'orderFilter')
# select = Selenium::WebDriver::Support::Select.new(years)
# select.select_by(:value,'year-2019')
# wait.until {driver.find_element(:id,'navFooter').displayed?}
# sleep 3
# driver.quit

# frozen_string_literal: true

require 'selenium-webdriver'
require_relative './account_reader'

abort 'account file not specified.' unless ARGV.size == 1
account = read_account(ARGV[0])

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(timeout: 20)

driver.get 'https://www.amazon.co.jp/'
element = driver.find_element(:id, 'nav-link-accountList')
puts element.text
element.click
wait.until { driver.find_element(:id, 'ap_email').displayed? }
element = driver.find_element(:id, 'ap_email')
element.send_keys(account[:email])
element = driver.find_element(:id, 'continue')
element.click
wait.until { driver.find_element(:id, 'ap_password').displayed? }
element = driver.find_element(:id, 'ap_password')
element.send_keys(account[:password])
element = driver.find_element(:id, 'signInSubmit')
element.click
wait.until { driver.find_element(:id, 'nav-link-accountList').displayed? }
element = driver.find_element(:id, 'nav-orders')
element.click
wait.until { driver.find_element(:id, 'navFooter').displayed? }
puts driver.title
years = driver.find_element(:name, 'orderFilter') # <1>
select = Selenium::WebDriver::Support::Select.new(years) # <2>
select.select_by(:value, 'year-2019') # <3>
wait.until { driver.find_element(:id, 'navFooter').displayed? } # <4>
selector = '#ordersContainer .order > div:nth-child(2) .a-fixed-left-grid-col.a-col-right > div:nth-child(1)'
titles = driver.find_elements(:css,selector)
puts titles.size
titles.map { |t| puts t.text}
if driver.find_elements(:class,'pagination-full').size != 0
    element = driver.find_element(:class, 'a-last')
    element.click
    wait.until { driver.find_element(:id, 'navFooter').displayed? }
    titles = driver.find_elements(:css,selector)
    puts titles.size
    titles.map { |t| puts t.text}
end
driver.quit

#ordersContainer > div:nth-child(2) > div.a-box.shipment > div > div > div > div.a-fixed-right-grid-col.a-col-left > div > div > div > div.a-fixed-left-grid-col.yohtmlc-item.a-col-right > div:nth-child(1) > a