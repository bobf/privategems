FROM ruby:2.7.5

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle config set without 'development test' && bundle install

COPY . /usr/src/app

ENV RACK_ENV production
CMD ["bundle", "exec", "unicorn", "-c", "unicorn.rb"]
