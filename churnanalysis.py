#!/usr/bin/env python
# coding: utf-8

# In[11]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


# # #DATA OVERVIEW

# In[4]:


df = pd.read_csv(r'C:/Users/sujit/Desktop/Churn_analysis_sujit.csv')


# In[5]:


df.describe()

Attribute year is having a zero standard deviation because all the elements of attribute year are same, i.e. the year 2021. The dataset contains only the data about the customers who were there on the platform during the year 2021. There are 1918 rows, i.e. 1918 customers in total. This is after we remove the null values from the dataset. Age of the customer varies from 18 to 82. The main attribute used to describe if the customer churned or not is based on maximum days the customer was inactive. The minimum value for this attribute is 0, which is reasonable as some of the customers may not be inactive on the platform, but the maximum value is 6, i.e. some of the customers were inactive for longer time and result into getting churned. This description says a lot about the customers, i.e. the average customers were of age 38-39 and on a average 0.13% of customers are getting churned
# ### Checking for the missing values

# In[6]:


df.isna().sum()

As we can see there are 24, 23, 35 missing vlues in gender, maximum_days_inactive and churned respectvely.So,we Dropping rows with missing values
# In[7]:


df = df.dropna()
df


# ### Encoding Categorical Variables 

# In[8]:


df.head(5)

As we can see there are four categorical variables: Gender, multi_screen, mail_subscribed and churned
# ### Feature Engineering

# In[ ]:


#adding a colum of age_group categorizing ages in group


# In[22]:


bins = [0, 20, 30, 40, 50, 60, 70, 80, 90, 100]
labels = ['0-20', '20-30', '30-40', '40-50', '50-60', '60-70', '70-80', '80-90', '90-100']
df['age_group'] = pd.cut(df['age'], bins=bins, labels=labels, right=False)
age_group_counts = df['age_group'].value_counts()

print(age_group_counts)


# #### Finding churned rate

# In[9]:


df['churned'].value_counts()

255 of total consumers churned that means the churn rate is : (255/1922)*100= 13.26% churn rate
# # Exploratory Data Analysis

# ### Univariate Analysis

# In[23]:


#distribution of age group in dataset
plt.figure(figsize=(12, 6))
sns.barplot(x=age_group_counts.index, y=age_group_counts.values)
plt.title('Distribution of Age Groups in the Dataset')
plt.xlabel('Age Group')
plt.ylabel('Count')
plt.show()
max_age_group = age_group_counts.idxmax()
print(f'The age group with the maximum count is: {max_age_group}')


# In[12]:


#distribution of target variable
sns.countplot(x='churned', data=df)
plt.title('Churn Distribution')
plt.show()


# In[19]:



gender_counts = df['gender'].value_counts()
print(gender_counts)
sns.barplot(x=gender_counts.index, y=gender_counts.values)
plt.title('Distribution of Gender in the Dataset')
plt.xlabel('Gender')
plt.ylabel('Count')
plt.show()


# ## Bivariate Analysis

# In[29]:


#Relationship between Age_group and Churn status
import seaborn as sns
import matplotlib.pyplot as plt
plt.figure(figsize=(12, 6))

churn_counts = df.groupby(['age_group', 'churned']).size().unstack(fill_value=0)

churn_counts.plot(kind='bar', stacked=True, colormap='viridis', width=0.6)
plt.title('Relationship between Age Group and Churned Status')
plt.xlabel('Age Group')
plt.ylabel('Count')
plt.legend(title='Churned', labels=['Not Churned', 'Churned'], loc='upper right')

plt.show()

for index, row in churn_counts.iterrows():
    print(f"Age Group: {index}, Churned customer Count: {row[1]}")

Bar plots for categorical features with respected to target variable 'Churned'
# In[31]:


#Countplot for the categorical columns
categorical_cols = ['gender', 'multi_screen', 'mail_subscribed']
for col in categorical_cols:
    sns.countplot(x=col, hue='churned', data=df)
    plt.title(f'{col} relationship with the churn status')
    plt.show()


# In[32]:


#Relationship between the maximum_days_inactive and Churn status

plt.figure(figsize=(10, 6))

sns.boxplot(x='churned', y='maximum_days_inactive', data=df, palette='pastel')
plt.title('Relationship between Maximum Days Inactive and Churned Status')
plt.xlabel('Churned')
plt.ylabel('Maximum Days Inactive')
plt.xticks([0, 1], ['Not Churned', 'Churned'])

plt.show()

No such strong correlation between the maximum days inactive and churn status is there.
# In[33]:


#Realtionship between maximum_days_inactive and minimum_daily_minutes
plt.figure(figsize=(10, 6))

sns.scatterplot(x='maximum_days_inactive', y='minimum_daily_mins', data=df, palette='pastel')
plt.title('Relationship between Maximum Days Inactive and Minimum Daily Minutes')
plt.xlabel('Maximum Days Inactive')
plt.ylabel('Minimum Daily Minutes')

plt.show()

As the daily watching time of a consumer increases the more days he is likely to be inactive.
# #### Correlation Matrix
A positive correlation (close to 1) indicates a strong positive relationship, while a negative correlation (close to -1) indicates a strong negative relationship between the given variables.
# In[20]:


import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 8))

numerical_columns = ['age', 'no_of_days_subscribed', 'weekly_mins_watched', 'minimum_daily_mins', 'maximum_daily_mins', 'videos_watched', 'maximum_days_inactive', 'customer_support_calls']

correlation_matrix = df[numerical_columns].corr()

sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', linewidths=.5)
plt.title('Correlation Heatmap')
plt.show()


# # BUILDING PREDICTIVE MODEL

# In[34]:


#Data Preprocessing
df.dtypes


# In[39]:


import pandas as pd

categorical_cols = ['gender', 'multi_screen', 'mail_subscribed']
df_encoded = pd.get_dummies(df, columns=categorical_cols, drop_first=True)

df_encoded['churned'] = df['churned'].map({'No': 0, 'Yes': 1})

df_encoded.head(5)


# In[40]:


df.isna().sum()


# ## Split the dataset using Sklearn library

# In[65]:


from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

# Exclude columns from features
columns_to_exclude = ['year', 'customer_id', 'phone_no', 'age_group']
X = df_encoded.drop(columns=columns_to_exclude, axis=1)
y = df_encoded['churned']

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)


# ## Create a Logistic Regression Model 

# In[59]:


model = LogisticRegression(random_state=42)
# Train the model
model.fit(X_train, y_train)


# ## Testing The Model on the test set

# In[64]:


y_pred = model.predict(X_test)

# Evaluate the model
accuracy = accuracy_score(y_test, y_pred)
conf_matrix = confusion_matrix(y_test, y_pred)
classification_rep = classification_report(y_test, y_pred)

print(f'Accuracy: {accuracy}')
print(f'Confusion Matrix:\n{conf_matrix}')
print(f'Classification Report:\n{classification_rep}')


# ### Accuracy that we got while predicting using this model is 1 which is excellent.
# 
# 
# ### The confusion matrix indicates that there are 336 true negatives (TN) and 49 true positives (TP). There are no false positives (FP) or false negatives (FN), resulting in a perfect classification.
# 
# 
# ### Precision, recall, and F1-score are all perfect for both classes (0 and 1). This indicates that the model is performing exceptionally well.
# 
