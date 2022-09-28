import websockets
import asyncio
from tflite_support.task import core
from tflite_support.task import processor
from tflite_support.task import vision
import cv2, base64

print("Started server on port : ", 5000)

async def transmit(websocket, path):
    print("Client Connected !")

    base_options = core.BaseOptions(
      file_name='./models/lite-model_ssd_mobilenet_v1_1_metadata_2.tflite',
      use_coral=False,
      num_threads=4,
      )

    options = vision.ObjectDetectorOptions(
      base_options
    )

    detector = vision.ObjectDetector.create_from_options(options)

    try :
        cap = cv2.VideoCapture(0)
        while cap.isOpened():
            _, frame = cap.read()
            
            encoded = cv2.imencode('.jpg', frame)[1]

            data = str(base64.b64encode(encoded))
            data = data[2:len(data)-1]

            tensor_image = vision.TensorImage.create_from_array(frame)
            detect = detector.detect(tensor_image)

            for i in range(len(detect.detections)):
                if (detect.detections[i].categories[0].score > 0.6) & (detect.detections[i].categories[0].category_name != "tv"):
                    cv2.rectangle(frame, (detect.detections[i].bounding_box.origin_x, detect.detections[i].bounding_box.origin_y), (detect.detections[i].bounding_box.origin_x + detect.detections[i].bounding_box.width, detect.detections[i].bounding_box.origin_y + detect.detections[i].bounding_box.height), (0, 255, 0), 2)
                    cv2.putText(frame, detect.detections[i].categories[0].category_name, (detect.detections[i].bounding_box.origin_x, detect.detections[i].bounding_box.origin_y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

            await websocket.send(data)
            cv2.imshow("Transimission", frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    except websockets.connection.ConnectionClosed as e:
        print("Client Disconnected !")

start_server = websockets.serve(transmit, "127.0.0.1", 5000)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()