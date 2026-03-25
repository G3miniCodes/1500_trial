# =============================================================================
# Sales & Customer Analytics Pipeline
# Author: Analytics Team
# Description: End-to-end data analysis pipeline for retail sales data,
#              including EDA, statistical modelling, and reporting.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. LIBRARY IMPORTS
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
  library(janitor)
  library(skimr)
  library(corrplot)
  library(glmnet)
  library(caret)
  library(randomForest)
  library(xgboost)
  library(ggplot2)
  library(patchwork)
  library(viridis)
  library(knitr)
  library(broom)
  library(forcats)
})

# Set global options
options(scipen = 999, digits = 4)
set.seed(42)

# -----------------------------------------------------------------------------
# 2. CONFIGURATION & CONSTANTS
# -----------------------------------------------------------------------------

CONFIG <- list(
  raw_data_path    = "data/raw/sales_data.csv",
  clean_data_path  = "data/processed/sales_clean.rds",
  output_dir       = "output/",
  fig_dir          = "output/figures/",
  model_dir        = "models/",
  train_split      = 0.80,
  cv_folds         = 5,
  alpha_level      = 0.05,
  top_n_products   = 20,
  forecast_horizon = 12   # months
)

REGIONS    <- c("North", "South", "East", "West", "Central")
CATEGORIES <- c("Electronics", "Clothing", "Groceries", "Furniture",
                "Toys", "Sports", "Beauty", "Books")

# -----------------------------------------------------------------------------
# 3. HELPER FUNCTIONS
# -----------------------------------------------------------------------------

#' Create output directories if they don't exist
setup_dirs <- function(dirs) {
  invisible(lapply(dirs, function(d) {
    if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  }))
}

#' Safe log transformation (handles zeros)
safe_log <- function(x, offset = 1) log(x + offset)

#' Winsorize a numeric vector at given quantile thresholds
winsorize <- function(x, lower = 0.01, upper = 0.99) {
  q <- quantile(x, probs = c(lower, upper), na.rm = TRUE)
  x[x < q[1]] <- q[1]
  x[x > q[2]] <- q[2]
  x
}

#' Calculate MAPE (Mean Absolute Percentage Error)
mape <- function(actual, predicted) {
  non_zero <- actual != 0
  mean(abs((actual[non_zero] - predicted[non_zero]) / actual[non_zero])) * 100
}

#' Pretty-print a section header to the console
section <- function(title, width = 70) {
  bar <- strrep("=", width)
  cat("\n", bar, "\n")
  cat(" ", title, "\n")
  cat(bar, "\n\n")
}

#' Summarise missing values in a data frame
missing_summary <- function(df) {
  df %>%
    summarise(across(everything(),
                     list(n_miss  = ~ sum(is.na(.)),
                          pct_miss = ~ round(mean(is.na(.)) * 100, 2)))) %>%
    pivot_longer(everything(),
                 names_to  = c("variable", ".value"),
                 names_sep = "_(?=[^_]+$)") %>%
    arrange(desc(pct_miss))
}

# -----------------------------------------------------------------------------
# 4. DATA SIMULATION (replaces CSV load for reproducibility)
# -----------------------------------------------------------------------------

section("Generating Synthetic Sales Data")

n_records <- 15000

raw_sales <- tibble(
  transaction_id  = paste0("TXN", formatC(seq_len(n_records), width = 6,
                                          flag = "0")),
  transaction_date = sample(
    seq(as.Date("2022-01-01"), as.Date("2024-12-31"), by = "day"),
    n_records, replace = TRUE
  ),
  customer_id     = paste0("CUST", sample(1:3000, n_records, replace = TRUE)),
  product_id      = paste0("PROD", sample(1:500,  n_records, replace = TRUE)),
  category        = sample(CATEGORIES, n_records, replace = TRUE,
                           prob = c(0.20, 0.15, 0.18, 0.08,
                                    0.10, 0.10, 0.09, 0.10)),
  region          = sample(REGIONS,    n_records, replace = TRUE),
  quantity        = sample(1:20, n_records, replace = TRUE),
  unit_price      = round(runif(n_records, 5, 2000), 2),
  discount_pct    = sample(c(0, 5, 10, 15, 20, 25), n_records, replace = TRUE,
                           prob = c(0.50, 0.15, 0.15, 0.10, 0.07, 0.03)),
  payment_method  = sample(c("Credit Card", "Debit Card", "Cash",
                             "Net Banking", "Wallet"),
                           n_records, replace = TRUE,
                           prob = c(0.35, 0.25, 0.15, 0.15, 0.10)),
  return_flag     = rbinom(n_records, 1, prob = 0.05)
)

