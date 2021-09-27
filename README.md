<a href="https://www.twilio.com">
  <img src="https://static0.twilio.com/marketing/bundles/marketing/img/logos/wordmark-red.svg" alt="Twilio" width="250" />
</a>

# Twilio SDK Starter Application for Ruby

This sample project demonstrates how to use Twilio APIs in a Ruby web
application. Once the app is up and running, check out [the home page](http://localhost:4567)
to see which demos you can run. You'll find examples for [Chat](https://www.twilio.com/chat),
[Notify](https://www.twilio.com/notify), and [Sync](https://www.twilio.com/sync).

Let's get started!

## Configure the sample application

To run the application, you'll need to gather your Twilio account credentials and configure them
in a file named `.env`. To create this file from an example template, do the following in your
Terminal.

```bash
cp .env.example .env
```

Open `.env` in your favorite text editor and configure the following values.

### Configure account information

Every sample in the demo requires some basic credentials from your Twilio account. Configure these first.

| Config Value  | Description |
| :-------------  |:------------- |
`TWILIO_ACCOUNT_SID` | Your primary Twilio account identifier - find this [in the console here](https://www.twilio.com/console).
`TWILIO_API_KEY` | Used to authenticate - [generate one here](https://www.twilio.com/console/dev-tools/api-keys).
`TWILIO_API_SECRET` | Used to authenticate - [just like the above, you'll get one here](https://www.twilio.com/console/dev-tools/api-keys).

#### A Note on API Keys

When you generate an API key pair at the URLs above, your API Secret will only be shown once -
make sure to save this information in a secure location, or possibly your `~/.bash_profile`.

### Configure Development vs Production Settings

By default, this application will run in production mode - stack traces will not be visible in the web browser. If you would like to run this application in development locally, change the `APP_ENV` variable in your `.env` file.

`APP_ENV=development`

For more about development vs production, visit [Sinatra's configuration page](http://sinatrarb.com/configuration.html).

### Configure product-specific settings

Depending on which demos you'd like to run, you may need to configure a few more values in your `.env` file.

#### Configuring Twilio Sync

Twilio Sync works out of the box, using default settings per account. Once you have your API keys configured, run the application (see below) and [open a browser](http://localhost:4567/sync)!

#### Configuring Twilio Chat

In addition to the above, you'll need to [generate a Chat Service](https://www.twilio.com/console/chat/services) in the Twilio Console. Put the result in your `.env` file.

| Config Value  | Where to get one. |
| :------------- |:------------- |
`TWILIO_CHAT_SERVICE_SID` | [Generate one in the Twilio Chat console](https://www.twilio.com/console/chat/services)

With this in place, run the application (see below) and [open a browser](http://localhost:4567/chat)!

#### Configuring Twilio Notify

You will need to create a Notify Service and add at least one credential on the [Mobile Push Credential screen](https://www.twilio.com/console/notify/credentials) (such as Apple Push Notification Service or Firebase Cloud Messaging for Android) to send notifications using Notify.

| Config Value   | Where to get one. |
| :------------- |:------------- |
`TWILIO_NOTIFICATION_SERVICE_SID` | Generate one in the [Notify Console](https://www.twilio.com/console/notify/services) and put this in your `.env` file.
A Push Credential | Generate one with Apple or Google and [configure it as a Notify credential](https://www.twilio.com/console/notify/credentials).

Once you've done that, run the application (see below) and [open a browser](http://localhost:4567/notify)!

## Run the sample application

Now that the application is configured, we need to install our dependencies with Bundler.

```bash
bundle install
```

Now we should be all set! Run the application using the `bundle exec` command.

```bash
bundle exec ruby app.rb
```

Your application should now be running at [http://localhost:4567/](http://localhost:4567/).

![Home Screen](https://cloud.githubusercontent.com/assets/809856/26252870/0bfd80ac-3c77-11e7-9252-2b19dff5d784.png)

Check your config values, and follow the links to the demo applications!

## Running the SDK Starter Kit with ngrok

If you are going to connect to this SDK Starter Kit with a mobile app (and you should try it out!), your phone won't be able to access localhost directly. You'll need to create a publicly accessible URL using a tool like [ngrok](https://ngrok.com/) to send HTTP/HTTPS traffic to a server running on your localhost. Use HTTPS to make web connections that retrieve a Twilio access token.

```bash
ngrok http 4567
```

## License
MIT
