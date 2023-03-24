# R Script for Structural Topic Modeling (STM) of Newspaper Articles

## Overview

This R script uses the Structural Topic Model (STM) to analyze a collection of newspaper articles. The script loads required libraries, reads in the documents, and creates a data frame. It then performs the STM and creates a plot of the topics. The script also creates plots of the word distribution in selected topics, finds the most probable words in each topic, estimates the effect of time on topic proportions, and saves the document-topic proportions to a CSV file. This script is useful for researchers interested in analyzing large text corpora to identify and understand the main topics of interest.

## Libraries

This script loads several libraries that are required for the analysis, including `LexisNexisTools`, `dplyr`, `quanteda`, `stm`, `wordcloud`, `igraph`, `stminsights`, `tidyverse`, and `ggplot2`.

## Data Preparation

The script reads in a set of newspaper articles in .docx format from the LexisNexis database and creates a data frame from them. It filters out any articles that do not have a valid date, and then transforms the dates to a numeric format.

## Topic Modeling

The script performs an STM analysis on the documents, creating 20 topics. It gets the common words for each topic and defines custom topic names. It then displays the topics in a plot, ordered by expected topic proportions.

## Word Distribution

The script uses the `reshape2` package to plot the distribution of words in selected topics. It saves the resulting plot to a file named "topic_word_distribution.png".

## Most Representative Documents

The script finds the top 10 most representative documents for a specified topic using the `findThoughts` function and computes the topic correlation using the `topicCorr` function.

## Effect of Date on Topics

The script estimates the effect of the date on the topics using the `estimateEffect` function and plots the effect of the date for selected topics. It saves the resulting plot to a file named "topic_time_effect.png".

## Document-Topic Matrix

Finally, the script creates a document-topic matrix, calculates topic proportions for each document, adds the topic proportions to the original data frame, and saves the resulting data frame to a CSV file named "document_topic_proportions.csv".

This R script is useful for researchers who want to analyze large text corpora to identify and understand the main topics of interest. It uses a dataset of newspaper articles from the LexisNexis database, and provides a step-by-step approach to topic modeling, including various plots and analyses to assist researchers in their analysis.
