# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Webview by amount_in_pack
One button to send data to sklad (create a table WholesaleReport from:datetime, till:Datetime)
Inside WholesaleReport#show display sales, if agent_diller is present: display only for agent user
After create send report to telegram with link, grouped by AgentDiller
Fix the way product_sell.amount is defined, display amount_per_pack and remaining out of pack if exists
Fix monthly/daily report
Add ability to update buyers location for agents