# Inject some NAs to mimic real data quality issues
na_indices <- sample(seq_len(n_records), size = floor(n_records * 0.02))
raw_sales$discount_pct[na_indices] <- NA

cat("Rows:", nrow(raw_sales), " | Columns:", ncol(raw_sales), "\n")

# -----------------------------------------------------------------------------
# 5. DATA CLEANING & FEATURE ENGINEERING
# -----------------------------------------------------------------------------

section("Data Cleaning & Feature Engineering")

sales <- raw_sales %>%
  clean_names() %>%
  # Parse and derive date parts
  mutate(
    transaction_date = as.Date(transaction_date),
    year             = year(transaction_date),
    quarter          = quarter(transaction_date),
    month            = month(transaction_date, label = TRUE, abbr = TRUE),
    month_num        = month(transaction_date),
    week             = isoweek(transaction_date),
    day_of_week      = wday(transaction_date, label = TRUE, abbr = TRUE),
    is_weekend       = wday(transaction_date) %in% c(1, 7)
  ) %>%
  # Impute missing discounts with median by category
  group_by(category) %>%
  mutate(discount_pct = if_else(
    is.na(discount_pct),
    median(discount_pct, na.rm = TRUE),
    discount_pct
  )) %>%
  ungroup() %>%
  # Derived financial metrics
  mutate(
    gross_revenue    = quantity * unit_price,
    discount_amount  = gross_revenue * discount_pct / 100,
    net_revenue      = gross_revenue - discount_amount,
    is_high_value    = net_revenue > quantile(net_revenue, 0.75),
    price_tier       = cut(unit_price,
                           breaks  = c(0, 50, 200, 500, Inf),
                           labels  = c("Budget", "Mid", "Premium", "Luxury"),
                           include.lowest = TRUE)
  ) %>%
  # Remove duplicate transactions (keep first)
  distinct(transaction_id, .keep_all = TRUE) %>%
  # Exclude returns for revenue analysis
  filter(return_flag == 0)

cat("Clean rows:", nrow(sales), "\n")
cat("Date range:", format(min(sales$transaction_date)), "to",
    format(max(sales$transaction_date)), "\n")

# -----------------------------------------------------------------------------
# 6. EXPLORATORY DATA ANALYSIS
# -----------------------------------------------------------------------------

section("Exploratory Data Analysis")

## 6.1 Overall summary stats
skim_summary <- skim(sales %>% select(quantity, unit_price,
                                      discount_pct, net_revenue))
print(skim_summary)

## 6.2 Revenue by category
revenue_by_cat <- sales %>%
  group_by(category) %>%
  summarise(
    total_revenue    = sum(net_revenue),
    avg_order_value  = mean(net_revenue),
    n_transactions   = n(),
    avg_discount     = mean(discount_pct),
    .groups = "drop"
  ) %>%
  arrange(desc(total_revenue)) %>%
  mutate(revenue_share = total_revenue / sum(total_revenue) * 100)

cat("\nRevenue by Category:\n")
print(revenue_by_cat, n = Inf)

## 6.3 Monthly revenue trend
monthly_revenue <- sales %>%
  group_by(year, month_num, month) %>%
  summarise(
    revenue      = sum(net_revenue),
    transactions = n(),
    aov          = mean(net_revenue),
    .groups = "drop"
  ) %>%
  arrange(year, month_num)

