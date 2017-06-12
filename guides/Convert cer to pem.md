# Convert Pem Certificate to Cer

**Note** This Section is extracted from this great [article](https://blog.serverdensity.com/how-to-build-an-apple-push-notification-provider-server-tutorial/) by David Mytton

The first thing you need is your Push certificates. These identify you when communicating with APNS over SSL.

## Generating the Apple Push Notification SSL certificate on Mac:

- Log in to the iPhone Developer Connection Portal and click App IDs
Ensure you have created an App ID without a wildcard. Wildcard IDs cannot use the push notification service. For example, our iPhone application ID looks something like AB123346CD.com.serverdensity.iphone

- Click Configure next to your App ID and then click the button to generate a Push Notification certificate. A wizard will appear guiding you through the steps to generate a signing authority and then upload it to the portal, then download the newly generated certificate. This step is also covered in the Apple documentation.
Import your aps_developer_identity.cer into your Keychain by double clicking the .cer file.
Launch Keychain Assistant from your local Mac and from the login keychain, filter by the Certificates category. You will see an expandable option called “Apple Development Push Services”

- Expand this option then right click on “Apple Development Push Services” > Export “Apple Development Push Services ID123”. Save this as apns-dev-cert.p12 file somewhere you can access it.

- Do the same again for the “Private Key” that was revealed when you expanded “Apple Development Push Services” ensuring you save it as apns-dev-key.p12 file.
These files now need to be converted to the PEM format by executing this command from the terminal:

```
openssl pkcs12 -clcerts -nokeys -out apns-dev-cert.pem -in apns-dev-cert.p12
openssl pkcs12 -nocerts -out apns-dev-key.pem -in apns-dev-key.p12
```

- If you wish to remove the passphrase, either do not set one when exporting/converting or execute:

```
openssl rsa -in apns-dev-key.pem -out apns-dev-key-noenc.pem
```

It is a good idea to keep the files and give them descriptive names should you need to use them at a later date. The same process above applies when generating the production certificate.
