
# Swift - web view proprietal messaging

  
Integration of the swift app with the web view by the custom reqResMessaging protocol.


## Example data communication

```
⬅️ JS  → iOS 2022-08-16 14:48:05 | REQUEST//ios/JS_STD_OUTPUT | id-l6w6kdi0-8vrik2sl40c 
➡️ iOS →  JS 2022-08-16 14:48:05 | RESPONSE                   | id-l6w6kdi0-8vrik2sl40c
⬅️ JS  → iOS 2022-08-16 14:48:05 | REQUEST//ios/JS_STD_OUTPUT | id-l6w6kdi5-nizf3pgmob9
➡️ iOS →  JS 2022-08-16 14:48:05 | RESPONSE                   | id-l6w6kdi5-nizf3pgmob9
⬅️ JS  → iOS 2022-08-16 14:48:08 | REQUEST//ios/ASYNC_UI      | id-l6w6kfce-nghtdgumcx}
➡️ iOS →  JS 2022-08-16 14:48:46 | REQUEST//js/REVERSE_TEXT   | id-484044587-859464217 
⬅️ JS  → iOS 2022-08-16 14:48:46 | RESPONSE                   | id-484044587-859464217
➡️ iOS →  JS 2022-08-16 14:48:46 | RESPONSE                   | id-l6w6kfce-nghtdgumcx}
```

## Example data communication with data

```
⬅️ JS  → iOS 2022-08-16 14:48:05 | REQUEST//ios/JS_STD_OUTPUT | id-l6w6kdi0-8vrik2sl40c | ["uri":ios/JS_STD_OUTPUT,"id":id-l6w6kdi0-8vrik2sl40c},"body":{message=xxx;type=error;},"directionFlow":REQUEST]
➡️ iOS →  JS 2022-08-16 14:48:05 | RESPONSE                   | id-l6w6kdi0-8vrik2sl40c | ["data":[:],"id":"id-l6w6kdi0-8vrik2sl40c}","directionFlow":"RESPONSE"]
⬅️ JS  → iOS 2022-08-16 14:48:05 | REQUEST//ios/JS_STD_OUTPUT | id-l6w6kdi5-nizf3pgmob9 | ["id":id-l6w6kdi5-nizf3pgmob9},"body":{message=logging;type=log;},"uri":ios/JS_STD_OUTPUT,"directionFlow":REQUEST]
➡️ iOS →  JS 2022-08-16 14:48:05 | RESPONSE                   | id-l6w6kdi5-nizf3pgmob9 | ["id":"id-l6w6kdi5-nizf3pgmob9}","data":[:],"directionFlow":"RESPONSE"]
⬅️ JS  → iOS 2022-08-16 14:48:08 | REQUEST//ios/ASYNC_UI      | id-l6w6kfce-nghtdgumcx} | ["directionFlow":REQUEST,"body":{h1="JSheader";},"id":id-l6w6kfce-nghtdgumcx},"uri":ios/ASYNC_UI]
➡️ iOS →  JS 2022-08-16 14:48:46 | REQUEST//js/REVERSE_TEXT   | id-484044587-859464217  | ["directionFlow":"REQUEST","body":["inputText":NAM],"id":"id-484044587-859464217","uri":"js/REVERSE_TEXT"]
⬅️ JS  → iOS 2022-08-16 14:48:46 | RESPONSE                   | id-484044587-859464217  | ["directionFlow":RESPONSE,"id":id-484044587-859464217,"data":{reversedText=MAN;}]
➡️ iOS →  JS 2022-08-16 14:48:46 | RESPONSE                   | id-l6w6kfce-nghtdgumcx} | ["directionFlow":"RESPONSE","id":"id-l6w6kfce-nghtdgumcx}","data":["age":{value=30;},"hasGender":1,"username":Kubasvehla,"gender":MAN]]
```