# README

When generating a new Web Services API endpoint controller

~~~
$ rails generate versionist:new_controller publishers Api::V1
~~~

To generate/update the Swagger JSON file(s) thru [rswag](https://github.com/domaindrivendev/rswag)

~~~
$ rake rswag:specs:swaggerize
~~~

then run the rails server and load the API doc at 

~~~
http://localhost:3000/api-docs
~~~

Run redis server 
~~~
$ redis-server
~~~

Run sidekiq
~~~
$ bundle exec sidekiq
~~~
