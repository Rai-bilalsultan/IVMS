from ultralytics import YOLO
import easyocr
import cv2
import re

# Use a YOLO model trained for license plates
model = YOLO("yolo11n.pt")
reader = easyocr.Reader(['en'])

def detect_plate_and_read(image_path):
    image = cv2.imread(image_path)
    results = model(image)  # YOLO plate detection

    for r in results:
        for box in r.boxes:
            # x1, y1, x2, y2 = map(int, box.xyxy[0])
            # crop = image[y1:y2, x1:x2]

            # # ---------- PREPROCESS ----------
            # gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
            # gray = cv2.bilateralFilter(gray, 11, 17, 17)

            # # Resize for better OCR
            # height = 200
            # ratio = height / crop.shape[0]
            # width = int(crop.shape[1] * ratio)
            # resized_crop = cv2.resize(gray, (width, height))

            # # Threshold to enhance letters
            # thresh = cv2.adaptiveThreshold(
            #     resized_crop,
            #     255,
            #     cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            #     cv2.THRESH_BINARY,
            #     2
            # )

            # ---------- OCR ----------
            text = reader.readtext(image, detail=0)
            print("TEXT-------------->", text)

            if text:
                plate = ''.join(text[1])
                # ---------- NORMALIZE ----------
                plate = plate.replace(" ", "").replace("-", "").upper()
                plate = re.sub(r'[^A-Z0-9]', '', plate)
                print("PLATE------------->", plate)

                # Optional: save debug images
                cv2.imwrite("debug_plate.jpg", image)
                cv2.imwrite("debug_processed_plate.jpg", image)

                return plate

    return None, None