## 6.4 Customer segmentation by spend
customer_stats <- sales %>%
  group_by(customer_id) %>%
  summarise(
    total_spend      = sum(net_revenue),
    avg_order_value  = mean(net_revenue),
    n_orders         = n(),
    n_categories     = n_distinct(category),
    first_purchase   = min(transaction_date),
    last_purchase    = max(transaction_date),
    days_active      = as.numeric(max(transaction_date) - min(transaction_date)),
    .groups = "drop"
  ) %>%
  mutate(
    clv_tier = case_when(
      total_spend >= quantile(total_spend, 0.90) ~ "Platinum",
      total_spend >= quantile(total_spend, 0.70) ~ "Gold",
      total_spend >= quantile(total_spend, 0.40) ~ "Silver",
      TRUE                                        ~ "Bronze"
    )
  )

cat("\nCustomer CLV Distribution:\n")
print(table(customer_stats$clv_tier))

## 6.5 Region performance
region_perf <- sales %>%
  group_by(region) %>%
  summarise(
    revenue          = sum(net_revenue),
    transactions     = n(),
    unique_customers = n_distinct(customer_id),
    avg_basket       = mean(net_revenue),
    .groups = "drop"
  ) %>%
  mutate(revenue_share = revenue / sum(revenue) * 100)

# -----------------------------------------------------------------------------
# 7. STATISTICAL ANALYSIS
# -----------------------------------------------------------------------------

section("Statistical Analysis")

## 7.1 ANOVA: Does mean net_revenue differ across categories?
aov_model <- aov(net_revenue ~ category, data = sales)
aov_summary <- summary(aov_model)
cat("One-Way ANOVA (net_revenue ~ category):\n")
print(aov_summary)

if (aov_summary[[1]]$`Pr(>F)`[1] < CONFIG$alpha_level) {
  cat("Post-hoc Tukey HSD:\n")
  tukey_result <- TukeyHSD(aov_model)
  # Show only significant pairs
  tukey_df <- as.data.frame(tukey_result$category)
  sig_pairs <- rownames(tukey_df)[tukey_df$`p adj` < CONFIG$alpha_level]
  cat("Significant pairs:", length(sig_pairs), "\n")
}

## 7.2 Chi-square: Payment method vs price tier
chi_table <- table(sales$payment_method, sales$price_tier)
chi_test   <- chisq.test(chi_table)
cat("\nChi-Square (payment_method ~ price_tier):\n")
cat("X2 =", round(chi_test$statistic, 3),
    " df =", chi_test$parameter,
    " p =", format(chi_test$p.value, digits = 4), "\n")

## 7.3 Correlation matrix for numeric features
num_vars <- sales %>%
  select(quantity, unit_price, discount_pct, gross_revenue,
         net_revenue, discount_amount) %>%
  cor(use = "complete.obs")

cat("\nCorrelation Matrix:\n")
round(num_vars, 3) %>% print()

## 7.4 T-test: Weekend vs weekday average order value
weekend_aov  <- sales %>% filter(is_weekend) %>% pull(net_revenue)
weekday_aov  <- sales %>% filter(!is_weekend) %>% pull(net_revenue)
ttest_result <- t.test(weekend_aov, weekday_aov, var.equal = FALSE)
cat("\nWelch T-test (Weekend vs Weekday AOV):\n")
cat("Weekend mean:", round(mean(weekend_aov), 2),
    " | Weekday mean:", round(mean(weekday_aov), 2), "\n")
cat("p-value:", format(ttest_result$p.value, digits = 4), "\n")

# -----------------------------------------------------------------------------
# 8. REGRESSION MODELLING (Predict net_revenue)
# -----------------------------------------------------------------------------

section("Regression Modelling")

