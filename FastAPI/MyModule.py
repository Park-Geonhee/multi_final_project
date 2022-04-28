import glob
import cv2
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
#
#
# def imageClassify(img_path):
#
#     print(mean)
#     return mean

def Scoring(img_path,survey):
    out = []
    # img_path = './image'
    # '/image'
    model_path = './model'
    img_folder_paths = glob.glob(img_path + '/*.jpg')
    model_paths = glob.glob(model_path + '/*.h5')
    for i in img_folder_paths:
        image_name = i.split('\\')[-1]
        image_name = i[:-4]
        image = cv2.imread(i)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image = cv2.resize(image, (224, 224))
        image = np.array(image) * 1. / 255
        image = image.reshape(1, 224, 224, 3)
        for model in model_paths:
            # ./model/dandruff_resnet.h5
            model_name = model.split('/')[-1]
            # dandruff_resnet.h5
            model_name = model_name.split('_')[0]
            # dandruff
            model_name = model_name.split('\\')[-1]
            # model\dandruff > dandruff
            model = load_model(model, compile=False)
            prediction = model.predict(image)
            max = np.argmax(prediction)
            out.append([image_name, model_name, max])
    out = pd.DataFrame(out, columns=['image_name', 'model_name', 'predict'])
    print(out)
    mean = out.groupby(by='model_name').mean().reset_index()
    mean = mean.set_index('model_name')
    print(mean)
    scalp_type = np.where(survey[0] > survey[1], '건성',
                          np.where(survey[0] < survey[1], '지성', '중성')).tolist()

    scalp_score = np.where(scalp_type == 0, 0, round((mean['predict'].dryscalp + mean['predict'].oilyscalp) / 2, 1)).tolist()
    hairloss_score = round(np.mean([mean['predict'].hairloss, min(survey[4], survey[5])]), 1)
    sensitivity_score = round(np.mean([mean['predict'].erythema, survey[2]]), 1)
    dandruff_score = round(np.mean([mean['predict'].dandruff, mean['predict'].folliculitis]), 1)
    folliculitis_score = round(np.mean([mean['predict'].folliculitis, survey[3], mean['predict'].erythema]), 1)
    final_list = [scalp_score, hairloss_score, sensitivity_score, dandruff_score, folliculitis_score]
    return final_list

# def FasterRCNN(image):
#
#     return

def Recommend(survey, final_list):
    scalp_type = np.where(survey[0] > survey[1], '건성',
                          np.where(survey[0] < survey[1], '지성', '중성')).tolist()
    rec_list = [i for i, x in enumerate(final_list) if x >= 2]
    final_index = [scalp_type, '탈모', '민감성', '비듬', '두피염']
    final_keyword = list(map(lambda x: final_index[x], rec_list))
    final_keyword = ', '.join(final_keyword)
    # csv에서 입력받은 키워드로 추천상품 추출
    shampoo = pd.read_csv('./data/shampoo.csv')
    result = shampoo[shampoo['spec_list'].apply(lambda words: all(word in words for word in final_keyword))]
    result = result[result['rate'] > 4.6]
    result.sort_values(['rate', 'opinion'], ascending=False, ignore_index=True, inplace=True)
    result_list = result.values.tolist()
    return result_list
