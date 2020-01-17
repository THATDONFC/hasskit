## HassKit Mobile App Guide

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_6.png)
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_4.png)

The new version bring a deeper integration into Home Assistant. You can now register #HassKit as a Mobile App and allow sending notification and update location directly into Home Assistant. No additional custom component required.

To enable this feature, please follow these 3 easy steps

## 1. Register Mobile App

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_1.png)
<br>Click Register to regist HassKit as an Home Assistant's Mobile App
<br><br>
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_2.png)
<br>Then Restart Home Assistant

## 2. View Mobile App Location History

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_3.png)
<br>Add the newly registered Mobile App to room's screen.
<br><br>
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_4.png)
<br>Open the device to see location's history

## 3. Send Notification with Picture

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_5.png)
<br>HassKit registered device will appear as a Mobile App, you can send notification directly into the device without additional custom component.
<br><br>
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_6.png)
<br>Notification now support image and sound.

## 4. Delete Mobile App Integration
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_7.png)
<br>Go to Home Assistant > Configuration > Integrations > Mobile App: <App Name> and click the recycle bin icon.

## 5. Automatically send Notification to HassKit

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_9.png)

First, we need to edit ***configuration.yaml*** by adding the following line:

Allow Home Assistant write file into www folder:
```
homeassistant:
  whitelist_external_dirs:
    - /config/www
```

Add notify.ALL_DEVICES service:
<br>
(Replace mobile_app_hasskit_mobile_app_1 with your registered device name)
```
notify:
  - name: ALL_DEVICES
    platform: group
    services:
      - service: mobile_app_hasskit_mobile_app_1
      - service: mobile_app_hasskit_mobile_app_2
      - service: mobile_app_hasskit_mobile_app_3
```

Send a notification whenever garage door is opened:
<br>
(Replace http://hasskit.duckdns.org:8123/local/camera_1.jpg with your own data)
```
automation:
  - alias: 'Notify when garage door opened'
    trigger:
    - entity_id: cover.garage_door
      platform: state
      to: "open"
    action:
    - data_template:
        entity_id: camera.camera_1
        filename: /config/www/camera_1.jpg
      service: camera.snapshot
    - delay:
        seconds: 1
    - data_template:
        title: Garage Door 
        message: Opened
        data:
          image: http://hasskit.duckdns.org:8123/local/camera_1.jpg
      service: notify.ALL_DEVICES   
```
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_8.png)
<br>
<br>
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_10.png)

## 6. Troubleshooting

### Error 404 during Mobile App registration:
- Make sure you have ***default_config:*** in configuration.yaml
- If you don't, add this line to configuration.yaml and restart Home Assistant
```
mobile_app:
```
https://developers.home-assistant.io/docs/en/app_integration_setup.html

## 7. iPhone Location Tracking, Always Allow
By default, iOS will only allow HassKit to track your location `While Using the App`. If you want you can allow HassKit to be able to update your location always.

1. Open iOS `Settings`.
2. Go into: `Privacy` > `Location Services`.
3. Find `HassKit` in the list and click it.
4. Change `Allow Location Access` to `Always`.