## 8.1 Prepare modelling dataset
model_data <- sales %>%
  mutate(
    log_revenue    = safe_log(net_revenue),
    log_unit_price = safe_log(unit_price),
    category       = factor(category),
    region         = factor(region),
    price_tier     = factor(price_tier),
    payment_method = factor(payment_method),
    month_num      = as.numeric(month_num),
    quarter        = as.numeric(quarter)
  ) %>%
  select(log_revenue, quantity, log_unit_price, discount_pct,
         category, region, price_tier, is_weekend, month_num, quarter) %>%
  drop_na()

cat("Model dataset rows:", nrow(model_data), "\n")

## 8.2 Train / test split
train_idx   <- createDataPartition(model_data$log_revenue,
                                   p = CONFIG$train_split, list = FALSE)
train_data  <- model_data[ train_idx, ]
test_data   <- model_data[-train_idx, ]

cat("Train:", nrow(train_data), " | Test:", nrow(test_data), "\n")

## 8.3 Baseline OLS regression
ols_formula <- log_revenue ~ quantity + log_unit_price + discount_pct +
               category + region + is_weekend + month_num + quarter

ols_model <- lm(ols_formula, data = train_data)
ols_tidy  <- tidy(ols_model) %>%
  filter(p.value < CONFIG$alpha_level) %>%
  arrange(p.value)

cat("\nSignificant OLS Coefficients:\n")
print(ols_tidy, n = 20)

ols_glance <- glance(ols_model)
cat("\nOLS R² =", round(ols_glance$r.squared, 4),
    " | Adj. R² =", round(ols_glance$adj.r.squared, 4),
    " | AIC =", round(ols_glance$AIC, 2), "\n")

## 8.4 OLS test-set predictions
ols_preds       <- predict(ols_model, newdata = test_data)
ols_rmse        <- sqrt(mean((test_data$log_revenue - ols_preds)^2))
ols_mae         <- mean(abs(test_data$log_revenue - ols_preds))
cat("OLS -- RMSE:", round(ols_rmse, 4),
    " | MAE:", round(ols_mae, 4), "\n")

## 8.5 Ridge / Lasso via glmnet
x_train <- model.matrix(log_revenue ~ . - 1, data = train_data)
y_train <- train_data$log_revenue
x_test  <- model.matrix(log_revenue ~ . - 1, data = test_data)
y_test  <- test_data$log_revenue

# Cross-validated Ridge (alpha = 0)
cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0, nfolds = CONFIG$cv_folds)
ridge_preds <- predict(cv_ridge, s = cv_ridge$lambda.min, newx = x_test)
ridge_rmse  <- sqrt(mean((y_test - ridge_preds)^2))
cat("Ridge -- RMSE:", round(ridge_rmse, 4),
    " | λ.min =", round(cv_ridge$lambda.min, 5), "\n")

# Cross-validated Lasso (alpha = 1)
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1, nfolds = CONFIG$cv_folds)
lasso_preds <- predict(cv_lasso, s = cv_lasso$lambda.min, newx = x_test)
lasso_rmse  <- sqrt(mean((y_test - lasso_preds)^2))
cat("Lasso -- RMSE:", round(lasso_rmse, 4),
    " | λ.min =", round(cv_lasso$lambda.min, 5), "\n")

# Lasso non-zero coefficients
lasso_coef <- coef(cv_lasso, s = cv_lasso$lambda.min)
n_nonzero  <- sum(lasso_coef != 0) - 1   # subtract intercept
cat("Lasso non-zero features:", n_nonzero, "\n")

# -----------------------------------------------------------------------------
# 9. RANDOM FOREST CLASSIFICATION (High-value transaction)
# -----------------------------------------------------------------------------

section("Random Forest Classification")

## 9.1 Prepare classification dataset
clf_data <- sales %>%
  mutate(
    high_value     = factor(if_else(is_high_value, "Yes", "No"),
                            levels = c("No", "Yes")),
    category       = factor(category),
    region         = factor(region),
    price_tier     = factor(price_tier),
    log_unit_price = safe_log(unit_price),
    month_num      = as.numeric(month_num)
  ) %>%
  select(high_value, quantity, log_unit_price, discount_pct,
         category, region, price_tier, is_weekend, month_num) %>%
  drop_na()

