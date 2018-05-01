* should potentially pull non-dog data to get better idea of when last_update really was for a shelter
* split pet_nontrackable table into day_1 pets and blacklisted pets, so don't have to rewrite large table?
* make sure time zone used by api is same as one used by app code, and that app code uses consistent tz
* make pool object global and remove pool args from funs?
* docker volume for mysql db to persist across containers
* add tests to travis
* restrict shiny incoming requests to certain host (i.e., auth host)
* how to handle db transactions so don't write data worth half a day?
* note that "days on petfinder" isn't actually dof, it's "max(number of days since pet has been on pet finder and shelter has been active on petfinder)" 
