Walmart-Retail-Sales-Linear-Regression-Prediction
=================================================

A bagging algorithm to predict retail sales at a number of WalMart stores based on economic condition indicators. This project was completed as a part of a Kaggle competition in which WalMart made data available on select WalMart stores. The data contains the weekly sales figure for each store observed over a period of time. The data also contain economic condition variables which are used to predict the magnitude of retail sales at the store.

The largest determining variable for the retail sales of a WalMart store is whether or not the week in question is a holiday weekend or not. Store discounts on select departments also has a moderate impact on weekly sales. The code generates 2 bagging classification algorithms (one that is subset on the individual WalMart stores and one that does not take individual stores into account). The retail sales dollar values for the stores are discretized into factor levels so that the algorithm can be used to make a discrete choice classification.

The model was evaluated by a random partition of the data into a testing set that was performed by WalMart. The evaluation of the model predictions on the out of sample data is also weighted to penalize errors on holiday weekend observations more than errors on non-holiday weekends. The weighted mean squared error (WMSE) for this model is $4430.86 on out of sample predictions. The winning submission for this competition has a WMSE of $2301.48. 
