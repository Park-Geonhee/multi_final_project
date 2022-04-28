import cv2
import uvicorn
from typing import Optional
import base64
from fastapi import FastAPI, Body
# import requests
from fastapi import Request
# from fastapi import File, UploadFile
import numpy as np
import nest_asyncio
from pyngrok import ngrok
# import json
# from tensorflow.keras.models import load_model
# import glob
# import pandas as pd
# from pydantic import BaseModel
import pandas as pd
import os
import re

from MyModule import Scoring, Recommend # imageClassify
from MyFasterRCNN import WheatTestDataset, get_test_transform, collate_fn, format_prediction_string

from PIL import Image
#################
from albumentations import Compose

from albumentations.pytorch.transforms import ToTensorV2

import torch
import torchvision

from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection import FasterRCNN
from torchvision.models.detection.rpn import AnchorGenerator

from torch.utils.data import DataLoader, Dataset
from torch.utils.data.sampler import SequentialSampler

import time
import urllib.request
##########################

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.post("/test")
async def getImg(req: Request):

        start = time.time()

        img = await req.json()
        # : [{}] ~ 리스트로 한번 감싸져 있음

        survey = img[0]['survey']

        # print(survey)
        survey = list(survey.values())
        survey = list(map(lambda x: x.replace('그렇지 않다', '0'), survey))
        survey = list(map(lambda x: x.replace('조금 그렇다', '1'), survey))
        survey = list(map(lambda x: x.replace('매우 그렇다', '3'), survey))
        survey = list(map(lambda x: x.replace('그렇다', '2'), survey))
        survey = list(map(lambda x: int(x), survey))
        # list 점수화 해주기
        # 그렇지않다 : 0, 조금그렇다 : 1, 그렇다 : 2, 매우그렇다 : 3

        # Image URL
        img_key_list = list(img[0].keys())[:-1]
        print(img[0])
        print(img_key_list)
        # try:
        for key in img_key_list:

                image_url = img[0][key]
                print(image_url)
                image_url = image_url[0]
                temp = urllib.request.urlopen(image_url)
                temp = np.asarray(bytearray(temp.read()), dtype='uint8')
                temp = cv2.imdecode(temp, cv2.IMREAD_COLOR)
                temp = cv2.resize(temp, (224, 224))
                cv2.imwrite('./image/test_{}.jpg'.format(key), temp)
        # except:
        #         pass
        # for key in img_key_list:
        #
        #         image_url = img[0][key]
        #         print(image_url)
        #         image_url = image_url[0]
        #         img = urllib.request.urlopen(image_url)
        #         img = np.asarray(bytearray(img.read()), dtype='uint8')
        #         img = cv2.imdecode(img, cv2.IMREAD_COLOR)
        #         img = cv2.resize(img, (224, 224))
        #         cv2.imwrite('./image/test_{}.jpg'.format(key), img)


        img_encode_list = []

        # exec(open("MyFasterRCNN.py").read())
        # mean = imageClassify()
        # print('mean')
        score_list = Scoring('./image', survey)

        recommend_list = Recommend(survey, score_list)

        ##################################################################

        DIR_TEST = './image'

        WEIGHTS_FILE = './model/fasterrcnn_resnet50_fpn.pth'

        path = './image/'
        # for image in os.listdir(path):
        #         img = cv2.imread(path + image)
        #         img = cv2.resize(img, (224, 224))
        #         cv2.imwrite(path + image, img)
        images = []
        for image in os.listdir(path):
                row = [image[:-4], '1.0 0 0 50 50']
                images.append(row)

        test_df = pd.DataFrame(images, columns=['image_id', 'PredictionString'])

        # load a model; pre-trained on COCO
        model = torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=False, pretrained_backbone=False)

        device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
        num_classes = 2  # 1 class (wheat) + background

        # get number of input features for the classifier
        in_features = model.roi_heads.box_predictor.cls_score.in_features

        # replace the pre-trained head with a new one
        model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)

        # Load the trained weights
        model.load_state_dict(torch.load(WEIGHTS_FILE))
        model.eval()

        x = model.to(device)

        test_dataset = WheatTestDataset(test_df, DIR_TEST, get_test_transform())

        test_data_loader = DataLoader(
                test_dataset,
                batch_size=10,
                shuffle=False,
                num_workers=0,
                drop_last=False,
                collate_fn=collate_fn
        )

        detection_threshold = 0.75
        results = []

        for images, image_ids in test_data_loader:

                images = list(image.to(device) for image in images)
                outputs = model(images)

                for i, image in enumerate(images):
                        boxes = outputs[i]['boxes'].data.cpu().numpy()
                        scores = outputs[i]['scores'].data.cpu().numpy()

                        boxes = boxes[scores >= detection_threshold].astype(np.int32)
                        scores = scores[scores >= detection_threshold]
                        image_id = image_ids[i]

                        boxes[:, 2] = boxes[:, 2] - boxes[:, 0]
                        boxes[:, 3] = boxes[:, 3] - boxes[:, 1]

                        result = {
                                'image_id': image_id,
                                'PredictionString': format_prediction_string(boxes, scores)
                        }

                        results.append(result)

        test_df = pd.DataFrame(results, columns=['image_id', 'PredictionString'])
        image_list = os.listdir('./image')
        for i, image in enumerate(image_list):
                sample = images[i].permute(1, 2, 0).cpu().numpy()
                boxes = outputs[i]['boxes'].data.cpu().numpy()
                scores = outputs[i]['scores'].data.cpu().numpy()

                boxes = boxes[scores >= detection_threshold].astype(np.int32)

                img_path = './image/' + image

                img_raw = cv2.imread(img_path, cv2.IMREAD_COLOR)
                for box in boxes:
                        img_raw = cv2.rectangle(img_raw,
                                                (box[0], box[1]),
                                                (box[2], box[3]),
                                                (0, 0, 220), 2)

                cv2.imwrite(img_path, img_raw)
                with open(img_path, 'rb') as img:
                        base64_string = base64.b64encode(img.read())
                img_encode_list.append(base64_string)

        ##########################
        end = time.time()
        print(f'total time(s):{end-start}')

        return {'value': score_list, 'recommend': recommend_list, 'image01': img_encode_list[0]}


ngrok_tunnel = ngrok.connect(8000)
print('Public URL:', ngrok_tunnel.public_url)
nest_asyncio.apply()
uvicorn.run(app, host="0.0.0.0", port = 8000)