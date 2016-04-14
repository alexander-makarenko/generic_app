## About

A simple Ruby on Rails project ready to be deployed on Heroku.

## Key features

- a *Bootstrap*-based UI;
- server-side validations;
- authentication (based on *has_secure_password*);
- email confirmation;
- password recovery;
- authorization (based on *Pundit*);
- user profile, user roles (admin, user);
- image uploads (via *jQuery-File-Upload* and *Paperclip*);
- internationalization and localization (English, Russian);
- some Ajax: login via a modal, endless scrolling, table sorting and more;
- a comprehensive test suite (*RSpec*, *Capybara*, *Jasmine*);
- *Amazon S3* for storing user images in production;
- *SendGrid* for sending emails in production.

## Live demo

See this project deployed and running at [https://twilight-glade.herokuapp.com/](https://twilight-glade.herokuapp.com/).

### How to use

1. Click *Sign in* on the navbar.

2. Sign in as an admin with `admin@twilight-glade.herokuapp.com` / `qwerty`.

3. Click around to see what's possible.

4. Optionally, register your own (non-admin) account to try out the email features.