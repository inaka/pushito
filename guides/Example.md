# Pushing notifications with Knuff and Pushito

We are going to push some notifications using `pushito` and [Knuff](https://github.com/KnuffApp/Knuff).

In order to push notifications we need 3 actors, a _Provider_, _APNs_ and the _Client App_. Only the _Provider_ and the _Client App_ matters for us:

- For the _Provider_ we are going to use `pushito`
- For the _Client App_ we are going to take advantage of Knuff and all the infrastructure they already have. The client App we are going to use is [Knuff IO](https://itunes.apple.com/us/app/knuff-the-apns-debug-tool/id993435856)

## Our Plan

What we want:
- Write a simple _Provider_ using `Pushito`
- Push messages to `Knuff IO` thru APNs platform

What we need:
- Download `Pushito` from [Hex.pm](https://hex.pm/packages/pushito)
- Install `Knuff IO` in our IOs device (Ipad or Iphone)
- Find out the `Knuff`s APNs info (like certificates, apns_topic, Device Id...)

## Push Notifications with Knuff

Knuff is a great application. It is not only an IOs app, it also has a desktop application which allows us to send notifications to our `knuff IOs`. We don't want to use it because we want to send them thru our _Provider_ but we can use it in order to get the certificate, device Id and topic. Lets see how to push something with Knuff.

- Install `Knuff` in your Computer (find it [here](https://github.com/KnuffApp/Knuff/releases))
- Install `Knuff IO` in your device (find it on the [store](https://itunes.apple.com/us/app/knuff-the-apns-debug-tool/id993435856))
- Open `Knuff` in your computer

![Alt text](assets/Example/knuff-Desktop-1.png?raw=true "Knuff Desktop")

- Open `Knuff IO` on your device. In your computer you will see a new "devices" section

![Alt text](assets/Example/knuff-Desktop-2.png?raw=true "Knuff Desktop")

- Click on "devices" and select your IOs device

![Alt text](assets/Example/knuff-Desktop-3.png?raw=true "Knuff Desktop")

- This `token` is actually the `device_id`, save it! we will need it later

![Alt text](assets/Example/knuff-Desktop-4.png?raw=true "Knuff Desktop")

- Now we need to select the certificate. Click on "Choose" button and select the Certificate:

![Alt text](assets/Example/knuff-Desktop-5.png?raw=true "Knuff Desktop")

- Now it seems we have all we need to send a notification thru Knuff.

![Alt text](assets/Example/knuff-Desktop-6.png?raw=true "Knuff Desktop")

- Close your `Knuff IO` app in your phone (Remember, APNs only makes sense if the app is not running!). Click on "Push" Button.

![Alt text](assets/Example/knuff-IOs-1.png?raw=true "Knuff IOs")

It worked! that means we have all what we need in order to push notifications.

## Get the APNs info from Knuff

We said before we need the `device_id`, `certificate` and `topic` in order to use pushito instead of Knuff Desktop. We got the `device_id` in the previous section so we need the `certificate` and the topic.

We saw we already have the certificate because we selected when we chose the identity in knuff. The problem is it is stored in the Keychain. In order to extract it from Keychain we are going to follow these steps:

- Open Keychain and expand the Knuff certificate, there you can see the certificate and its key

![Alt text](assets/Example/keychain-1.png?raw=true "Keychain")

- Right click on “Apple Push Services: com.madebybowtie.Knuff-IOs...” > Export “Apple Push Services: com.madebybowtie.Knuff-IOs...”

![Alt text](assets/Example/keychain-2.png?raw=true "Keychain")

- Save the file as `apns-cert.p12` in a place you can access it later.

- Repeat the steps with the key and store it as `apns-cert.p12`

![Alt text](assets/Example/keychain-3.png?raw=true "Keychain")

- Great! we have the certificate and the key but we still have a problem. Pushito accepts `.pem` files not `.p12`, so lets convert them. In order to do that we have to use the console:

```
openssl pkcs12 -clcerts -nokeys -out apns-cert.pem -in apns-cert.p12
openssl pkcs12 -nocerts -out apns-key.pem -in apns-key.p12
```

- If you wish to remove the passphrase, either do not set one when exporting/converting or execute:

```
openssl rsa -in apns-key.pem -out apns-key-noenc.pem
```

Thats all, we have the 3 things we need:

- `device_id` we got it on the previous section
- `certificates`, here we have to files we are about to need, the certificate file `apns-cert.pem` and the key file `apns-key-noenc.pem`
- `topic` we didn't talk about it yet. the `apns-topic` is an identifier of our application. It is simple to find it, just open `apns-cert.pem` file an you will see it there. In our case the topic is `com.madebybowtie.Knuff-iOS`

## Good Bye Knuff, Pushito is in town now

We have all what we need. We are going to work now with the _Provider_. It is going to be a very simple code, just for have an idea `Pushito` can do.

lets create a new mix project:

```
$ mix new pusher
$ cd pusher
```

We have a `lib/pusher.ex` file created. We are going to add almost all of our code in that module.

First we need to add `pushito` as a dependency. in your `mix.exs` file add:

```elixir
{:pushito, "~> 0.1.0"}
```

on the same file we have to tell Elixir to start `Pushito` when starting `pusher`

```elixir
[extra_applications: [:logger, :pushito]]
```

Getting the dependencies:

```
$ mix deps.get
```

Lets create a function for start the connection. First we have saved our certificate and key files in `priv/` folder. We are working with production so the apple host is `api.push.apple.com`
We have to create a config file before create the connection and then we can connect to apns:

```elixir
def create_connection do
  import Pushito.Config

  config = new()
           |> add_name(:knuff_connection)
           |> add_type(:cert)
           |> add_host("api.push.apple.com")
           |> add_cert_file("priv/apns-cert.pem")
           |> add_key_file("priv/apns-key-noenc.pem")

  {:ok, _pid} = Pushito.connect config
  :ok
end
```

Great, now we need a function which send notifications. We are going to create notifications with the same format Knuff does, remember:

![Alt text](assets/Example/notification-format.png?raw=true "Knuff Desktop")

So our notification will be something like this in Elixir:

```elixir
notification = %{"aps" =>
                  %{"alert" => "Test",
                    "sound" => "default",
                    "badge" => 1}
                }
```

Lets build our function based on that:

```elixir
def push(message) do
  import Pushito.Notification

  apns_topic = "com.madebybowtie.Knuff-iOS"
  device_id = "bd5c3ad01bbe4d884bf2fe8801ed77e94a71bc2e9de937c84f745f54eb4cb2f4"

  body = %{"aps" =>
            %{"alert" => message,
              "sound" => "default",
              "badge" => 1}
          }

  notification = new()
                 |> add_device_id(device_id)
                 |> add_topic(apns_topic)
                 |> add_message(body)

  Pushito.push :knuff_connection, notification
end
```



Launch `pusher`

```
iex -S mix
```


```
iex(1)> Pusher.create_connection
:ok
iex(2)> Pusher.push "Ey! you have a new message!"
%Pushito.Response{body: :no_body,
 headers: [{"apns-id", "ECDB2E47-5E98-7D43-B17A-67B9409CB548"}], status: 200}
```

And I get...

![Alt text](assets/Example/knuff-IOs-2.png?raw=true "Knuff IOs")

Yeah! we did it!. Now you know how `pushito` works
