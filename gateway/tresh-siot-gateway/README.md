# Hacking siot.net-nodejs-api to return data only.

Change this in `siot.net-nodejs-api/src/siot_sensor.js`:

```js
/**
 *  send data formmatted as serialised json. JSON structure: { time: CURRENTTIME, value: DATA}
 *
 *
 * @param {string} data the data to be send as string
 * @param {function} callback the result
 */
SiotSensor.prototype.sendSensorData = function (data, callback) {
    var self = this;

    if(!self.gatewayReference) return callback(new Error('Device not registered'));

    var output = {
        time: (new Date()).toString(),
        value: data
    };

    // self.gatewayReference.publish(self.uuid, "DAT", JSON.stringify(output), callback);
    self.gatewayReference.publish(self.uuid, "DAT", JSON.stringify(data), callback);
};
```