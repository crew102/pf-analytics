* should potentially pull non-dog data to get better idea of when last_update really was for a shelter
* split pet_nontrackable table into day_1 pets and blacklisted pets, so don't have to rewrite large table?
* make sure time zone used by api is same as one used by app code, and that app code uses consistent tz
* make pool object global and remove pool args from funs?
* docker volume for mysql db to persist across containers
* add tests to travis
* restrict shiny incoming requests to certain host (i.e., auth host)
* how to handle db transactions so don't write data worth half a day?
* note that "days on petfinder" isn't actually dof, it's "max(number of days since pet has been on pet finder and shelter has been active on petfinder)" 


* adding a new dog or removing a dog should be considered "activity"/sign of log in for shelter

* search by shelterid?

* if last_update on pet hasn't changed, don't update pet's var data. otherwise, update it

* "has applicaiton" listed in description
* how to handle foster
* filtering out "bad" shelters - those that don't update, etc.
* weird case when dogs without pics/descriptions adopted very quickly (less than 3 days)
* predicting "additional days on pf," not total expected days...so it would take into account how many days have already been spent

* have to account for fact that don't have data on each day

* dogs taken off then added back on in a few days (account for this)
* same dog with diff id (use size, sex, name, age to determine if should merge)
* account for changes in data (pics added, breed changed, etc)
* redefine "date taken off" as first date where dog hasn't been seen in five days

* define a pet as being "off petfinder" if it hasn't been seen in five days (id wise and "data wise")
