#WORKING WITH BINARY TREE
class TreeNode:
    def __init__(self, value):
        self.val = value
        self.left = None
        self.right = None

def bfs_traversal(root):
    if root is None:
        return []

    result = []
    queue = [root]

    while queue:
        node = queue.pop(0)
        result.append(node.val)

        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)

    return result

root = TreeNode(1)
root.left = TreeNode(2)
root.right = TreeNode(3)
root.left.left = TreeNode(4)
root.left.right = TreeNode(5)

print("BFS Traversal:", bfs_traversal(root))


#TRAIN A SIMPLE ML MODEL
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.preprocessing import LabelEncoder
df = pd.read_csv(r"C:\Users\sujit\Downloads\titanic\train.csv")
df.head(10)
df.describe()
dummydf= df.copy()
null_values=df.isnull()
null_values
df['Age'].fillna(Age_mean, inplace = True)
survival_rate_by_class=df.groupby('Pclass')['Survived'].mean()*100
print(survival_rate_by_class)
label_encoder = LabelEncoder()
df['Sex'] = label_encoder.fit_transform(features['Sex'])
from sklearn.ensemble import RandomForestClassifier

y = df["Survived"]

features = ["Pclass", "Sex", "SibSp", "Parch"]
X = pd.get_dummies(df[features])
X_test = pd.get_dummies(test_df[features])

model = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=1)
model.fit(X, y)
predictions = model.predict(X_test)

output = pd.DataFrame({'PassengerId': test_df.PassengerId, 'Survived': predictions})
output.to_csv('submission.csv', index=False)
print("Your submission was successfully saved!")
