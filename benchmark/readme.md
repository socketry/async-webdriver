# Comparison

This is a comparison of a small test suite. The more tests you have, the bigger the parallelization benefit.

## Selenium Sequential (56s)

```
samuel@aiko ~/P/o/socketry.io (modernize-selenium)> time bundle exec sus
12 passed out of 12 total (52 assertions)
🏁 Finished in 56.6s; 0.919 assertions per second.
🥲 You should write more tests (12/20)!
💔 Ouch! Your test suite performance is painful (0.9 < 10)!
🐢 Slow tests:
	17.5s: describe pages/customer with existing customer with product subscription it can pay for a subscription using a new credit card that requires authentication test/pages/customer.rb:212
	10.2s: describe pages/customer with existing customer with product subscription it can pay for and then cancel a subscription test/pages/customer.rb:235
	9.7s: describe pages/customer with existing customer with product subscription it can pay for a subscription using new credit card test/pages/customer.rb:191
	4.3s: describe pages/customer with existing customer it can reset the password test/pages/customer.rb:130
	3.3s: describe pages/customer with existing customer it can log in and log out test/pages/customer.rb:115
	3.2s: describe pages/customer with existing customer it can't sign up with same email address test/pages/customer.rb:94
	3.2s: describe pages/customer it can create a new customer test/pages/customer.rb:21
	1.6s: describe pages/customer it cannot create new customer without accepting terms of service test/pages/customer.rb:40
	1.5s: describe pages/customer with invalid account details it can log in and log out test/pages/customer.rb:61
	1.3s: describe website with interactive session it can visit the front page test/website.rb:28
	617.7ms: describe Socketry::Database it can synchronize from stripe test/socketry/database.rb:8

________________________________________________________
Executed in   56.99 secs    fish           external
   usr time    8.88 secs    0.00 micros    8.88 secs
   sys time    3.15 secs  458.00 micros    3.15 secs
```

## Selenium Parallel (18s)

```
samuel@aiko ~/P/o/socketry.io (modernize-selenium)> time bundle exec sus-parallel
12 passed out of 12 total (52 assertions)
🏁 Finished in 18.2s; 2.86 assertions per second.
🥲 You should write more tests (12/20)!
💔 Ouch! Your test suite performance is painful (2.9 < 10)!
🐢 Slow tests:
	17.9s: describe pages/customer with existing customer with product subscription it can pay for a subscription using a new credit card that requires authentication test/pages/customer.rb:212
	10.4s: describe pages/customer with existing customer with product subscription it can pay for and then cancel a subscription test/pages/customer.rb:235
	10.2s: describe pages/customer with existing customer with product subscription it can pay for a subscription using new credit card test/pages/customer.rb:191
	5.3s: describe pages/customer with existing customer it can reset the password test/pages/customer.rb:130
	3.9s: describe pages/customer with existing customer it can log in and log out test/pages/customer.rb:115
	3.6s: describe pages/customer with existing customer it can't sign up with same email address test/pages/customer.rb:94
	3.3s: describe pages/customer it can create a new customer test/pages/customer.rb:21
	2.6s: describe pages/customer it cannot create new customer without accepting terms of service test/pages/customer.rb:40
	1.6s: describe pages/customer with invalid account details it can log in and log out test/pages/customer.rb:61
	1.4s: describe website with interactive session it can visit the front page test/website.rb:28
	665.5ms: describe Socketry::Database it can synchronize from stripe test/socketry/database.rb:8

________________________________________________________
Executed in   18.46 secs    fish           external
   usr time    9.42 secs    0.00 micros    9.42 secs
   sys time    3.71 secs  404.00 micros    3.71 secs
```

## Async::WebDriver Sequential (52s)

```
> time bundle exec sus
12 passed out of 12 total (52 assertions)
🏁 Finished in 51.8s; 1.004 assertions per second.
🥲 You should write more tests (12/20)!
💔 Ouch! Your test suite performance is painful (1.0 < 10)!
🐢 Slow tests:
	17.4s: describe pages/customer with existing customer with product subscription it can pay for a subscription using a new credit card that requires authentication test/pages/customer.rb:212
	10.0s: describe pages/customer with existing customer with product subscription it can pay for and then cancel a subscription test/pages/customer.rb:235
	9.2s: describe pages/customer with existing customer with product subscription it can pay for a subscription using new credit card test/pages/customer.rb:191
	3.3s: describe pages/customer with existing customer it can reset the password test/pages/customer.rb:130
	3.1s: describe pages/customer it can create a new customer test/pages/customer.rb:21
	2.7s: describe pages/customer with existing customer it can't sign up with same email address test/pages/customer.rb:94
	2.7s: describe pages/customer with existing customer it can log in and log out test/pages/customer.rb:115
	998.3ms: describe pages/customer it cannot create new customer without accepting terms of service test/pages/customer.rb:40
	870.3ms: describe Socketry::Database it can synchronize from stripe test/socketry/database.rb:8
	853.4ms: describe pages/customer with invalid account details it can log in and log out test/pages/customer.rb:61
	726.1ms: describe website with interactive session it can visit the front page test/website.rb:28

________________________________________________________
Executed in   52.24 secs    fish           external
   usr time   11.80 secs  267.00 micros   11.80 secs
   sys time    5.52 secs  120.00 micros    5.52 secs
```

## Async::WebDriver Parallel (17s)

```
> time bundle exec sus-parallel
12 passed out of 12 total (52 assertions)
🏁 Finished in 17.1s; 3.05 assertions per second.
🥲 You should write more tests (12/20)!
💔 Ouch! Your test suite performance is painful (3.0 < 10)!
🐢 Slow tests:
	16.8s: describe pages/customer with existing customer with product subscription it can pay for a subscription using a new credit card that requires authentication test/pages/customer.rb:212
	10.1s: describe pages/customer with existing customer with product subscription it can pay for and then cancel a subscription test/pages/customer.rb:235
	9.8s: describe pages/customer with existing customer with product subscription it can pay for a subscription using new credit card test/pages/customer.rb:191
	3.8s: describe pages/customer with existing customer it can reset the password test/pages/customer.rb:130
	3.2s: describe pages/customer with existing customer it can log in and log out test/pages/customer.rb:115
	2.7s: describe pages/customer with existing customer it can't sign up with same email address test/pages/customer.rb:94
	2.7s: describe pages/customer it can create a new customer test/pages/customer.rb:21
	1.5s: describe pages/customer it cannot create new customer without accepting terms of service test/pages/customer.rb:40
	1.2s: describe pages/customer with invalid account details it can log in and log out test/pages/customer.rb:61
	1.2s: describe website with interactive session it can visit the front page test/website.rb:28
	618.1ms: describe Socketry::Database it can synchronize from stripe test/socketry/database.rb:8

________________________________________________________
Executed in   17.33 secs    fish           external
   usr time    6.67 secs  391.00 micros    6.67 secs
   sys time    2.21 secs    0.00 micros    2.21 secs
```
