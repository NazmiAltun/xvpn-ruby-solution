# Automated DNS Management Coding Challenge (Ruby On Rails, July 2020)

A simple automated dns management system to manage hosted zones on Amazon Route53 service. Can add/remove predefined servers
to subdomain of hosted domain/zone on AWS Route53.It supports only  ipv4 addresses at moment.

It is hosted on Heroku (Link is removed)

## How To Run
Install the latest version of Ruby , Rails and yarn.

Clone the repo

```bash
https://github.com/xvpn-coding-challenges/xv_coding_challenge_nazmi_a.git
```

Install dependencies
```bash
bundle install
yarn install
```

### Run the App On Development Machine
```bash
rake db:migrate RAILS_ENV=development
rake db:seed RAILS_ENV=development
rails s
```
Navigate to  [http://localhost:3000/](http://localhost:3000/) and you should see dns entries

### Run Tests
```bash
rake db:migrate RAILS_ENV=test 
rspec
```

Or run tests in watch mode
```bash
guard
```

### Linting
```bash
rails_best_practices .
rubocop .
```

Set AWS Credentials in your environment
```bash
AWS_ACCESS_KEY_ID= {YOUR_AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY= {YOUR_AWS_SECRET_ACCESS_KEY}
```
After setting environment variables restart might be reequire on Windows environment.
At the moment , only one Route53 domain can be managed and it is configured in config\application.rb file as below

```
 config.zone_id = 'Z040251137DWBG4URKYPY' #AWS Route53 Hosted Zone ID
 config.domain_name = 'domain.com' # AWS Route53 Hosted Zone domain name
```

Note that,  while development and test environments use  Sqlite db , production environment requires postgresdb.
This is something enforced and automaticall handled by Heroku.

## How To Deploy Production
Login to heroku and configure

```bash
heroku login
heroku git:remote -a xv-coding-challenge-nazmi-a
```

Deploy
```bash
git push heroku master
```

Setup DB
```bash
heroku run rake db:migrate
heroku run rake db:seed
```

To configure AWS Credentials on Heroku go to Heroku dashbaord, navigate to Application Settings -> Config Vars and set credential values by using same names (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY). In addition, setting AWS_REGION might be required.

Open your heroku app on browser
