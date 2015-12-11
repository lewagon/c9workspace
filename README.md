## Build

```bash
docker build -t lewagon/c9workspace .
```

## Run


```bash
# On host
docker run -i -t -p 3000:3000 lewagon/c9workspace bash
```

```bash
# In container
cd workspace
rails new -T --database=postgresql test-in-container
cd test-in-container
git init
git add .
git commit -m "rails new"
sudo service postgresql start
rake db:create
rails g scaffold restaurant name description:text
rake db:migrate
rails s -b 0.0.0.0
```

```bash
# On host
open "http://$(docker-machine ip default):3000"
```