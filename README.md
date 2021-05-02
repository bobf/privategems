# Private Gems

_RubyGems_ compatible server for hosting private gems. Based (heavily) on [Geminabox](https://github.com/geminabox/geminabox).

Public gems are proxied automatically via [https://rubygems.org/](https://rubygems.org/).

Browse available private gems in your web browser via the front end (served on the same host/port as the back end server).

## Running a Server

### Docker

The server is most easily launched as a _Docker_ image. Environment variables for the user config and data directories must be provided.

```bash
docker run \
  --volume /path/to/data/directory:/privategems/data \
  --volume /path/to/users.yml:/privategems-users.yml \
  --env SECRET_KEY_BASE=my-secure-cookie-secret \
  --publish 8080:8080 \
  bobfarrell/privategems
```

You will be able to access the application at http://localhost:8080/

* `PRIVATE_GEMS_DATA_PATH` must point to an existing directory with read/write access.
* `PRIVATE_GEMS_USERS_PATH` must point to a `.yml` file with read/write access. See below for more details on how to create this file.

It is strongly recommended that you use a web server like [_Nginx_](https://www.nginx.com/) to proxy requests to _Private Gems_. If your server is accessible over the public internet then _SSL_ should be enabled.

### Other

If you want to run with some other custom configuration then you can start by running the _Rack_ server:

```bash
bundle exec rackup config.ru
```

Running a production-ready web server etc. will be up to you.

## Users Configuration

User configuration uses a _YAML_ file to provide the available users and their role. Two roles are available:

* `developer` - can browse the front end and download gems (either from the front end or via the `gem` command or with _Bundler_ etc.)
* `admin` - can do everything a `developer` can do as well as upload new gems and delete existing gems.

When a user signs in (see below) for the first time an API key will be automatically generated and the users configuration will be updated.

The configuration adheres to the following format:

```yaml
---
users:
- username: alex@example.com
  password: alexiscool
  role: developer
- username: chris@example.com
  password: alexsucks
  role: developer
- username: jenkins
  password: iamjenkins
  role: admin
  api_key: XbhH2y36FtHmc8ljOcw6ws48JcVN70um
```

## Authentication

Sign in to the _RubyGems_ server with your username and password to retrieve your API key:

```bash
gem signin --host https://<your-rubygems-host>
```

This will automatically update your _Gem_ configuration (`~/.gem/credentials`) with your new API key.

### Bundler Authentication

_Bundler_ can be configured to automatically use your credentials to access the private _RubyGems_ server. Set the environment variable `BUNDLER_RUBYGEMS__MYHOST__COM` (for `https://rubygems.myhost.com`).

```bash
# ~/.bash_profile
export BUNDLER_RUBYGEMS__MYHOST__COM=myusername:mypassword
```

## Gemfile configuration

Replace the typical `source` line with the custom configuration:

```ruby
source "https://<your-rubygems-host>"
```

All private gems will now be available.
