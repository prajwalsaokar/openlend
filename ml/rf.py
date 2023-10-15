import sklearn
import matplotlib.pyplot as plt
import numpy as np
from sklearn import *
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, precision_score, recall_score, ConfusionMatrixDisplay, f1_score
from sklearn.model_selection import RandomizedSearchCV, train_test_split
import pickle
import joblib

cols = ['grade','loan_amnt','int_rate','home_ownership','annual_inc','purpose', 'dti', 'tot_cur_bal']
acc_df = pd.read_csv("trunc_accepted.csv", usecols=cols)
acc_df.head()

acc_df['grade'] = acc_df['grade'].map({'A': 0, 'B' : 1, 'C' : 2, 'D' : 3, 'E' : 4, 'F' : 5, 'G' : 5})

purpose_map = {'debt_consolidation' : 0, 'small_business' : 1, 'home_improvement' : 2, 'major_purchase' : 3,
 'credit_card' : 4, 'other' : 5, 'house' : 6, 'vacation' : 7, 'car' : 8, 'medical' : 9, 'moving' : 10,
 'renewable_energy' : 11, 'wedding' : 12, 'educational' : 13}
acc_df['purpose'] = acc_df['purpose'].map(purpose_map)

home_ownership_map = {'MORTGAGE' : 0, 'RENT' : 1, 'OWN' : 2, 'ANY' : 3, 'NONE' : 4, 'OTHER' : 5}
acc_df['home_ownership'] = acc_df['home_ownership'].map(home_ownership_map)

curr_cols = acc_df.columns
imp = SimpleImputer(missing_values=np.nan, strategy='most_frequent')
acc_df = pd.DataFrame(imp.fit_transform(acc_df), columns = curr_cols)

X = acc_df.drop('grade', axis=1)
y = acc_df['grade']

print(X.columns)
print(y.mean())
X_train, X_test, y_train, y_test= train_test_split(X, y, test_size = 0.2)

rf = RandomForestClassifier(n_jobs = -1)
rf.fit(X_train, y_train)

joblib.dump(rf, 'model.joblib')