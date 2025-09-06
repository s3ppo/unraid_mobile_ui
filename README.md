# Unraid Mobile UI

GraphQL client app using flutter to show data from your unraid server.
Once there are more features included in unraid connect plugin it will be published on Google Play and IOS Appstore.

# API Key

If you wonder how to get your API Key.
Open a terminal in your Unraid console and enter:
```sh
unraid-api apikey --create
```

# Beta / Testflight
Want to help me testing? Here is my testflight link :-)

iOS:
https://testflight.apple.com/join/P1XCE1ym

Android:
https://play.google.com/apps/testing/com.hw.unraidui

# Screenshots
<table>
    <tr>
        <td>
            <img src="https://github.com/s3ppo/unraid_mobile_ui/blob/main/assets/dashboard.png" width="300">
        </td>
        <td>
            <img src="https://github.com/s3ppo/unraid_mobile_ui/blob/main/assets/menu.png" width="300">
        </td>
    <tr>
    <tr>
        <td>
            <img src="https://github.com/s3ppo/unraid_mobile_ui/blob/main/assets/array.png" width="300">
        </td>
        <td>
            <img src="https://github.com/s3ppo/unraid_mobile_ui/blob/main/assets/dockers.png" width="300">
        </td>
    </tr>
    <tr>
        <td>
            <img src="https://github.com/s3ppo/unraid_mobile_ui/blob/main/assets/vms.png" width="300">
        </td>
        <td>
            &nbsp;
        </td>
    </tr>
</table>

# Troubleshooting

Connection Issues
- Before 7.2.0 beta Unraid Connect Plugin has to be installed<br/>
- Check if your port is correct (it has to be the same that you are using for your Unraid Web Login)<br/>
- Check if you can reach /graphql endpoint in browser (http(s)://ip:port/graphql)<br/>
- App settings/authorizations on your device, 'Local Area Network' has to be allowed<br/>