clf_train_idx  <- createDataPartition(clf_data$high_value,
                                      p = CONFIG$train_split, list = FALSE)
clf_train      <- clf_data[ clf_train_idx, ]
clf_test       <- clf_data[-clf_train_idx, ]

cat("Class distribution (train):\n")
print(prop.table(table(clf_train$high_value)) * 100)

## 9.2 Train Random Forest
rf_ctrl <- trainControl(method          = "cv",
                         number          = CONFIG$cv_folds,
                         classProbs      = TRUE,
                         summaryFunction = twoClassSummary,
                         verboseIter     = FALSE)

rf_model <- train(
  high_value ~ .,
  data      = clf_train,
  method    = "rf",
  metric    = "ROC",
  ntree     = 300,
  trControl = rf_ctrl,
  tuneGrid  = expand.grid(mtry = c(2, 3, 4))
)

cat("\nBest RF mtry:", rf_model$bestTune$mtry, "\n")
cat("CV ROC AUC:", round(max(rf_model$results$ROC), 4), "\n")

## 9.3 Test set evaluation
rf_preds      <- predict(rf_model, newdata = clf_test)
rf_conf_mat   <- confusionMatrix(rf_preds, clf_test$high_value,
                                  positive = "Yes")
cat("\nConfusion Matrix:\n")
print(rf_conf_mat$table)
cat("\nAccuracy:", round(rf_conf_mat$overall["Accuracy"], 4))
cat(" | Kappa:",  round(rf_conf_mat$overall["Kappa"], 4), "\n")
cat("Sensitivity:", round(rf_conf_mat$byClass["Sensitivity"], 4))
cat(" | Specificity:", round(rf_conf_mat$byClass["Specificity"], 4), "\n")
cat("F1 Score:", round(rf_conf_mat$byClass["F1"], 4), "\n")

## 9.4 Variable importance
var_imp <- varImp(rf_model)$importance %>%
  rownames_to_column("Feature") %>%
  arrange(desc(Overall)) %>%
  head(10)

cat("\nTop-10 Feature Importances:\n")
print(var_imp)

# -----------------------------------------------------------------------------
# 10. TIME SERIES COMPONENTS & DECOMPOSITION
# -----------------------------------------------------------------------------

section("Time Series Analysis")

weekly_revenue <- sales %>%
  mutate(week_start = floor_date(transaction_date, unit = "week")) %>%
  group_by(week_start) %>%
  summarise(revenue = sum(net_revenue), .groups = "drop") %>%
  arrange(week_start)

# Simple centred moving average (4-week window)
weekly_revenue <- weekly_revenue %>%
  mutate(
    ma4  = stats::filter(revenue, rep(1/4, 4), sides = 2),
    ma12 = stats::filter(revenue, rep(1/12, 12), sides = 2),
    yoy_growth = (revenue / lag(revenue, 52) - 1) * 100
  )

cat("Weekly revenue stats:\n")
cat("  Mean:", round(mean(weekly_revenue$revenue), 0), "\n")
cat("  Std Dev:", round(sd(weekly_revenue$revenue), 0), "\n")
cat("  Min:", round(min(weekly_revenue$revenue), 0), "\n")
cat("  Max:", round(max(weekly_revenue$revenue), 0), "\n")

# Detect anomalous weeks (beyond 2 SD)
revenue_mean <- mean(weekly_revenue$revenue)
revenue_sd   <- sd(weekly_revenue$revenue)
anomaly_weeks <- weekly_revenue %>%
  filter(abs(revenue - revenue_mean) > 2 * revenue_sd)

cat("\nAnomalous weeks detected:", nrow(anomaly_weeks), "\n")
if (nrow(anomaly_weeks) > 0) print(anomaly_weeks %>% select(week_start, revenue))

