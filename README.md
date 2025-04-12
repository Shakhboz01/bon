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

1 For admin, in telegram add product entry
2 Remove oformit prixod tovara from site
3 Add verified_by_factory:boolean to sale portion, only admin can access
4 In pack remaining, add to remaining those sale portions whose verified_by_factory is false
5 Fix adding a new buyer
6 Add a new attributes if necessary like INN
7 Add screen video for agents to demonstrate how it works
8 Tell Doniyor to call me after his agents submited orders
9 Change prices
10 Add photos to packs