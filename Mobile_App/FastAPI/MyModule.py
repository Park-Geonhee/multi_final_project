import glob
import cv2
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
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
    # print(out)
    mean = out.groupby(by='model_name').mean().reset_index()
    mean = mean.set_index('model_name')
    print(mean)
    scalp_type = np.where(survey[0] > survey[1], '건성',
                          np.where(survey[0] < survey[1], '지성', '중성')).tolist()
    scalp_score = np.where(scalp_type == 0, 0,
                           round((mean['predict'].dryscalp + mean['predict'].oilyscalp) / 2, 1)).tolist()

    hairloss_score = round(np.mean([mean['predict'].hairloss, min(survey[4], survey[5])]), 1)

    sensitivity_score = round(np.mean([mean['predict'].erythema, survey[2]]), 1)

    dandruff_score = round(np.mean([mean['predict'].dandruff, mean['predict'].folliculitis]), 1)

    folliculitis_score = round(np.mean([mean['predict'].folliculitis, survey[3], mean['predict'].erythema]), 1)

    final_list = [scalp_score, hairloss_score, sensitivity_score, dandruff_score, folliculitis_score]

    return final_list, scalp_type

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

    shampoo = pd.read_excel('./data/shampoo.xlsx')

    result = shampoo[shampoo['spec_list'].apply(lambda words: all(word in words for word in final_keyword))]

    result = result[result['rate'] > 4.5]

    result.sort_values(['rate', 'opinion'], ascending=False, ignore_index=True, inplace=True)

    #######################################

    count_vect = TfidfVectorizer(min_df=0, ngram_range=(1, 1))

    specs_mat = count_vect.fit_transform(shampoo['spec_list'])

    specs_sim = cosine_similarity(specs_mat, specs_mat)

    specs_sim_sorted_ind = specs_sim.argsort()[:, ::-1]

    base_name = result.iloc[0]['title']
    base_shampoo = shampoo[shampoo['title'] == base_name]
    base_index = base_shampoo.index.values

    similar_indexes = specs_sim_sorted_ind[base_index, :10]

    similar_indexes = similar_indexes.reshape(-1)

    result_CBF = shampoo.iloc[similar_indexes]

    result_list = result_CBF.values.tolist()

    # ################################################

    serum = pd.read_excel('./data/serum.xlsx')
    print(final_keyword)
    result_serum = serum[serum['spec_list'].apply(lambda words: all(word in words for word in final_keyword))]

    print(result_serum)
    #result_serum = result_serum[result_serum['rate'] > 4.5]

    if result_serum.empty:

        print('Serum list is None!')
        print('Recommend Completed!')

        result_list_serum = []

        return result_list, result_list_serum

    else:

        result_serum.sort_values(['rate', 'opinion'], ascending=False, ignore_index=True, inplace=True)

        count_vect_serum = TfidfVectorizer(min_df=0, ngram_range=(1, 1))

        specs_mat_serum = count_vect_serum.fit_transform(serum['spec_list'])

        specs_sim_serum = cosine_similarity(specs_mat_serum, specs_mat_serum)

        specs_sim_sorted_ind_serum = specs_sim_serum.argsort()[:, ::-1]

        base_name_serum = result_serum.iloc[0]['title']
        base_serum = serum[serum['title'] == base_name_serum]
        base_index_serum = base_serum.index.values

        similar_indexes_serum = specs_sim_sorted_ind_serum[base_index_serum, :5]

        similar_indexes_serum = similar_indexes_serum.reshape(-1)

        result_CBF_serum = serum.iloc[similar_indexes_serum]

        result_list_serum = result_CBF_serum.values.tolist()

        print('Recommend Completed!')

        return result_list, result_list_serum