# -----------------------------------------------------------------------------
# 11. COHORT ANALYSIS
# -----------------------------------------------------------------------------

section("Customer Cohort Analysis")

cohort_data <- sales %>%
  group_by(customer_id) %>%
  mutate(cohort_month = floor_date(min(transaction_date), "month")) %>%
  ungroup() %>%
  mutate(order_month = floor_date(transaction_date, "month")) %>%
  group_by(cohort_month, order_month) %>%
  summarise(customers = n_distinct(customer_id), .groups = "drop") %>%
  group_by(cohort_month) %>%
  mutate(
    period_number   = as.integer(
      interval(cohort_month, order_month) / months(1)
    ),
    cohort_size     = customers[period_number == 0],
    retention_rate  = customers / cohort_size * 100
  ) %>%
  ungroup()

# Average retention by period
avg_retention <- cohort_data %>%
  group_by(period_number) %>%
  summarise(
    avg_retention = mean(retention_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(period_number <= 12)

cat("Average retention by months since first purchase:\n")
print(avg_retention, n = 13)

# -----------------------------------------------------------------------------
# 12. PRODUCT AFFINITY / BASKET ANALYSIS (simplified)
# -----------------------------------------------------------------------------

section("Product Affinity Analysis")

category_pairs <- sales %>%
  select(transaction_id, category) %>%
  inner_join(
    sales %>% select(transaction_id, category) %>%
      rename(category2 = category),
    by = "transaction_id"
  ) %>%
  filter(category < category2) %>%
  count(category, category2, name = "co_occurrences") %>%
  arrange(desc(co_occurrences)) %>%
  head(15)

cat("Top category co-occurrences:\n")
print(category_pairs)

# -----------------------------------------------------------------------------
# 13. VISUALISATIONS
# -----------------------------------------------------------------------------

section("Creating Visualisations")

setup_dirs(c(CONFIG$fig_dir, CONFIG$output_dir, CONFIG$model_dir))

# Plot theme
theme_analytics <- theme_minimal(base_size = 11) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(colour = "grey50", size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

## Plot 1: Revenue by category (bar chart)
p1 <- revenue_by_cat %>%
  mutate(category = fct_reorder(category, total_revenue)) %>%
  ggplot(aes(x = total_revenue / 1e6, y = category, fill = revenue_share)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(round(revenue_share, 1), "%")),
            hjust = -0.1, size = 3) +
  scale_fill_viridis_c(option = "D") +
  scale_x_continuous(labels = label_dollar(suffix = "M")) +
  labs(title    = "Net Revenue by Product Category",
       subtitle = "Filtered: Returns excluded",
       x = "Net Revenue (USD Millions)", y = NULL) +
  theme_analytics

## Plot 2: Monthly revenue trend with 3-month MA
p2 <- monthly_revenue %>%
  mutate(date = as.Date(paste(year, month_num, "01", sep = "-"))) %>%
  ggplot(aes(x = date, y = revenue / 1e3)) +
  geom_line(colour = "#1f77b4", linewidth = 0.7) +
  geom_smooth(method = "loess", span = 0.3, se = TRUE,
              colour = "#ff7f0e", fill = "#ff7f0e", alpha = 0.15) +
  scale_y_continuous(labels = label_dollar(suffix = "K")) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  labs(title    = "Monthly Net Revenue Trend",
       subtitle = "Orange ribbon = LOESS smoothed trend ± 95% CI",
       x = NULL, y = "Revenue (USD Thousands)") +
  theme_analytics +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

## Plot 3: Customer CLV tier pie / bar
p3 <- customer_stats %>%
  count(clv_tier) %>%
  mutate(clv_tier = fct_reorder(clv_tier, n)) %>%
  ggplot(aes(x = n, y = clv_tier, fill = clv_tier)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = comma(n)), hjust = -0.1, size = 3) +
  scale_fill_brewer(palette = "YlOrRd") +
  labs(title = "Customer Distribution by CLV Tier",
       x = "Number of Customers", y = NULL) +
  theme_analytics

## Plot 4: Discount vs net revenue scatter (sample)
set.seed(7)
p4_data <- sales %>% sample_n(2000)
p4 <- ggplot(p4_data, aes(x = discount_pct, y = net_revenue,
                           colour = category)) +
  geom_jitter(alpha = 0.35, size = 0.8, width = 0.5) +
  scale_y_log10(labels = label_dollar()) +
  scale_colour_viridis_d(option = "C") +
  labs(title    = "Discount % vs Net Revenue (log scale)",
       subtitle = "Sample n = 2,000 transactions",
       x = "Discount (%)", y = "Net Revenue (log USD)",
       colour = "Category") +
  theme_analytics +
  guides(colour = guide_legend(nrow = 2, override.aes = list(size = 2)))

## Combine and save
combined_plot <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title   = "Retail Sales Analytics Dashboard",
    caption = paste("Generated:", Sys.time()),
    theme   = theme(plot.title = element_text(face = "bold", size = 16))
  )

