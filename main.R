# Load required libraries
library("LexisNexisTools")
library("dplyr")
library("quanteda")
library("stm")
library("wordcloud")
library("igraph")
library("stminsights")
library("tidyverse")
library("ggplot2")
library("tidytext")
library("reshape2")

# Read documents
setwd("~/Desktop/media framing-newspaper data/")
file_list <- list.files(pattern = "\\.docx?$")
LNToutput = lnt_read(file_list, convert_date = TRUE)


# Creating the data frame
df <- right_join(LNToutput@meta, LNToutput@articles, by = "ID")
df <- dplyr::filter(df, !is.na(Date))

# Transform date to numeric
df$Date <- as.numeric(df$Date)

# Performing the STM
processed <- textProcessor(df$Article, metadata = df)
out <- prepDocuments(processed$documents, processed$vocab, processed$meta)
docs <- out$documents
vocab <- out$vocab
meta <-out$meta

First_STM <- stm(documents = out$documents, vocab = out$vocab,
                 K = 20, prevalence =~  s(Date),
                 max.em.its = 75, data = out$meta,
                 init.type = "Spectral", verbose = FALSE)

# Get common words of the topics
topic_terms <- labelTopics(First_STM, c(1:20))

# Define custom topic names (Modify these names based on your research focus)
topicNames <- c("Topic 1", "Topic 2", "Topic 3", "Topic 4", "Topic 5", "Topic 6",
                "Topic 7", "Topic 8", "Topic 9", "Topic 10", "Topic 11", "Topic 12",
                "Topic 13", "Topic 14", "Topic 15", "Topic 16", "Topic 17",
                "Topic 18", "Topic 19", "Topic 20")

# Display STM topics ordered by expected topic proportions
par(bty="n",col="grey40",lwd=5)
plot.STM(First_STM, type = "summary", custom.labels = "", topic.names = topicNames)

# Plot word distribution in selected topics
tidy_stm <- tidytext::tidy(First_STM)
selected_topics <- c(1, 2, 11, 13, 15, 16)

# Modify these numbers based on the topics you want to display
tidy_stm_filter <- filter(tidy_stm, topic %in% selected_topics)

tidy_stm_filter %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ggplot(aes(term, beta, fill = as.factor(topic))) +
  geom_col(alpha = 0.8, show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_y") +
  coord_flip() +
  scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
  labs(x = NULL, y = expression(beta))

# Save the plot to a file
ggsave("topic_word_distribution.png", width = 10, height = 8, dpi = 300)

# Find thoughts of stm (Modify the 'topics' argument with the topic numbers you want to analyze)
findThoughts(model = First_STM, texts = df$Article, topics = 2, n = 10)

# Topic correlation
topicCorr(First_STM, method = c("simple", "huge"), cutoff = 0.01, verbose = TRUE)

# Estimate the effect of the date
First_STM_Time_Effect <- estimateEffect(formula = 1:20 ~ s(Date), stmobj = First_STM, metadata = out$meta,
                                        uncertainty = "Global")

# Plot the effect of the date for selected topics (Modify 'topics' argument based on the topics you want to display)
par(lwd = 2)
plot.estimateEffect(First_STM_Time_Effect, "Date", method = "continuous", topics = selected_topics,
                    model = First_STM, printlegend = FALSE, xaxt = "n", xlab = "Time", ylim = c(-.2, 0.6),
                    linecol = c("red", "orange", "darkgreen"))

yearseq = seq(from = as.Date("1980-01-01"),
              to = as.Date("2022-12-12"), by = "year")
yearnames = as.numeric(format(as.Date(yearseq), "%Y"))
axis(1, at = as.numeric(yearseq), labels = yearnames)

# Add a legend to the plot (Modify the labels to match your selected topics)
legend("topright", legend = c("Topic 1", "Topic 2", "Topic 11", "Topic 13", "Topic 15", "Topic 16"),
       col = c("red", "orange", "darkgreen"), lwd = 2)

# Save the plot to a file
ggsave("topic_time_effect.png", width = 10, height = 8, dpi = 300)


# Create a document-topic matrix
theta <- tidy(First_STM, matrix = "theta")
doc_topic_matrix <- spread(theta, key = "topic", value = "gamma")
rownames(doc_topic_matrix) <- doc_topic_matrix$document
doc_topic_matrix$document <- NULL

# Calculate topic proportions for each document
topic_proportions <- apply(doc_topic_matrix, 1, function(x) x / sum(x))

# Add topic proportions to the original data frame
df_topics <- cbind(df, topic_proportions)

# Save the document-topic proportions data frame to a CSV file
write.csv(df_topics, "document_topic_proportions.csv
