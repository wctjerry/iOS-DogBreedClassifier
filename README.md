# iOS-DogBreedClassifier

I am a believer of project based learning. This project is an opportunity for me to grasp basic ideas of SwiftUI (a new UI framework for iOS) and CoreML (a highly automated Machine Learning tool). Before building this project, I have very little App development experience, so this is also a challenge to myself and see how much I can do it.

The app is simple. It is a game for human players to compete with AI. After a randomized dog image showing on the screen, the player will be asked to make a decision among four choices - what is the breed of the dog. AI model will also predict a breed based on the showing dog image. The result of the prediction and the genuine breed of the dog image will be one (or two, if the prediction is different from the genuine one) of the four choices.

The player can play as many rounds as he/she wants. The player or AI will win one point if they have the right choice or prediction:

- Both AI and the player are correct, then both will win one point
- AI is not correct, but the player is, then the player will win one point
- AI is correct, but the player is not, then AI will win one point
- Both AI and the player are wrong, then both will win zero point

After the player ends the game, the final result of the game will be prompted. Guess who will win!

The AI model is trained by CoreML with a dataset from [Kaggle](https://www.kaggle.com/c/dog-breed-identification/data). There are 120 dog breeds and it is very challenging for human to correctly figure them out (at least for myself). A Jupyter Notebook (`data_preparation.ipynb`) is involved to manipulate the structure of the data so that it meets the requirement of CoreML classifier.

TODO:

1. ~~Randomly show an image along with four choices for users to choose~~
   1. ~~Implement UI with one image and four choice~~
   2. ~~Import testing images and implement selecting an image randomly~~
   3. ~~Generate four choices randomly and show correctly on the UI~~
2. ~~Implement classification model's prediction on randomly shown image~~
3. ~~Replace one of four choices with model's prediction~~
4. ~~Randomly select 5% training data as testing data. It will be used for challenging human and AI model~~
   1. ~~Extract 5% training data~~
   2. ~~Generated the game based on this testing data~~
   3. ~~Make sure the prediction and the genuine breed of the dog image will be one (or two, if the prediction is different from the genuine one) of the four choices. Also randomize the order~~
5. Implement battle between AI and human
   1. ~~Identify win or lose after a round is ended~~
   2. ~~Record the progress of the game~~
   3. ~~End button to stop the game~~
   4. ~~Prompt the result after ending the game~~
6. Enhance the performance of the model