ggsave(
  filename = file.path(CONFIG$fig_dir, "dashboard.png"),
  plot     = combined_plot,
  width    = 16, height = 10, dpi = 150
)
cat("Dashboard saved to:", file.path(CONFIG$fig_dir, "dashboard.png"), "\n")

# -----------------------------------------------------------------------------
# 14. MODEL COMPARISON SUMMARY
# -----------------------------------------------------------------------------

section("Model Performance Summary")

model_comparison <- tribble(
  ~Model,        ~RMSE,             ~Notes,
  "OLS",          ols_rmse,         "Baseline linear regression",
  "Ridge",        ridge_rmse,       paste0("lambda=", round(cv_ridge$lambda.min, 5)),
  "Lasso",        lasso_rmse,       paste0("lambda=", round(cv_lasso$lambda.min, 5),
                                           ", features=", n_nonzero)
) %>%
  arrange(RMSE) %>%
  mutate(rank = row_number())

cat("Regression Models (target: log net_revenue):\n")
print(model_comparison)

cat("\nClassification Model (Random Forest - High Value):\n")
cat("  AUC ROC:     ", round(max(rf_model$results$ROC), 4), "\n")
cat("  Accuracy:    ", round(rf_conf_mat$overall["Accuracy"], 4), "\n")
cat("  F1 Score:    ", round(rf_conf_mat$byClass["F1"], 4), "\n")

# -----------------------------------------------------------------------------
# 15. EXPORT RESULTS
# -----------------------------------------------------------------------------

section("Exporting Results")

# Save cleaned data
saveRDS(sales, CONFIG$clean_data_path)
cat("Clean data saved to:", CONFIG$clean_data_path, "\n")

# Save summary tables as CSV
write_csv(revenue_by_cat,  file.path(CONFIG$output_dir, "revenue_by_category.csv"))
write_csv(region_perf,     file.path(CONFIG$output_dir, "region_performance.csv"))
write_csv(customer_stats,  file.path(CONFIG$output_dir, "customer_segments.csv"))
write_csv(avg_retention,   file.path(CONFIG$output_dir, "cohort_retention.csv"))
write_csv(model_comparison, file.path(CONFIG$output_dir, "model_comparison.csv"))
cat("Summary CSVs exported to:", CONFIG$output_dir, "\n")

# Save best regression model
saveRDS(ols_model, file.path(CONFIG$model_dir, "ols_revenue_model.rds"))
saveRDS(cv_ridge,  file.path(CONFIG$model_dir, "ridge_revenue_model.rds"))
saveRDS(rf_model,  file.path(CONFIG$model_dir, "rf_highvalue_classifier.rds"))
cat("Models saved to:", CONFIG$model_dir, "\n")

# -----------------------------------------------------------------------------
# 16. SESSION INFO
# -----------------------------------------------------------------------------

section("Session Information")
sessionInfo()

cat("\n\nPipeline complete at", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
